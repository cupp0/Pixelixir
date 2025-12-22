//~ButtonUIState
class ButtonUIState extends DBUIState{

  ButtonUIState() {
    super();
    setData(new UIPayload(false)); 
  }

  String getType(){ return "button"; }

}