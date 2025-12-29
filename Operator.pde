//~Operator
enum ExecutionSemantics{
  MUTATES,
  GENERATES
}

public abstract class Operator{
  
  protected OperatorListener listener; //module that needs to react to changes to this operator
  
  String name;
  String label;
  
  Operator parent;                                                    //how we communicate with what's outside
  ArrayList<Operator> kids = new ArrayList<Operator>();               //define this' behavior
  ArrayList<InPork> ins = new ArrayList<InPork>();                    //where we point for input data
  ArrayList<OutPork> outs = new ArrayList<OutPork>();                 //where we put output data
  ArrayList<Pork> typeBoundPorks = new ArrayList<Pork>();             //ports that resolve eachother's type
  //TypeBoundIdentity tbi = new TypeBoundIdentity();
  ArrayList<Pork> dataBoundPorks = new ArrayList<Pork>();             //ports that resolve eachother's targetFlow
  boolean continuous = false;
  
  Graph graph = new Graph();                                          //the graph that kids are in, not the one this is in
  ArrayList<Operator> evaluationSequence = new ArrayList<Operator>(); //derived from toposort of graph. 
  ExecutionSemantics executionSemantics;
  Flow sourceData;
  
  Operator(){
    setExecutionSemantics(ExecutionSemantics.GENERATES);  //generate by default
  }
  
  abstract void initialize();
     
  //add a kid to this composite operator. have to check if its a send/receive so we can add ins/outs to
  //the composite op
  void addKid(Operator what){
    what.setParent(this);
    kids.add(what);
    
    if (what.continuous){
      this.continuous = true;
    }
  }
  
  //composites have some edge cases that shouldn't break anything, 
  //but we should eventually override.
  
  //@overrides - valve,
  boolean shouldExecute(){
    //don't allow execution if we are missing inputs
    if (!inPorksFull()){return false; }
    
    //if it's a speaker (UI generators, valve
    if (isSpeaker()){if (this != bigbang){ } return true; }
    
    //if any data is hot, we should execute
    for (InPork i : ins){
      if (i.getSource().getHot()){
        if (this != bigbang){;}
        return true;
      }
    }
    
    //if there are no hot ins, don't execute
    return false;
  }
  
  abstract void execute();
  
