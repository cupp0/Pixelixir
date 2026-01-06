class ReadOperator extends PrimeOperator{  
  
  String address = "";
  
  ReadOperator(){
    super();
    name = "read";  
  }
  
  void initialize(){
    addInPork(DataType.TEXT); 
    addOutPork(DataType.UNDETERMINED).setTargetFlow(new Flow(DataType.UNDETERMINED));
    
    initializeTypeBinder(outs.get(0));
  }
  
  void execute(){
    String address = ins.get(0).targetFlow.getTextValue(); 
    Flow readData = flowRegistry.readFlow(address);
    
    //if nothing found at this address do nothing
    if (readData == null){ println("nothing to read"); return; }    
    if (readData.getType() != outs.get(0).getCurrentDataType()){
      println("read " + readData.getType() + ", expected " + outs.get(0).getCurrentDataType());
      setExecutionStatus(ExecutionStatus.BADDATA);
      return;
    }
        
    //else, copy the data to the output
    Flow.copyData(readData, outs.get(0).targetFlow);
  }
  
}
