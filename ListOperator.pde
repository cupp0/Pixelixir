class ListOperator extends PrimeOperator{
    
  int currentSize;
  DataCategory currentDataCategory;
  
  ListOperator(){
    super();
    name = "list"; 
  }
  
  void initialize(){
    addInPork(DataCategory.NUMERIC);addInPork(DataCategory.UNDETERMINED); addOutPork(DataCategory.LIST).setTargetFlow(new Flow(DataCategory.LIST));
  }

  void execute(){
    
    if ((int)ins.get(0).targetFlow.getFloatValue() != currentSize || ins.get(1).getCurrentDataCategory() != currentDataCategory){
      instantiateList((int)ins.get(0).targetFlow.getFloatValue(), ins.get(1).getCurrentDataCategory());
    }
        
  }
  
  ArrayList<Flow> instantiateList(int listSize, DataCategory listType){
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
