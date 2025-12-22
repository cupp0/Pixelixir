class KeyOperator extends RawInputOperator{
  
  GlobalInputEvent currentEvent;
  
  KeyOperator(){
    super();
    name = "key";
  }
  
  void initialize(){
    addOutPork(DataCategory.TEXT).data.setTextValue(""); 
  }  

  
  //should compare with previous event and trigger data notification on
  //inputs that have changed
  void onGlobalInputEvent(GlobalInputEvent e){
    switch(e.action){
      case KEY_TYPED:
        outs.get(0).dataNotification();
        break;
        
      case KEY_RELEASED:
        outs.get(0).dataNotification();
        break;
    }
      
    currentEvent = e; 
  }
  
  
  
  void execute(){
    if (currentEvent != null){
      if (currentEvent.action == Action.KEY_TYPED){
        outs.get(0).data.setTextValue(str(currentEvent.theKey));
      }
      if (currentEvent.action == Action.KEY_RELEASED){
        outs.get(0).data.setTextValue("");
      }
    }
  }
  
  boolean isSpeaker() { return true; }
        
}