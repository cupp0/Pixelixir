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
  
  StateChange interaction(HumanEvent e){
    
    if(e.input.action == Action.MOUSE_PRESSED){
      state.onLocalEvent(new UIPayload(true));
      return new StateChange(StateAction.ADD, InteractionState.HOLDING_BUTTON, this); 
    }
    
    if(e.input.action == Action.MOUSE_RELEASED){
      state.onLocalEvent(new UIPayload(false));
      return new StateChange(StateAction.REMOVE, InteractionState.HOLDING_BUTTON, this); 
    }
    
    return new StateChange(StateAction.DO_NOTHING);
  }

}
