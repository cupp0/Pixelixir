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
    ellipse(knobPos, getAbsolutePosition().y+size.y/2, size.y+3, size.y+3);
    displayIdentity();
  }
  
  void onInteraction(HumanEvent e){
    float x = e.xMouse;
    PVector sliderRange = ((SliderUIState)state).range.copy();
    float newValue = round(constrain(map(x, getAbsolutePosition().x, getAbsolutePosition().x+size.x, sliderRange.x, sliderRange.y), sliderRange.x,sliderRange.y));
    state.onLocalEvent(new UIPayload(newValue));
  }
    
}
