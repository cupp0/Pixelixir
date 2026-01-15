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
    Flow.copyData(ins.get(0).targetFlow, outs.get(0).targetFlow);
  }


  void confirmExecutionStatus(){
    //sliders, time, 
    if (isSpeaker()){
      setExecutionStatus(ExecutionStatus.GO);
      return;
    }
    
    //if any data is hot, we should execute
    for (InPork i : ins){
      if (i.getSource() == null) continue;      
      if (i.getSource().getDataStatus() == DataStatus.HOT){
        if (ins.get(1).targetFlow.getBoolValue()){
          setExecutionStatus(ExecutionStatus.GO);
          return;
        }
      }
    }
    
    //if we are here, all inputs are valid but the data is cold (ie valve is closed)
    setExecutionStatus(ExecutionStatus.NOGO);
  }
  
}
