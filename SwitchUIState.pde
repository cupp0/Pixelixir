//~SwitchUIState
class SwitchUIState extends DBUIState{
    
  SwitchUIState() {
    super();
    setData(new UIPayload(false)); 
  }
  
  @Override
  void onLocalEvent(UIPayload p){
    boolean newBool = !data.getBoolValue();
    setData(new UIPayload(newBool));
    identityManager.propagateIdentityEvent(identityToken, this);    
  }
  
  String getType(){ return "switch"; }  
}