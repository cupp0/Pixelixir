//~Operator
enum ExecutionSemantics{
  MUTATES,
  GENERATES
}

public abstract class Operator{
  
  protected OperatorListener listener; //module that needs to react to changes to this operator
  
  String name;
  String label;
  
  ArrayList<InPork> ins = new ArrayList<InPork>();                    //where we point for input data
  ArrayList<OutPork> outs = new ArrayList<OutPork>();                 //where we put output data
  ArrayList<Pork> typeBoundPorks = new ArrayList<Pork>();             //ports that resolve eachother's type
  
  Flow targetFlow;
  ExecutionSemantics executionSemantics;
  
  Operator(){
    setExecutionSemantics(ExecutionSemantics.GENERATES);  //generate by default
  }
  
  abstract void initialize();
  
  //composites have some edge cases that shouldn't break anything, 
  //but we should eventually override.
  
  void setTargetFlow(Flow f){
    targetFlow = f;
  }
  
  Flow getTargetFlow(){
    return targetFlow;
  }
  
  //@overrides - valve,
  boolean shouldExecute(){
    //don't allow execution if we are missing inputs
    if (!inPorksFull()){return false; }
    
    //if it's a speaker (UI generators, valve
    if (isSpeaker()){ return true; }
    
    //if any data is hot, we should execute
    for (InPork i : ins){
      if (i.getSource().getDataStatus() == DataStatus.HOT){
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
      
    //this updates outs that dynamically affect evaluation
    //at "runtime" (mid evaluation sequence)
    if (executed){
      for (OutPork o : outs){
        o.setDataStatus(DataStatus.HOT);
      }
    } else {
      for (OutPork o : outs){
        o.setDataStatus(DataStatus.COLD);
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
  
  
  //defaults. may refactor ports entirely
  InPork addInPork(DataCategory dc){                             
    return addInPork(dc, false, false);        
  }
  
  OutPork addOutPork(DataCategory dc){                             
    return addOutPork(dc, false, false); 
  }
  
  InPork addInPork(DataCategory dc, boolean typeBound, boolean hidden){
    InPork in = new InPork(this, ins.size());                //create the pork
    setPorkSemantics(in, dc, typeBound, hidden);  //store port qualities
    ins.add(in);                                             //store it
    listener.onPorkAdded(in);                                //tell module about changes
    return in;
  }
  
  OutPork addOutPork(DataCategory dc, boolean typeBound, boolean hidden){   
    OutPork out = new OutPork(this, outs.size());             //create the pork
    setPorkSemantics(out, dc, typeBound, hidden);  //store port qualities
    outs.add(out);                                            //store it
    listener.onPorkAdded(out);                                //tell module about changes
    return out;
  }
  
  void setPorkSemantics(Pork p, DataCategory dc, boolean typeBound, boolean hidden){
    
    //what data type does this pork expect
    p.setDefaultDataCategory(dc);
    p.setCurrentDataCategory(p.getDefaultDataCategory());
    
    //is this type bound to the type of any other pork
    if (typeBound){
      typeBoundPorks.add(p); 
    }    
   
    p.setHidden(hidden);

  }

  //always returns a module with Composition.ONE
  Module getModule(){
    return (Module)listener;
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
    
  void setExecutionSemantics(ExecutionSemantics es){
    executionSemantics = es;
  }
  
  ExecutionSemantics getExecutionSemantics(){
    return executionSemantics;
  }
  
  void setPortsCold(){
    for (OutPork o : outs){
      o.setDataStatus(DataStatus.COLD); 
    }
  }
  
  void onConnectionAdded(InPork where){}
  void onConnectionAdded(OutPork where){}
  
  void onKeyPressed(){}
  
  boolean isSpeaker() { return false; }
  boolean isListener() { return false; }
  boolean isContinuous() { return false; }
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
  
  void propagateCurrentDataCategory(Pork where, DataCategory dc){
    where.setCurrentDataCategory(dc);
    if (typeBoundPorks.contains(where)){
      for (Pork p : typeBoundPorks){
        
        //ensure we don't get stuck in a loop
        if (p.getCurrentDataCategory() != dc){
          
          p.setCurrentDataCategory(dc);
          //get all porks connected to any pork we have changd
          for (Pork po : p.getConnectedPorks()){
            po.owner.propagateCurrentDataCategory(po, dc);
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
      p.setCurrentDataCategory(p.getDefaultDataCategory());
    }
  }
  
  //this should only ever set targetFlow of in1 and out1 to f,
  //then propagate down from out1
  void propagateTargetFlow(InPork where, Flow f){
    
    where.setTargetFlow(f);    
    if (!(executionSemantics == ExecutionSemantics.MUTATES)) return; //doesn't need to propagate       
    if (where.index > 0) return;                                     //not the mutation port
    
    OutPork dataBoundPork = outs.get(0);                             //in1 and out1 always the mutation ports
    dataBoundPork.setTargetFlow(f);
    
    for (InPork p : dataBoundPork.getDestinations()){
      p.owner.propagateTargetFlow(p, f);
    }
  
  }
  
  //send and receive hide porks in their UI. use this method to expose
  //any hidden porks in the enclosing module
  void tryExposingHiddenPorts(){
    
    Module encloser = ((Module)listener).parent;
    if (encloser == mama) return; //make sure we are in a composite
    
    for (InPork i : ins){
      if (i.hidden){
        if (!encloser.isExposing(i)){
          i.owner.setDefaultDataAccess();
          encloser.addInPort(i);
          encloser.getWindow().registerPorts(encloser);
          encloser.organizeUI();
        }
      }
    }
    
    for (OutPork o : outs){
      if (o.hidden){
        if (!encloser.isExposing(o)){
          o.owner.setDefaultDataAccess();
          encloser.addOutPort(o);
          encloser.getWindow().registerPorts(encloser);
          encloser.organizeUI();
        }
      }
    }
  }
  
  void addUpdater(UpdateObject uo){}
  void onSpeaking(InPork where){}
  
} 
