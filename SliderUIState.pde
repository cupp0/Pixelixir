//~SliderUIState
class SliderUIState extends DBUIState{
  
  PVector range = new PVector(-100, 100);
  
  SliderUIState() {
    super();
    setData(new UIPayload(0f));
  }

  String getType(){ return "slider"; }

}