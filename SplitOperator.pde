class SplitOperator extends PrimeOperator implements DynamicPorks{  
  
  SplitOperator(){
    super();
    name = "split";
  }
  
  void initialize(){
    addInPork(DataCategory.LIST); 
    addOutPork(DataCategory.UNDETERMINED).setTargetFlow(new Flow(DataCategory.UNDETERMINED)); 
    addOutPork(DataCategory.UNDETERMINED).setTargetFlow(new Flow(DataCategory.UNDETERMINED)); 
  }

  void execute(){
    List<Flow> flowList = ins.get(0).targetFlow.getListValue();
    
    while (outs.size() < flowList.size()){
      addCanonicalPork();
    }
    
    for (int i = 0; i< flowList.size(); i++){
      outs.get(i).setCurrentDataCategory(flowList.get(i).getType());
      Flow.copyData(flowList.get(i), outs.get(i).targetFlow);
    }
    
  } 
  
  void addCanonicalPork(){
    addOutPork(DataCategory.UNDETERMINED).setTargetFlow(new Flow(DataCategory.UNDETERMINED));
    ((Module)listener).getWindow().registerPorts((Module)listener);
  }
}
