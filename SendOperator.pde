//send and receive are the linkage between scopes
class SendOperator extends PrimeOperator implements DynamicPorts{  
  
  SendOperator(){
    super();
    name = "send"; setExecutionSemantics(ExecutionSemantics.MUTATES);
  }
  
  void initialize(){
    addInPork(DataCategory.UNKNOWN, false, true);
  }
  
  void execute(){}

  
  //index_ tells us which Sender Pork just built a new connection
  void onConnectionAdded(Pork where){
        
    //if we just made a connection that the parent doesn't have, we need to make one
    //if (parent.outs.size() <= where.index){
    //  OutPork pOut = parent.addOutPork(where.getCurrentDataCategory());
    //}
    
    //if all ins are full, add a new in
    if (inPorksFull()){
      addInPork(DataCategory.UNKNOWN);      
    }
    
  }
  
  void onConnectionRemoved(Pork where){
  }

}
