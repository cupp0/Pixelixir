class ReceiveOperator extends PrimeOperator implements DynamicPorts{  
  
  ReceiveOperator(){
    super();
    name = "receive"; setExecutionSemantics(ExecutionSemantics.MUTATES);
  }
  
  void initialize(){
    addOutPork(DataCategory.UNKNOWN, false, true);
  }

  //send/receive are just pass through mutators, routing handled on connection
  void execute(){} 
  
  //receive just built a connection. Do we need to make a port on the enclosing composite?
  //do we need to make a port on the receive?
  void onConnectionAdded(Pork where){
        
    ////if we just made a connection that the parent doesn't have, we need to make one
    //if (parent.ins.size() <= where.index && parent != bigbang){
    //  InPork pIn = parent.addInPork(where.getCurrentDataCategory());
    //  pIn.setDefaultAccess(DataAccess.READWRITE);
    //  pIn.setCurrentAccess(pIn.getDefaultAccess());
    //}

    //if all ins are full, add a new in
    if (outPorksFull()){
      addOutPork(DataCategory.UNKNOWN);      
    }    
  }
  
  void onConnectionRemoved(Pork where){
  }

  boolean isSpeaker() { return true; }
  
}
