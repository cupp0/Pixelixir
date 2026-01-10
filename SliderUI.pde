//~SliderUI
class SliderUI extends DBUI{
  
  SliderUI(){
    super();
    name = "slider"; setSize(new PVector(201, 12));
  }
  
  void display() {
    float sliderValue = getUIPayload().getFloatValue();
    PVector sliderRange = ((SliderUIState)state).range.copy();
    float knobPos = getAbsolutePosition().x + map(sliderValue, sliderRange.x, sliderRange.y, 0, size.x);
    rect(getAbsolutePosition().x, getAbsolutePosition().y, size.x, size.y, roundOver);
    fill(150);
    ellipse(knobPos, getAbsolutePosition().y+size.y/2, size.y+3, size.y+3);
    
    textAlign(CENTER, CENTER);
    fill(255);
    text((int)sliderValue, knobPos, getAbsolutePosition().y+size.y/2);
    displayIdentity();
  }
  
  StateChange interaction(HumanEvent e){
    StateMan sm = getWindow().windowMan.stateMan;
     
    if (e.input.action == Action.MOUSE_PRESSED){
      drag(e);
      return new StateChange(StateAction.ADD, InteractionState.DRAGGING_SLIDER, this);
    }        
    
    if (e.input.action == Action.MOUSE_DRAGGED){
      drag(e);
    }
    
    if (e.input.action == Action.MOUSE_RELEASED){
      q();
      return new StateChange(StateAction.REMOVE, InteractionState.DRAGGING_SLIDER, this);
    }
    
    return new StateChange(StateAction.DO_NOTHING);
  }
  
  void drag(HumanEvent e){
    float x = e.xMouse;
    PVector sliderRange = ((SliderUIState)state).range.copy();
    float newValue = round(constrain(map(x, getAbsolutePosition().x, getAbsolutePosition().x+size.x, sliderRange.x, sliderRange.y), sliderRange.x,sliderRange.y));
    state.onLocalEvent(new UIPayload(newValue));
  }
    
}
