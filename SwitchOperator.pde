class SwitchOperator extends UIOperator{
    
  SwitchOperator(){
    super();
    name = "switch"; uiPayload = new UIPayload(false);
  }
  
  void initialize(){
    addOutPork(DataType.BOOL).setTargetFlow(new Flow(DataType.BOOL));
  }
  
  void execute(){
   outs.get(0).targetFlow.setBoolValue(uiPayload.getBoolValue());
  }
        
}
