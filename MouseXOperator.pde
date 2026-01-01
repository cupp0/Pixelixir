class MouseXOperator extends RawInputOperator{
  
  GlobalInputEvent currentEvent;
  
  MouseXOperator(){
    super();
    name = "mouseX";
  }
  
  void initialize(){    
    addOutPork(DataCategory.NUMERIC).setTargetFlow(new Flow(DataCategory.NUMERIC));
  }
  
  //should compare with previous event and trigger data notification on
  //inputs that have changed
  void onGlobalInputEvent(GlobalInputEvent e){
    
    if ((e.action == Action.MOUSE_MOVED || e.action == Action.MOUSE_DRAGGED)){
      outs.get(0).dataNotification();
    }

    currentEvent = e; 
  }
  
  void execute(){
    if (currentEvent != null){
      outs.get(0).targetFlow.setFloatValue(currentEvent.xMouse);
    }
  }
  
  boolean isSpeaker() { return true; }
        
}
