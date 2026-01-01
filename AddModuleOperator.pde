class WindowOperator extends PrimeOperator {
  
  WindowOperator(){
    super();
    name = "window";
  }
  
  void initialize(){    
    addOutPork(DataCategory.WINDOW).setTargetFlow(new Flow(DataCategory.WINDOW));
  }
  
  boolean shouldExecute(){ return true; }
  
  void execute(){
    String s = ((Module)listener).parent.id;
    outs.get(0).targetFlow.setWindowValue(s);
  }
  
  boolean isSpeaker(){ return true; } 
 
}
