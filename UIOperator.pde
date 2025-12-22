//this will be all Operators that have default databenders
abstract class UIOperator extends PrimeOperator{
  
  UIPayload uiPayload;
  
  UIOperator(){
    super();
  }
  
  void onPayloadChange(UIPayload pl) {
    uiPayload = pl;
    for (OutPork o : outs){
      o.dataNotification();
    }
  }
  
  DataBender getDataBender(){
    for (ModuleUI ui : ((Module)listener).uiBits){
      if (ui.state instanceof DataBender){
        return (DataBender)ui.state;
      }
    }
    
    return null;
  }
  
  boolean isSpeaker() { return true; }
  
}