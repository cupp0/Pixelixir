class WriteOperator extends PrimeOperator{  
  
  String address = "";
  
  WriteOperator(){
    super();
    name = "write";  
  }
  
  void initialize(){
    addInPork(DataCategory.TEXT); addInPork(DataCategory.UNKNOWN); 
  }
  
  void execute(){
    address = inFlows.get(0).getTextValue(); 
    flowRegistry.writeFlow(address, inFlows.get(1));  //add new flow to registry
  }
  
}
