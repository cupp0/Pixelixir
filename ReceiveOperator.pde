class ReceiveOperator extends IOOperator implements DynamicPorks{  
  
  ReceiveOperator(){
    super();
    name = "receive"; setExecutionSemantics(ExecutionSemantics.MUTATES);
  }
  
  void initialize(){
    addInPork(DataCategory.UNKNOWN, false, true);
    addOutPork(DataCategory.UNKNOWN, false, false);  
  }

  //receive just built a connection. Do we need to make a port on the enclosing composite?
  //do we need to make a port on the receive?
  @Override
  void onConnectionAdded(OutPork where){
    //if all outs are full, add a new one
    if (outPorksFull()){
      addCanonicalPork();
    }    
    tryExposingHiddenPorts();
  }

  void addCanonicalPork(){
    addInPork(DataCategory.UNKNOWN, false, true);
    addOutPork(DataCategory.UNKNOWN, false, false);  
    ((Module)listener).getWindow().registerPorts((Module)listener);
  }
  
}
