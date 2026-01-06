class ConcatOperator extends PrimeOperator implements DynamicPorks{  
  
  ConcatOperator(){
    super();
    name = "concat";
  }
  
  void initialize(){
    addInPork(DataType.UNDETERMINED); addOutPork(DataType.LIST).setTargetFlow(new Flow(DataType.LIST));
    
    initializeTypeBinder(ins.get(0));
  }
  
  @Override
  boolean validInputConnections(){
    return true;
  }
  
  void execute(){
    outs.get(0).targetFlow.clearList();
    
    for (int i = 0; i< ins.size(); i++){ 
      if (ins.get(i).getSource() != null){
        Flow in = ins.get(i).targetFlow.copyFlow();
        outs.get(0).targetFlow.addToList(in);
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
    InPork i = addInPork(DataType.UNDETERMINED);
    i.setAllowedAccess(readOnly);
    i.setCurrentAccess(DataAccess.NONE);
    initializeTypeBinder(i);
    ((Module)listener).getWindow().registerPorts((Module)listener);
  }
  
  boolean isInputDynamic(){ return true; }
  boolean isOutputDynamic(){ return false; }
  
}
