class ValveOperator extends PrimeOperator{
  
  ValveOperator(){
    super();
    name = "valve";
  }
  
  void initialize(){
    addInPork(DataCategory.UNDETERMINED, true, false); 
    addInPork(DataCategory.BOOL); 
    addOutPork(DataCategory.UNDETERMINED, true, false).setTargetFlow(new Flow(DataCategory.UNDETERMINED));
  }
  
  void execute(){    
    Flow.copyData(ins.get(0).targetFlow, outs.get(0).targetFlow);
  }

  @Override
  boolean shouldExecute(){
    if (!inPorksFull()){
      return false;
    }
    return ins.get(1).targetFlow.getBoolValue();
  }
  
  boolean isSpeaker(){ return true; }
  
  boolean isContinuous(){ return true; }
  
}
