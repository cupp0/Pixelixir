class SplitOperator extends PrimeOperator{  
  
  SplitOperator(){
    super();
    name = "split";
  }
  
  void initialize(){
    addInPork(DataCategory.LIST); 
    addOutPork(DataCategory.UNKNOWN).setTargetFlow(new Flow(DataCategory.UNKNOWN)); 
    addOutPork(DataCategory.UNKNOWN).setTargetFlow(new Flow(DataCategory.UNKNOWN)); 
  }

  void execute(){
 
    List<Flow> flowList = ins.get(0).targetFlow.getListValue();
    
    while (outs.size() < flowList.size()){
      addOutPork(DataCategory.UNKNOWN).setTargetFlow(new Flow(DataCategory.UNKNOWN)); 
    }
    
    for (int i = 0; i< flowList.size(); i++){
      outs.get(i).setRequiredDataCategory(flowList.get(i).getType());
      Flow.copyData(flowList.get(i), outs.get(i).targetFlow);
    }
    
  } 
  
  void resolvePorkDataType(Pork where, DataCategory dc){  }

}
