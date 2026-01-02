class ReadOperator extends PrimeOperator{  
  
  String address = "";
  
  ReadOperator(){
    super();
    name = "read";  
  }
  
  void initialize(){
    addInPork(DataType.TEXT); addOutPork(DataType.UNDETERMINED).setTargetFlow(new Flow(DataType.UNDETERMINED));
  }
  
  void execute(){
    String address = ins.get(0).targetFlow.getTextValue(); 
    Flow readData = flowRegistry.readFlow(address);
    
    //if nothing found at this address do nothing
    if (readData == null){ return; }    
        
    //else, copy the data to the output
    outs.get(0).targetFlow.setType(readData.getType());
    Flow.copyData(readData, outs.get(0).targetFlow);
  }
  
}
