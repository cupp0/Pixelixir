//~Operator
enum ExecutionSemantics{
  MUTATES,
  GENERATES
}

public abstract class Operator{
  
  protected OperatorListener listener; //module that needs to react to changes to this operator
  
  String name;
  String label;
  
  ArrayList<InPork> ins = new ArrayList<InPork>();                           //where we point for input data
  ArrayList<OutPork> outs = new ArrayList<OutPork>();                        //where we put output data
  ArrayList<DataTypeBinder> typeBindings = new ArrayList<DataTypeBinder>();  //ports that resolve eachother's type
  
  ExecutionSemantics executionSemantics;
  
  Operator(){
    setExecutionSemantics(ExecutionSemantics.GENERATES);  //generate by default
  }
  
  abstract void initialize();
   
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
  //ValveOperator, for instance, needs to update its output DataType
  void onConnection(Pork p){} 
  
  //defaults. may refactor ports entirely
  InPork addInPork(DataType dt){                             
    InPork in = new InPork(this, ins.size());                //create the pork
    in.setDefaultDataType(dt);
    ins.add(in);                                             //store it
    listener.onPorkAdded(in);                                //tell module about changes
    return in;
  }
  
  OutPork addOutPork(DataType dt){                             
    OutPork out = new OutPork(this, outs.size());             //create the pork
    out.setDefaultDataType(dt);
    outs.add(out);                                            //store it
    listener.onPorkAdded(out);                                //tell module about changes
    return out;
  }
  
  //default data category is local, so we set that in AddPork methods above
  //type bindings are concerned with other porks at the operator level so
  //we have to override in relevant operator classes (valve, copy, I/O).
  void setPorkSemantics(Pork p){ }

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
  boolean isMutating(){
    if (executionSemantics == ExecutionSemantics.GENERATES) return false;
    if (ins.size() == 0) return false;
    return ins.get(0).getCurrentAccess() == DataAccess.READWRITE;
  }
  boolean hasOutput(){ return outs.size() > 0; }
  boolean hasInput(){ return ins.size() > 0; }
  
  //this method returns the typeBinder helper if the supplied pork is part of a binding
  DataTypeBinder isBound(Pork p){
    for (DataTypeBinder dtb : this.typeBindings){
      if (dtb.boundPorks.contains(p)){
        return dtb;
      }
    }
    
    return null;
  }
  
  void setDefaultTypeBindings(){    
  }
  
  //data access is per port
  void setDefaultDataAccess(){
    
    EnumSet<DataAccess> read = EnumSet.of(DataAccess.READONLY);
    EnumSet<DataAccess> readOrWrite = EnumSet.of(DataAccess.READONLY, DataAccess.READWRITE);
    EnumSet<DataAccess> none = EnumSet.of(DataAccess.NONE);
    
    //first input is the designated mutation port   
    if (getExecutionSemantics() == ExecutionSemantics.MUTATES){
      
      //input 1 is the designated mutation port
      ins.get(0).setAllowedAccess(readOrWrite);
      ins.get(0).setCurrentAccess(DataAccess.NONE);
      
      for (int i = 1; i < ins.size(); i++){
        ins.get(i).setAllowedAccess(read);
        ins.get(i).setCurrentAccess(DataAccess.NONE);
      }     
    }
    
    else {
      for (InPork i : ins){
        i.setAllowedAccess(read);
        i.setCurrentAccess(DataAccess.NONE);
      }     
    }
    
    //out edges can always be either read or readwrite. user has to specify readonly
    for (OutPork o : outs){
      o.setAllowedAccess(readOrWrite);
      o.setCurrentAccess(DataAccess.NONE);
    }     

  }
  
  //this method resolves expected type for operators with indeterminite data 
  //for instance, a valve, send/receive, copy, etc.. It also propagates that
  //change down/up stream in the case of chained unresolved types
  void propagateCurrentDataType(Pork where, DataType dt){
    where.setCurrentDataType(dt);
    for (DataTypeBinder dtb : typeBindings){
      if (dtb.getBoundPorks().contains(where)){ 
        
        //ensure we don't get stuck in a loop
        if (dtb.getDataType() != dt){
          dtb.setDataType(dt);
          
          //propagate to all porks connected to any pork we have changed
          for (Pork p : dtb.getBoundPorks()){
            p.owner.propagateCurrentDataType(p, dt);
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
    for (DataTypeBinder dtb : typeBindings){
      boolean reset = true;
      for (Pork p : dtb.getBoundPorks()){
        if (p.getConnectedPorks().size() > 0) reset = false; 
      }
      //if none of the typeBound Porks have a connection, reset.
      if (reset){
        for (Pork p : dtb.getBoundPorks()){
          p.setCurrentDataType(p.getDefaultDataType());
        }
      }
    }    
  }
  
  //after a connection is made, the operator that owns the outpork that just 
  //connected is responsible for resolving any data lifecycle questions 
  //DataAccess, and DataType is already set at this point. if readwrite, propagate. if readonly
  //allocate a new Flow downstream and propagate
  void tryResolveTargetFlow(OutPork src){
    Flow f = src.targetFlow;
    
    for (InPork i : src.getDestinations()){
      //null catch here so we don't try to copy a nothing
      if (f == null){
        i.owner.propagateTargetFlow(i, null); 
        return;
      }
    
      i.owner.propagateTargetFlow(i, f);
    }

  }
  
  //this should only ever set targetFlow of in1 and out1 to f,
  //then propagate down from out1
  void propagateTargetFlow(InPork where, Flow f){
    
    where.setTargetFlow(f);
    
    //if it wants read write, that means dest is a mutation port
    if (where.getCurrentAccess() == DataAccess.READWRITE){
      outs.get(0).setTargetFlow(f);
      tryResolveTargetFlow(outs.get(0));
      return;
    } 
    
    //this code is for mutation ops that are currently read only. That means
    //we need to put a new Flow at its mutation outport
    if (executionSemantics == ExecutionSemantics.MUTATES){
      outs.get(0).setTargetFlow(new Flow(outs.get(0).getCurrentDataType()));
      tryResolveTargetFlow(outs.get(0));
      return;
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
