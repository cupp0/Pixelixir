class ValveOperator extends PrimeOperator{
  
  ValveOperator(){
    super();
    name = "valve";
  }
  
  void initialize(){
    addInPork(DataType.UNDETERMINED); 
    addInPork(DataType.BOOL); 
    addOutPork(DataType.UNDETERMINED);
    outs.get(0).setTargetFlow(new Flow(DataType.UNDETERMINED));
    
    initializeTypeBinder(ins.get(0), outs.get(0));
  }
  
  void execute(){    
    if (ins.get(0).targetFlow == null) return;
    Flow.copyData(ins.get(0).targetFlow, outs.get(0).targetFlow);
  }

  @Override
  void confirmExecutionStatus(){
    if (ins.get(1).targetFlow.getBoolValue()){
      setExecutionStatus(ExecutionStatus.GO); 
    } else {
      setExecutionStatus(ExecutionStatus.NOGO); 
    }
  }
  
  boolean isSpeaker(){ return true; }
  
  boolean isContinuous(){ return true; }
  
}
