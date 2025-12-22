class ListOperator extends PrimeOperator{
    
  int currentSize;
  DataCategory currentDataCategory;
  
  ListOperator(){
    super();
    name = "list"; 
  }
  
  void initialize(){
    addInPork(DataCategory.FLOAT);addInPork(DataCategory.UNKNOWN);addOutPork(DataCategory.LIST);
  }

  void execute(){
    
    if ((int)inFlows.get(0).getFloatValue() != currentSize || inFlows.get(1).getType() != currentDataCategory){
      instantiateList((int)inFlows.get(0).getFloatValue(), inFlows.get(1).getType());
    }
        
  }
  
  ArrayList<Flow> instantiateList(int listSize, DataCategory listType){
    ArrayList<Flow> newList = new ArrayList<Flow>();
    for (int i = 0; i < listSize; i++){
      Flow f = new Flow(listType);
      switch(listType){      
        case FLOAT:
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
    outs.get(0).data.setListValue(newList);
    return newList;
  }
        
}