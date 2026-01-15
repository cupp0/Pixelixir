class ConcatTextOperator extends PrimeOperator implements DynamicPorks{  
  
  ConcatTextOperator(){
    super();
    name = "concatText";
  }
  
  void initialize(){
    addInPork(DataType.TEXT); addOutPork(DataType.TEXT).setTargetFlow(new Flow(DataType.TEXT));
    
  }
  
  @Override
  boolean validInputConnections(){
    return true;
  }
  
  void execute(){
    outs.get(0).targetFlow.setTextValue("");
    
    for (int i = 0; i< ins.size(); i++){ 
      if (ins.get(i).targetFlow != null){
        String s = outs.get(0).targetFlow.getTextValue();
        outs.get(0).targetFlow.setTextValue(s+ins.get(i).targetFlow.getTextValue());
      }    
    }
  }
  
  //index_ tells us which Sender Pork just built a new connection
  void onConnectionAdded(InPork where){ 
    if (inPorksFull()){
      addCanonicalPork();
    }    
  }
  
  void rebuildPorks(int inCount, int outCount){
    while (ins.size() < inCount) addCanonicalPork();
  }
  
  void addCanonicalPork(){
    EnumSet<DataAccess> readOnly = EnumSet.of(DataAccess.READONLY);
    InPork i = addInPork(DataType.TEXT);
    i.setAllowedAccess(readOnly);
    i.setCurrentAccess(DataAccess.NONE);
    ((Module)listener).getWindow().registerPorts((Module)listener);
  }
  
  boolean isInputDynamic(){ return true; }
  boolean isOutputDynamic(){ return false; }
  
}
