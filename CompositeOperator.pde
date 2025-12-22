//every operator that is not primitive is a composite operator
class CompositeOperator extends Operator implements DynamicPorts{

  ArrayList<UpdateObject> updaters = new ArrayList<>(); //which porks are providing new data to the window
                                                        //keyed by this operator
  CompositeOperator(){
    super();
    name = "composite";
  }
  
  void initializeWindow(){
    windows.put(this, new Window(this));
  }
  
  void initialize(){}

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
  
  void execute(){
    for (Operator op : evaluationSequence){
      op.evaluate(); 
    }
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
    //thagt info outward. It means there is a graph island that needs to update
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
   
  void onConnectionRemoved(Pork where){}
  
  @Override
  void resolvePorkDataType(Pork where, DataCategory dc){
    
    where.data.setType(dc);
    //println("resolving from comp");
    
    if (where instanceof InPork){
      
      //propagate up
      OutPork src = ((InPork)where).getSource();
      if (src != null){
        if (src.data.getType() == DataCategory.UNKNOWN){
          src.owner.resolvePorkDataType(src, dc);
        }
      }
      
      //propagate down/in
      ReceiveOperator rec = getReceiver();
      if (rec != null){
        if (rec.outs.get(where.index).data.getType() == DataCategory.UNKNOWN){
          rec.resolvePorkDataType(rec.outs.get(where.index), dc);
        }
      }
    }
    
    if (where instanceof OutPork){
      //propagate down
      for (InPork i : ((OutPork)where).getDestinations()){
        if (i.data.getType() == DataCategory.UNKNOWN){
          i.owner.resolvePorkDataType(i, dc);
        }
      }
      
      //propagate up/in
      SendOperator send = getSender();
      if (send != null){
        if (send.ins.get(where.index).data.getType() == DataCategory.UNKNOWN){
          send.resolvePorkDataType(send.ins.get(where.index), dc);
        }
      }
    }
    
  }
  
}