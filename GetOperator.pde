class GetOperator extends PrimeOperator{  
  
  GetOperator(){
    super();
    name = "get";
  }
  
  void initialize(){
    addInPork(DataCategory.LIST); addInPork(DataCategory.NUMERIC); addOutPork(DataCategory.UNDETERMINED).setTargetFlow(new Flow(DataCategory.UNDETERMINED));
  }
    
  void execute(){ 

    List<Flow> flowList = ins.get(0).targetFlow.getListValue();
    
    //get target index from second input
    int index = (int)ins.get(1).targetFlow.getFloatValue();
    if (index < 0 || index >= flowList.size()) return;
    
    outs.get(0).setCurrentDataCategory(flowList.get(index).getType());
    Flow.copyData(flowList.get(index), outs.get(0).targetFlow);
    
  } 

}
