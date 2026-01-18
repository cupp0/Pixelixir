class WriteOperator extends PrimeOperator{  
  
  String address = "";
  
  WriteOperator(){
    super();
    name = "write";  
  }
  
  void initialize(){
    addInPork(DataType.TEXT); addInPork(DataType.UNDETERMINED);
    addOutPork(DataType.TEXT).setTargetFlow(new Flow(DataType.TEXT));
    initializeTypeBinder(ins.get(1));
  }
  
  void execute(){
    if (ins.get(0).targetFlow != null && ins.get(1).targetFlow != null){
      address = ins.get(0).targetFlow.getTextValue(); 
      flowRegistry.writeFlow(address, ins.get(1).targetFlow.copyFlow());  //add new flow to registry
    }
    outs.get(0).targetFlow.setTextValue(ins.get(0).targetFlow.getTextValue());
  }
  
}
