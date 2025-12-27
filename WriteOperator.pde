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
    if (ins.get(0).targetFlow != null && ins.get(1).targetFlow != null){
      address = ins.get(0).targetFlow.getTextValue(); 
      flowRegistry.writeFlow(address, ins.get(1).targetFlow);  //add new flow to registry
    }
  }
  
}
