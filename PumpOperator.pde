class ValveOperator extends PrimeOperator{

  ValveOperator(){
    super();
    name = "valve";  
  }
  
  void initialize(){
    addInPork(DataCategory.UNKNOWN); addInPork(DataCategory.BOOL); addOutPork(DataCategory.UNKNOWN);
  }
  
  void execute(){
    outs.get(0).data = inFlows.get(0).copyFlow();
    outs.get(0).dataNotification();
  }

  @Override
  boolean shouldExecute(){
    return inFlows.get(1).getBoolValue();
  }
  
  boolean isSpeaker(){ return true; }
  
}
