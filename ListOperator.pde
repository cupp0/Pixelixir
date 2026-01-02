class ListOperator extends PrimeOperator{
    
  int currentSize;
  DataType currentDataType;
  
  ListOperator(){
    super();
    name = "list"; 
  }
  
  void initialize(){
    addInPork(DataType.NUMERIC);addInPork(DataType.UNDETERMINED); addOutPork(DataType.LIST).setTargetFlow(new Flow(DataType.LIST));
  }

  void execute(){
    
    if ((int)ins.get(0).targetFlow.getFloatValue() != currentSize || ins.get(1).getCurrentDataType() != currentDataType){
      instantiateList((int)ins.get(0).targetFlow.getFloatValue(), ins.get(1).getCurrentDataType());
    }
        
  }
  
  ArrayList<Flow> instantiateList(int listSize, DataType listType){
    ArrayList<Flow> newList = new ArrayList<Flow>();
    for (int i = 0; i < listSize; i++){
      Flow f = new Flow(listType);
      switch(listType){      
        case NUMERIC:
        f.setFloatValue(0);
        break;
        
        case BOOL:
        f.setBoolValue(false);
        break;
  
        case TEXT:
        f.setTextValue("");
        break;
        
      }
      newList.add(new Flow(listType));
    }
   outs.get(0).targetFlow.setListValue(newList);
    return newList;
  }
        
}
