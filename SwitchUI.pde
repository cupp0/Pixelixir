//~SwitchUI
class SwitchUI extends DBUI{
        
  SwitchUI(){
    super();
    name = "switch"; setSize(new PVector(12, 12));
  }
  
  void display(){
    rect(getAbsolutePosition().x, getAbsolutePosition().y, size.x, size.y, roundOver);
    fill(175);
    if (getUIPayload().getBoolValue()){
      rect(getAbsolutePosition().x, getAbsolutePosition().y, size.x, size.y/2, roundOver);
    } else {
      rect(getAbsolutePosition().x, getAbsolutePosition().y+size.y/2, size.x, size.y/2, 0);
    }
    displayIdentity();
  }
  
  void onInteraction(HumanEvent e){
    boolean pressed = (e.input.action == Action.MOUSE_PRESSED);
    state.onLocalEvent(new UIPayload(pressed));
  }

}
