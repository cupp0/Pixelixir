//~Operator

public abstract class Operator{
  
  protected OperatorListener listener; //module that needs to react to changes to this operator
  
  String name;
  String text = "";
  String expSymbol;
  int lastEval = 0;
  
  Operator parent;                                                    //how we communicate with what's outside
  ArrayList<Operator> kids = new ArrayList<Operator>();               //define this' behavior
  ArrayList<InPork> ins = new ArrayList<InPork>();                    //where we point for input data
  ArrayList<OutPork> outs = new ArrayList<OutPork>();                 //where we put output data
  ArrayList<Flow> inFlows = new ArrayList<>();                        //data at the inports
  Graph graph = new Graph();                                          //the graph that kids are in, not the one this is in
  ArrayList<Operator> evaluationSequence = new ArrayList<Operator>(); //derived from toposort of graph. 

  Operator(){
  }
  
  abstract void initialize();
     
  //add a kid to this composite operator. have to check if its a send/receive so we can add ins/outs to
  //the composite op
  void addKid(Operator what){
    what.setParent(this);
    kids.add(what);
    
    if (what instanceof SendOperator){
      for (InPork i : what.ins){
        this.addOutPork(i.data.getType());
      }
    }
    if (what instanceof ReceiveOperator){
      for (OutPork o : what.outs){
        this.addInPork(o.data.getType());
      }
    }
  }
  
  //composites have some edge cases that shouldn't break anything, 
  //but we should eventually override.
  boolean shouldExecute(){
    
    //here, we check if any inports have hot (recently updated) data.
    //in the case of speakers (sources, generators), these should always
    //execute as their "hot" inports come from user interaction typically
    if (isSpeaker()){
      return true;
    }
    
    //if any data is hot, we should execute
    for (InPork i : ins){
      if (i.getSource() != null){
        if (i.getSource().data.getHot()){
          return true;
        }
      }
    }
    
    //if there are no hot ins, don't execute
    return false;
  }
  
  abstract void execute();
  
  void evaluate(){
    populateInFlows();
    if (shouldExecute()){
      execute();
      //println(frameCount + " " + name);
      postEvaluation(true);
    } else {
      postEvaluation(false);
    }
  }
  
  //composites also have some edge cases here.
  void postEvaluation(boolean executed){
    
    //this resets ports that coordinate where new data appears
    //at each scope
    for (OutPork o : outs){ o.speaking = false; }
    for (InPork i : ins){ i.speaking = false; }
      
    //this updates outs that dynamically affect evaluation
    //at "runtime" (mid evaluation sequence)
    if (executed){
      lastEval = frameCount;
      for (OutPork o : outs){
        o.data.setHot(true);
      }
    } else {
      for (OutPork o : outs){
        o.data.setHot(false);
      }
    }
    
    //we've done what we need with the inputs, set to cold
    for (InPork i : ins){
     i.data.setHot(false); 
    }
    
  }
  
  //copy data from upstream porks
  void populateInFlows(){
    inFlows.clear();
    for (InPork i : ins){
      if (i.getSource() != null){
        inFlows.add(i.getSource().data);
      } else {
        inFlows.add(i.data);
      }
    }
  }
       
  void rebuildListeners() {
    List<Operator> sorted = graph.getTopoSort();
    
    // clear previous listener links
    for (Operator op : sorted) {
      for (OutPork out : op.outs) out.clearListeners();
    }
  
    // connect speakers to reachable listeners
    for (Operator op : sorted) {
      if (op.isSpeaker()){
        for (OutPork out : op.outs){
          Set<InPork> reachableIns = graph.reachablePorks(out);
          for (InPork in : reachableIns){
            if (in.owner.isListener()){
              out.addListener(in);
            }
          }
        }
      }
    }
  }
  
  void setListener(Module m){
    listener = m;
  }

  void onConnection(Pork p){}

  InPork addInPork(DataCategory dc){
    InPork in = new InPork(this, ins.size());
    in.data = new Flow(dc);
    ins.add(in);
    if (listener != null){
      listener.onPorkAdded(in);
    }
    return in;
  }
  
  OutPork addOutPork(DataCategory dc){
    OutPork out = new OutPork(this, outs.size());
    out.data = new Flow(dc);
    outs.add(out);
    if (listener != null){
      listener.onPorkAdded(out);
    }  
    return out;
  }
  
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
  
  //this is to access the module by the operator
  Module getModule(){
    //the parent of this operator is the boundary in which we can view this operator
    Window whichWin = windows.get(parent);

    for (Module m : whichWin.modules){
      if (m.owner == this){
        return m;
      }
    }
    return null;
  }
  
  String getAddress(){
    return this.toString().substring(this.toString().indexOf('@'));
  }
    
  void setParent(Operator o){
    parent = o;
  }
  
  void onKeyPressed(){}
  
  boolean isSpeaker() { return false; }
  boolean isListener() { return false; }
  
  boolean containsSend(){
    for (Operator op : kids){
      if (op.name.equals("send")){
        return true;
      }
    }
    return false;
  }
  
  boolean containsReceive(){
    for (Operator op : kids){
      if (op.name.equals("receive")){
        return true;
      }
    }
    return false;
  }
  
  boolean containsKid(Operator op){
    return kids.contains(op);
  }
  
  //this method assumes that any Primitive Operator with an UNKNOWN data category at a port
  //will resolve all UNKNOWN ports the same way. It will then propagate that type either 
  //direction as necessary
  void resolvePorkDataType(Pork where, DataCategory dc){
    
    where.data.setType(dc);
    //println("resolving from " + name);
    
    for (InPork i : ins){
      if (i.data.getType() == DataCategory.UNKNOWN){
        i.data.setType(dc);       
      }
      
      //propagate up
      if (i.getSource() != null){
        if (i.getSource().data.getType() == DataCategory.UNKNOWN){
          resolvePorkDataType(i.getSource(), dc);
        }
      }
    }
    
    for (OutPork o : outs){
      if (o.data.getType() == DataCategory.UNKNOWN){
        o.data.setType(dc);        
      }
      //propagate down
      for (InPork i : o.getDestinations()){
        if (i.data.getType() == DataCategory.UNKNOWN){
          i.owner.resolvePorkDataType(i, dc);
        }
      }
    }
  }
  
  void addUpdater(UpdateObject uo){}
  void onSpeaking(InPork where){}
  
} 