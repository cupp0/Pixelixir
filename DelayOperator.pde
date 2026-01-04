class DelayOperator extends PrimeOperator{
  
  private Flow storedFlow = new Flow(DataType.UNDETERMINED);
  
  DelayOperator(){
    super();
    name = "delay";
  }
  
  void initialize(){
    addInPork(DataType.UNDETERMINED);
    addOutPork(DataType.UNDETERMINED).setTargetFlow(new Flow(DataType.UNDETERMINED));

    initializeTypeBinder(ins.get(0), outs.get(0));
  }
  
  void execute(){    
    Flow.copyData(storedFlow, outs.get(0).targetFlow);
    Flow.copyData(ins.get(0).targetFlow, storedFlow);
  }
  
}