  void evaluate(){
    if (shouldExecute()){
      execute();  
      if (this != bigbang){ println(name + " executed, frame " + frameCount); }
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
      for (OutPork o : outs){
        o.setHot(true);
      }
    } else {
      for (OutPork o : outs){
        o.setHot(false);
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
  
  OperatorListener getListener(){
    return listener;
  }
  
  //most onConnection stuff is handled directly through ports but some Operators need to know as well
  //ValveOperator, for instance, needs to update its output datacategory
  void onConnection(Pork p){}
  
  
  InPork addInPork(DataCategory dc){
    
    InPork in = new InPork(this, ins.size());        //create the pork
    ins.add(in);                                     //store it
    setPorkSemantics(in, dc, false, false);          //store port qualities
    
    return in;
  }
  
  InPork addInPork(DataCategory dc, boolean typeBound, boolean dataBound){
    
    InPork in = new InPork(this, ins.size());        //create the pork
    ins.add(in);                                     //store it
    setPorkSemantics(in, dc, typeBound, dataBound);  //store port qualities
    
    return in;
  }
  
  OutPork addOutPork(DataCategory dc){
   
    OutPork out = new OutPork(this, outs.size());     //create the pork
    outs.add(out);                                    //store it
    setPorkSemantics(out, dc, false, false);  //store port qualities
    
    return out;
  }
  
  void setPorkSemantics(Pork p, DataCategory dc, boolean typeBound, boolean dataBound){
    
    //what data type does this pork expect
    p.setRequiredDataCategory(dc);
    
    //is this type bound to the type of any other pork
    if (typeBound){
      typeBoundPorks.add(p); 
    }    
    
    //is the data here bound to any other pork. If so, we can include it in both lists
    if (dataBound){
      typeBoundPorks.add(p);
      dataBoundPorks.add(p);
    }
    
    //does the module representing this op need to know about this pork?
    if (listener != null){
      listener.onPorkAdded(p);
    }
  }
  
  OutPork addOutPork(DataCategory dc, boolean typeBound, boolean dataBound){
   
    OutPork out = new OutPork(this, outs.size());     //create the pork
    outs.add(out);                                    //store it
    setPorkSemantics(out, dc, typeBound, dataBound);  //store port qualities
    
    return out;
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
  
  void setLabel(String s){
    label = s;
  }
  
  String getLabel(){
    return label;
  }
    
  void setParent(Operator o){
    parent = o;
  }
  
  void setExecutionSemantics(ExecutionSemantics es){
    executionSemantics = es;
  }
  
  ExecutionSemantics getExecutionSemantics(){
    return executionSemantics;
  }
  
  void setPortsCold(){
    for (OutPork o : outs){
      o.setHot(false); 
    }
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
  
  boolean inPorksFull(){
    for (InPork i : ins){
      if (i.getSource() == null) return false; 
    }
    return true;
  }
  
  boolean outPorksFull(){
    for (OutPork o : outs){
      if (o.getDestinations().size() == 0) return false; 
    }
    return true;
  }
  
  void addTypeBoundPork(Pork p){
    typeBoundPorks.add(p);
  }
  
  void addDataBoundPork(Pork p){
    dataBoundPorks.add(p); 
  }
  
  //by default, generators allow READWRITE or READ connections 
  //MUTATORS require a READWRITE edge at input 1
  void setDefaultDataAccess(){
    
    //first input is the designated continuation port
    if (getExecutionSemantics() == ExecutionSemantics.MUTATES){
      if (ins.size() > 0){
        ins.get(0).setDefaultAccess(DataAccess.READWRITE);
        ins.get(0).setCurrentAccess(ins.get(0).getDefaultAccess());
      }
    }
  }
  
  //this method resolves expected type for operators with indeterminite data 
  //for instance, a valve, send/receive, copy, etc..
  
  void propagateRequiredDataCategory(Pork where, DataCategory dc){
    where.setRequiredDataCategory(dc);
    if (typeBoundPorks.contains(where)){
      for (Pork p : typeBoundPorks){
        
        //ensure we don't get stuck in a loop
        if (p.getRequiredDataCategory() != dc){
          
          p.setRequiredDataCategory(dc);
          //get all porks connected to any pork we have changd
          for (Pork po : p.getConnectedPorks()){
            po.owner.propagateRequiredDataCategory(po, dc);
          }
        }
      }
    }
    
  }
  
  //when we remove a connection, check if our type requirement can
  //get reset. I think this requires a more robust system
  void tryResetTypeBoundPorks(){
    //if anything is still connected, leave type requirement.
    //there are situations where we ~could~ reset the type requirement
    //even if there are still connections, but that shouldn't
    //result in "bad" behavior per se.
    for (Pork p : typeBoundPorks){
      if (p.getConnectedPorks().size() > 0){ return; }
    }
    
    //if none of the typeBound Porks have a connection, reset.
    for (Pork p : typeBoundPorks){
      p.setRequiredDataCategory(DataCategory.UNKNOWN);
    }
  }
  
  //flow should only propagate if we are in an Op that MUTATES
  void propagateTargetFlow(InPork where, Flow f){
    where.setTargetFlow(f);
    
    if (dataBoundPorks.contains(where)){
      for (Pork p : dataBoundPorks){
        
        //ensure we don't get stuck in a loop
        if (p.targetFlow != f){
          
          //ensure required data type is the same before setting
          if (p.getRequiredDataCategory() != f.getType()){
            p.setRequiredDataCategory(f.getType());
          }
          
          p.setTargetFlow(f);
          //get all porks connected to any pork we have changd
          //we should only get here for outs.get(0) so we'll cast
          for (Pork po : p.getConnectedPorks()){
            po.owner.propagateTargetFlow((InPork)po, f);
          }
        }
      }
    }    
  }
  
  void propagateNullFlow(InPork where){
    where.setTargetFlow(null);
    
    if (dataBoundPorks.contains(where)){
      for (Pork p : dataBoundPorks){
        
        //ensure we don't get stuck in a loop
        if (p.targetFlow != null){
          
          p.setTargetFlow(null);
          
          //get all porks connected to any pork we have changd
          //we should only get here for outs so we'll cast
          for (Pork po : p.getConnectedPorks()){
            po.owner.propagateNullFlow((InPork)po);
          }
        }
      }
    }
    
  }
  
  void addUpdater(UpdateObject uo){}
  void onSpeaking(InPork where){}
  
} 
