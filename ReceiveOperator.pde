class ReceiveOperator extends IOOperator implements DynamicPorks{  
  
  ReceiveOperator(){
    super();
    name = "receive"; setExecutionSemantics(ExecutionSemantics.MUTATES);
  }
  
  void initialize(){
    addBoundPair();  
  }
  
  void addBoundPair(){
    super.addBoundPair();
    ins.get(outs.size()-1).setHidden(true);
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

  //for any ports w need to add after op initialization. Has to do with when we register 
  //ports with their window. Perhaps we just keep a global portMap? Why not
  void addCanonicalPork(){
    addBoundPair();  
    ((Module)listener).getWindow().registerPorts((Module)listener);
  }
  
  boolean isInputDynamic(){ return true; }
  boolean isOutputDynamic(){ return true; }
  
}
