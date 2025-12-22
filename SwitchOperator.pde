class SwitchOperator extends UIOperator{
    
  SwitchOperator(){
    super();
    name = "switch"; uiPayload = new UIPayload(false);
  }
  
  void initialize(){
    addOutPork(DataCategory.BOOL);
  }
  
  void execute(){
    outs.get(0).data.setBoolValue(uiPayload.getBoolValue());
  }
        
}