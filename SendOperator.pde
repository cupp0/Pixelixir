//send and receive are the linkage between scopes
class SendOperator extends IOOperator implements DynamicPorks{  
  
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
  void onConnectionAdded(InPork where){
    if (inPorksFull()){
      addCanonicalPork();
    }    
    tryExposingHiddenPorts();  
  }
  
  void addCanonicalPork(){
    addInPork(DataCategory.UNKNOWN, false, false);
    addOutPork(DataCategory.UNKNOWN, false, true);   
    ((Module)listener).getWindow().registerPorts((Module)listener);
  }

}
