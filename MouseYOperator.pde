class MouseYOperator extends RawInputOperator{
  
  GlobalInputEvent currentEvent;
  
  MouseYOperator(){
    super();
    name = "mouseY";
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
      outs.get(0).targetFlow.setFloatValue(currentEvent.yMouse);
    }
  }
  
  boolean isSpeaker() { return true; }
        
}
