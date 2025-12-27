//send and receive are the linkage between scopes
class SendOperator extends PrimeOperator implements DynamicPorts{  
  
  SendOperator(){
    super();
    name = "send"; setExecutionSemantics(ExecutionSemantics.MUTATES);
  }
  
  void initialize(){
    addInPork(DataCategory.UNKNOWN, false, true);
  }

  //send/receive are passthroughs
  void execute(){
  } 
  
  //InPork where is the input of the send that is receiving new data.
  //it calls notify listeners at the appropriate out of the composite we are in
  void onSpeaking(InPork where){
    int whichPort = where.index;
    if (parent.outs.size() > whichPort){
      parent.outs.get(whichPort).dataNotification();
    } 
  }
  
  //index_ tells us which Sender Pork just built a new connection
  void onConnectionAdded(Pork where){
        
    //if we just made a connection that the parent doesn't have, we need to make one
    if (parent.outs.size() <= where.index){
      OutPork pOut = parent.addOutPork(where.getRequiredDataCategory(), false, true);
     
      //include send pork in corresponding composite pork data identity group
      //and vice versa
      parent.addDataBoundPork(where);
      addDataBoundPork(pOut);
      
    }
    
    //propagate flow if necessary
    if (where.targetFlow != null && parent != bigbang){
      propagateTargetFlow((InPork)where, where.targetFlow);
    }
    
    //if all ins are full, add a new in
    if (inPorksFull()){
      addInPork(DataCategory.UNKNOWN, false, true);      
    }
    
  }
  
  void onConnectionRemoved(Pork where){
  }
  
  boolean isListener() { return true; }

}
