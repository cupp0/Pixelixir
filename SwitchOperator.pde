class SwitchOperator extends UIOperator{
    
  SwitchOperator(){
    super();
    name = "switch"; uiPayload = new UIPayload(false);
  }
  
  void initialize(){
    addOutPork(DataCategory.BOOL).setTargetFlow(new Flow(DataCategory.BOOL));
  }
  
  void execute(){
   outs.get(0).targetFlow.setBoolValue(uiPayload.getBoolValue());
  }
        
}
