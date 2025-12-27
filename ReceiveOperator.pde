class ReceiveOperator extends PrimeOperator implements DynamicPorts{  
  
  ReceiveOperator(){
    super();
    name = "receive"; setExecutionSemantics(ExecutionSemantics.MUTATES);
  }
  
  void initialize(){
    addOutPork(DataCategory.UNKNOWN, false, true);
  }

  //send/receive are just pass through mutators, routing handled on connection
  void execute(){
  } 
  
  //index_ tells us which Sender Pork just built a new connection
  void onConnectionAdded(Pork where){
        
    //if we just made a connection that the parent doesn't have, we need to make one
    if (parent.ins.size() <= where.index){
      InPork pIn = parent.addInPork(where.getRequiredDataCategory(), false, true);
     
      //include rec pork in corresponding composite pork data identity group
      //and vice versa
      parent.addDataBoundPork(where);
      addDataBoundPork(pIn);      
    }
    
    //propagate Flow if necessary
    if (where.targetFlow != null && parent != bigbang){
      propagateTargetFlow((InPork)where, where.targetFlow);
    }
    
    //if all ins are full, add a new in
    if (outPorksFull()){
      addOutPork(DataCategory.UNKNOWN, false, true);      
    }
    
  }
  
  void onConnectionRemoved(Pork where){
  }

  boolean isSpeaker() { return true; }
  
}
