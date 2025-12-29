class ReceiveOperator extends PrimeOperator implements DynamicPorts{  
  
  ReceiveOperator(){
    super();
    name = "receive"; setExecutionSemantics(ExecutionSemantics.MUTATES);
  }
  
  void initialize(){
    addOutPork(DataCategory.UNKNOWN, false, true);
  }

  @Override
  void evaluate(){
    for (OutPork o : outs){ o.speaking = false; }
  }

  //send/receive are just pass through mutators, routing handled on connection
  void execute(){} 
  
  //receive just built a connection. Do we need to make a port on the enclosing composite?
  //do we need to make a port on the receive?
  void onConnectionAdded(Pork where){
        
    //if we just made a connection that the parent doesn't have, we need to make one
    if (parent.ins.size() <= where.index && parent != bigbang){
      InPork pIn = parent.addInPork(where.getRequiredDataCategory());
      pIn.setDefaultAccess(DataAccess.READWRITE);
      pIn.setCurrentAccess(pIn.getDefaultAccess());
    }

    //if all ins are full, add a new in
    if (outPorksFull()){
      addOutPork(DataCategory.UNKNOWN);      
    }    
  }
  
  //more jank see compositeOperator.propagateRequiredDataCategory for explanation
  @Override
  void propagateRequiredDataCategory(Pork where, DataCategory dc){
    where.setRequiredDataCategory(dc);
    
    if (parent != bigbang){
     
      //find corresponding port on the enclosing composite
      Pork p = parent.ins.get(where.index);      
      p.setRequiredDataCategory(dc);
      
      //propagate not on the composite, but what it connects to
      for (Pork po : p.getConnectedPorks()){
       po.owner.propagateRequiredDataCategory(po, dc);  
      }
      
    }    
  }
  
  void onConnectionRemoved(Pork where){
  }

  boolean isSpeaker() { return true; }
  
}
