class SelecterOperator extends PrimeOperator implements DynamicPorks{  
  
  SelecterOperator(){
    super();
    name = "select";
  }
  
  void initialize(){
    addInPork(DataType.UNDETERMINED);
    addOutPork(DataType.UNDETERMINED).setTargetFlow(new Flow(DataType.UNDETERMINED));
    
    initializeTypeBinder(ins.get(0), outs.get(0));
  }
  
  @Override
  boolean validInputConnections(){
    return true;
  }

  void execute(){   
    for (InPork i : ins){
      if (i.getSource() == null) continue;      
      if (i.getSource().getDataStatus() == DataStatus.HOT){
        Flow.copyData(i.targetFlow, outs.get(0).targetFlow);
        return;
      }
    }
  } 
  
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
    DataType dt = typeBindings.get(0).getCurrentType();
    InPork in = addInPork(dt);
    in.setCurrentDataType(dt);
    in.setAllowedAccess(readOnly);
    typeBindings.get(0).addPork(in);
    ((Module)listener).getWindow().registerPorts((Module)listener);
  }
  
  boolean isInputDynamic(){ return true; }
  boolean isOutputDynamic(){ return false; }

}
