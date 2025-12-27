class MouseWheelOperator extends RawInputOperator{
  
  GlobalInputEvent currentEvent;
  
  MouseWheelOperator(){
    super();
    name = "mouseWheel";
  }
  
  void initialize(){    
    addOutPork(DataCategory.FLOAT).setTargetFlow(new Flow(DataCategory.FLOAT));
  }
  
  //should compare with previous event and trigger data notification on
  //inputs that have changed
  void onGlobalInputEvent(GlobalInputEvent e){
    
    if (e.action == Action.MOUSE_WHEEL){           
      outs.get(0).dataNotification();
    }

    currentEvent = e; 
  }
  
  void execute(){
    if (currentEvent != null){
      if (currentEvent.action == Action.MOUSE_WHEEL){
        outs.get(0).targetFlow.setFloatValue(currentEvent.wheelDelta);
      }
    }
  }
  
  boolean isSpeaker() { return true; }
        
}
