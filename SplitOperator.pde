class SplitOperator extends PrimeOperator implements DynamicPorks{  
  
  SplitOperator(){
    super();
    name = "split";
  }
  
  void initialize(){
    addInPork(DataType.LIST);
    addOutPork(DataType.UNDETERMINED).setTargetFlow(new Flow(DataType.UNDETERMINED));
  }

  void execute(){
    List<Flow> flowList = ins.get(0).targetFlow.getListValue();
    
    while (outs.size() < flowList.size()){
      addCanonicalPork();
    }
    
    for (int i = 0; i< flowList.size(); i++){
      outs.get(i).setCurrentDataType(flowList.get(i).getType());
      Flow.copyData(flowList.get(i), outs.get(i).targetFlow);
    }
    
  } 
  
  void addCanonicalPork(){
    EnumSet<DataAccess> readOrWrite = EnumSet.of(DataAccess.READONLY, DataAccess.READWRITE);
    OutPork o = addOutPork(DataType.UNDETERMINED);
    o.setTargetFlow(new Flow(DataType.UNDETERMINED));
    o.setAllowedAccess(readOrWrite);
    o.setCurrentAccess(DataAccess.NONE);
    ((Module)listener).getWindow().registerPorts((Module)listener);
  }
}
