//~ButtonUI
class ButtonUI extends DBUI{
        
  ButtonUI(){
    super();
    name = "button"; setSize(new PVector(12, 12));
  }
  
  void display(){
    rect(getAbsolutePosition().x, getAbsolutePosition().y, size.x, size.y, roundOver);
    displayIdentity();
  }
  
  void onInteraction(HumanEvent e){
    boolean pressed = (e.input.action == Action.MOUSE_PRESSED);
    state.onLocalEvent(new UIPayload(pressed));
  }

}
