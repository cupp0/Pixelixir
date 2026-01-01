class TimeOperator extends PrimeOperator{
  
  TimeOperator(){
    super();
    name = "time";
  }
  
  void initialize(){
    addOutPork(DataCategory.NUMERIC).setTargetFlow(new Flow(DataCategory.NUMERIC));
  }
  
  void execute(){    
    outs.get(0).targetFlow.setFloatValue(frameCount);
  }
  
  boolean isSpeaker(){ return true; }
  
  boolean isContinuous(){ return true; }
  
}
