class SplitOperator extends PrimeOperator{  
  
  SplitOperator(){
    super();
    name = "split";
  }
  
  void initialize(){
    addInPork(DataCategory.LIST); addOutPork(DataCategory.UNKNOWN); addOutPork(DataCategory.UNKNOWN);
  }

  void execute(){
 
    List<Flow> flowList = inFlows.get(0).getListValue();
    
    while (outs.size() < flowList.size()){
      addOutPork(DataCategory.UNKNOWN);
    }
    
    for (int i = 0; i< flowList.size(); i++){
      outs.get(i).data.setType(flowList.get(i).getType());
      Flow.copyData(flowList.get(i), outs.get(i).data);
    }
    
  } 
  
  void resolvePorkDataType(Pork where, DataCategory dc){  }

}