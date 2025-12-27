class MouseOperator extends RawInputOperator{
  
  GlobalInputEvent currentEvent;
  
  MouseOperator(){
    super();
    name = "mouse";
  }
  
  void initialize(){
    addOutPork(DataCategory.FLOAT).setTargetFlow(new Flow(DataCategory.FLOAT)); addOutPork(DataCategory.FLOAT); //mouse position
    addOutPork(DataCategory.BOOL); addOutPork(DataCategory.BOOL);   //left/right buttons
    addOutPork(DataCategory.FLOAT);                                 //wheel delta
  }
  
  //should compare with previous event and trigger data notification on
  //inputs that have changed
  void onGlobalInputEvent(GlobalInputEvent e){
    switch(e.action){
      case MOUSE_MOVED:
       outs.get(0).dataNotification();
        outs.get(1).dataNotification();
        break;
      
      case MOUSE_DRAGGED:
       outs.get(0).dataNotification();
        outs.get(1).dataNotification();
        break;
      
      case MOUSE_PRESSED:
        if (e.mouseButt == LEFT){
          outs.get(2).dataNotification();
          
        }
        if (e.mouseButt == RIGHT){
          outs.get(3).dataNotification();
        }
        break;
        
      case MOUSE_CLICKED:
        if (e.mouseButt == LEFT){
          outs.get(2).dataNotification();
        }
        if (e.mouseButt == RIGHT){
          outs.get(3).dataNotification();
        }
        break;  
      
      case MOUSE_RELEASED:
        if (e.mouseButt == LEFT){
          outs.get(2).dataNotification();
        }
        if (e.mouseButt == RIGHT){
          outs.get(3).dataNotification();
        }
        break;
      
      case MOUSE_WHEEL:
        outs.get(4).dataNotification();
        break;
    }
    
    currentEvent = e; 
  }
  
  void execute(){
    if (currentEvent != null){
     outs.get(0).targetFlow.setFloatValue(currentEvent.xMouse);
      outs.get(1).targetFlow.setFloatValue(currentEvent.yMouse);
      if (currentEvent.action == Action.MOUSE_PRESSED || currentEvent.action == Action.MOUSE_DRAGGED){
        outs.get(2).targetFlow.setBoolValue(currentEvent.mouseButt == LEFT);
        outs.get(3).targetFlow.setBoolValue(currentEvent.mouseButt == RIGHT);
      }
      if (currentEvent.action == Action.MOUSE_RELEASED){
        outs.get(2).targetFlow.setBoolValue(false);
        outs.get(3).targetFlow.setBoolValue(false);
      }
      if (currentEvent.action == Action.MOUSE_CLICKED){
        outs.get(2).targetFlow.setBoolValue(false);
        outs.get(3).targetFlow.setBoolValue(false);
      }
      outs.get(4).targetFlow.setFloatValue(currentEvent.wheelDelta);
    }
  }
  
  boolean isSpeaker() { return true; }
        
}
