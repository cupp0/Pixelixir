//every operator that is not primitive is a composite operator
class CompositeOperator extends Operator implements DynamicPorts{

  ArrayList<UpdateObject> updaters = new ArrayList<>(); //which porks are providing new data to the window
                                                        //keyed by this operator
  CompositeOperator(){
    super();
    name = "composite"; label = "";
  }
  
  void initializeWindow(){
    windows.put(this, new Window(this));
  }
  
  void initialize(){}
  
  //one send / receive per window so that each composite has a clear line of communication
  ReceiveOperator getReceiver(){
    for (Operator op : kids){
      if (op.name.equals("receive")){
        return (ReceiveOperator)op;
      }
    }
    return null;
  }
  
  SendOperator getSender(){
    for (Operator op : kids){
      if (op.name.equals("send")){
        return (SendOperator)op;
      }
    }
    return null;
  }
  
  //composites shouldExecute returns true if all connections are sourced
  //and anything coming into it is hot. WE ALSO PIGGYBACK HERE TO SET INTERNAL
  //RECEIVE PORTS HOT. To keep this method inert, we could let receive handle
  //that internallyby querying its parent. Avoiding that for now cause it seems 
  //like unnecessary indirection
  @Override
  boolean shouldExecute(){
    
    //don't allow execution if we are missing inputs
    if (!inPorksFull()){ return false; }
    
    boolean hotInput = false;
    //if any data is hot, we should execute
    for (InPork i : ins){
      if (i.getSource().getHot()){
        hotInput = true;
        getReceiver().outs.get(i.index).setHot(true);
      }
    }
    
    return hotInput;
  }
  
  //evaluate all ops in order, then set all internal ports cold
  void execute(){
    for (Operator op : evaluationSequence){
      //println(op.name);
      op.evaluate();       
    }
    for (Operator op : evaluationSequence){
      op.setPortsCold();       
    }
  }
  
  //internal SendOperator sets all of the enclosing composite ports hot, as necessary
  //here we just handle the speaking flag, which currently is only used to color ports
  //should remove
  @Override
  void postEvaluation(boolean executed){
    
    //this resets ports that coordinate where new data appears
    //at each scope
    for (OutPork o : outs){ o.speaking = false; }
    for (InPork i : ins){ i.speaking = false; }
      
  }
  
  void primerContinousUpdaters(){
    for (Operator op : kids){
      if (op.continuous){
        
        if (op instanceof PrimeOperator){
          op.outs.get(0).dataNotification();     //assumes continuous prime ops send data to output zero
        }
        
        else {
          ((CompositeOperator)op).primerContinousUpdaters();
        }
        
      }
    }
  }

  //filters its topoSort by the combined BFS's of any updating OutPork
  void generateEvaluationSequence(){
    evaluationSequence.clear();     
    
    if (updaters.size() == 0){return; } //if nothing is updating we can leave operationOrder empty.

    else {  
      //create an unordered list of all objects that need to operate
      Set<Operator> neededOps = new HashSet<>(); 
      
      for (UpdateObject uo : updaters){
        
        // ~~ updater is a specific port ~~//
        if (uo.out != null){
          //add whatever operator is updating
          neededOps.add(uo.out.owner);
          
          //add any operator reachable from that pork
          for (Operator op : graph.reachableOps(uo.out)){
            neededOps.add(op);
          }
        }
        
        
        //~~ updater is an Operator with no designated port ~~//
        else {
          neededOps.add(uo.op);
        }
      }
      
      //filter topoSort by this list.
      for (Operator op : graph.topoSort){
        if (neededOps.contains(op)){
          evaluationSequence.add(op);
          
          //if we run into a composite, generate its sequence as well
          if (op instanceof CompositeOperator){
            ((CompositeOperator)op).generateEvaluationSequence();
          }
          
        }
      }
    }

    updaters.clear();   
  }
  
  boolean isSpeaker() { return true; }
  boolean isListener() { return true; }
  
  //InPork where is the input of the composite that is receiving new data.
  //it calls notify listeners at the appropriate PortUI of its contained receive Op
  void onSpeaking(InPork where){
    if (where != null){
      int whichPort = where.index;
      if (getReceiver() != null){
        getReceiver().outs.get(whichPort).dataNotification();
      }
    } 
  }
  
  void addUpdater(UpdateObject uo){
    
    //typically this is adding an outpork, so each scope knows exactly where its
    //getting new data
    if (!updaters.contains(uo)){
      updaters.add(uo);
    }
    
    //in the case where the update object is an operator with no specified pork, propagate 
    //that info outward. It means there is a graph island that needs to update
    if (uo.op != null){
      if (this != bigbang){
        parent.addUpdater(new UpdateObject(this));
      }
    }
  }
  
  boolean isUpdater(OutPork out){
    return updaters.contains(out);
  }

  void onConnectionAdded(Pork where){
    //resolveType(where); 
  }
  
  //used by a composite to access its corresponding send/receive pork
  //argument should be a pork on this compositeOperator
  Pork getInteriorPair(Pork p){
    if (p instanceof InPork){
      ReceiveOperator rec = getReceiver();
      return rec.outs.get(p.index);
    }
    
    if (p instanceof OutPork){
      SendOperator send = getSender();
      return send.ins.get(p.index);
    }
    
    println("no interior pair found");
    return null;
  }
   
  void onConnectionRemoved(Pork where){}
  
  //jank. have to build a bridge from composite to internal send/receive.
  //typebound and databound pattern binds ports on a single module in a hackish way.
  //Likely should make a more robust data identity manager that ports subscribe to?
  @Override
  void propagateRequiredDataCategory(Pork where, DataCategory dc){
    where.setRequiredDataCategory(dc);
    
    //find corresponding port on send/receive
    Pork p = getInteriorPair(where);
    
    if (p != null){
      p.setRequiredDataCategory(dc);
      
      //propagate not on the send/receive, but what it connects to
      for (Pork po : p.getConnectedPorks()){
       po.owner.propagateRequiredDataCategory(po, dc);  
      }
    }
    
  }
  
  @Override
  void propagateTargetFlow(InPork where, Flow f){
    where.setTargetFlow(f);
    
    //find corresponding port on send/receive
    OutPork p = (OutPork)getInteriorPair(where);
    
    p.setTargetFlow(f);
    
    //propagate not on the send/receive, but what it connects to
    for (InPork po : p.getDestinations()){
      po.owner.propagateTargetFlow(po, f);  
    }
  }
  
  @Override
  void propagateNullFlow(InPork where){
    where.setTargetFlow(null);
    
    //find corresponding port on send/receive
    OutPork p = (OutPork)getInteriorPair(where);
    
    p.setTargetFlow(null);
    
    //propagate not on the send/receive, but what it connects to
    for (InPork po : p.getDestinations()){
      po.owner.propagateNullFlow(po);  
    }
    
  }
  
}
