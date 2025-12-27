class ValveOperator extends PrimeOperator{
  
  ValveOperator(){
    super();
    name = "valve"; continuous = true;
  }
  
  void initialize(){
    addInPork(DataCategory.UNKNOWN, true, false); 
    addInPork(DataCategory.BOOL); 
    addOutPork(DataCategory.UNKNOWN, true, false).setTargetFlow(new Flow(DataCategory.UNKNOWN));
  }
  
  void execute(){    
    Flow.copyData(ins.get(0).targetFlow, outs.get(0).targetFlow);
  }

  @Override
  boolean shouldExecute(){
    if (ins.get(1).targetFlow == null){
      return false;
    }
    return ins.get(1).targetFlow.getBoolValue();
  }
  
  boolean isSpeaker(){ return true; }
  
}
