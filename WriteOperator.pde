class WriteOperator extends PrimeOperator{  
  
  String address = "";
  
  WriteOperator(){
    super();
    name = "write";  
  }
  
  void initialize(){
    addInPork(DataCategory.UNKNOWN); addInPork(DataCategory.TEXT); addInPork(DataCategory.BOOL);
  }
  
  boolean shouldExecute(){
    if (inFlows.get(2).getBoolValue()){
      return true;
    }
    
    return false;
  }
  
  void execute(){
    flowRegistry.removeFlow(address);                  //remove previous entry
    address = inFlows.get(1).getTextValue(); 
    flowRegistry.writeFlow(address, inFlows.get(0));  //add new flow to registry
  }
  
  boolean isListener() { return true; }

}