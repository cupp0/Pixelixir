//send and receive are the linkage between scopes
class SendOperator extends IOOperator implements DynamicPorts{  
  
  SendOperator(){
    super();
    name = "send"; setExecutionSemantics(ExecutionSemantics.MUTATES);
  }
  
  void initialize(){
    addInPork(DataCategory.UNKNOWN, false, false);
    addOutPork(DataCategory.UNKNOWN, false, true);  
  }
  
  //index_ tells us which Sender Pork just built a new connection
  @Override
  void onConnectionAdded(Pork where){

    if (inPorksFull()){
      addInPork(DataCategory.UNKNOWN, false, false);
      addOutPork(DataCategory.UNKNOWN, false, true);   
      ((Module)listener).getWindow().registerPorts((Module)listener);
    }
    
    tryExposingHiddenPorts();
    
  }

  
  void onConnectionRemoved(Pork where){
  }

}
