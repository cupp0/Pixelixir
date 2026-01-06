class WindowOperator extends PrimeOperator {
  
  WindowOperator(){
    super();
    name = "window";
  }
  
  void initialize(){    
    addOutPork(DataType.WINDOW).setTargetFlow(new Flow(DataType.WINDOW));
  }
    
  void execute(){
    String s = ((Module)listener).parent.id;
    outs.get(0).targetFlow.setWindowValue(s);
  }
  
  boolean isSpeaker(){ return true; } 
 
}
