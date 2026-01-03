//send and receive are the linkage between scopes
class SendOperator extends IOOperator implements DynamicPorks{  
  
  SendOperator(){
    super();
    name = "send"; setExecutionSemantics(ExecutionSemantics.MUTATES);
  }
  
  void initialize(){
    addBoundPair();
  }
  
  void addBoundPair(){
    super.addBoundPair();
    outs.get(outs.size()-1).setHidden(true);
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
    addBoundPair();  
    ((Module)listener).getWindow().registerPorts((Module)listener);
  }
  
  boolean isInputDynamic(){ return true; }
  boolean isOutputDynamic(){ return true; }

}
