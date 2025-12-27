class RightMouseOperator extends RawInputOperator{
  
  GlobalInputEvent currentEvent;
  
  RightMouseOperator(){
    super();
    name = "rightMouse";
  }
  
  void initialize(){    
    addOutPork(DataCategory.BOOL).setTargetFlow(new Flow(DataCategory.BOOL));
  }
  
  //should compare with previous event and trigger data notification on
  //inputs that have changed
  void onGlobalInputEvent(GlobalInputEvent e){
    
    if ((e.action == Action.MOUSE_PRESSED ||
         e.action == Action.MOUSE_CLICKED ||
         e.action == Action.MOUSE_RELEASED) && 
         e.mouseButt == RIGHT){
      outs.get(0).dataNotification();
    }

    currentEvent = e; 
  }
  
  void execute(){
    if (currentEvent != null){
      if (currentEvent.action == Action.MOUSE_PRESSED || currentEvent.action == Action.MOUSE_DRAGGED){
        outs.get(0).targetFlow.setBoolValue(currentEvent.mouseButt == RIGHT);
      }
      if (currentEvent.action == Action.MOUSE_RELEASED){
        outs.get(0).targetFlow.setBoolValue(false);
      }
      if (currentEvent.action == Action.MOUSE_CLICKED){
        outs.get(0).targetFlow.setBoolValue(false);
      }
    }
  }
  
  boolean isSpeaker() { return true; }
        
}
