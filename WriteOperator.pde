class WriteOperator extends PrimeOperator{  
  
  String address = "";
  
  WriteOperator(){
    super();
    name = "write";  
  }
  
  void initialize(){
    addInPork(DataType.TEXT); addInPork(DataType.UNDETERMINED);
    
    initializeTypeBinder(ins.get(1));
  }
  
  void execute(){
    if (ins.get(0).targetFlow != null && ins.get(1).targetFlow != null){
      address = ins.get(0).targetFlow.getTextValue(); 
      flowRegistry.writeFlow(address, ins.get(1).targetFlow.copyFlow());  //add new flow to registry
    }
  }
  
}
