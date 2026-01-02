class ButtonOperator extends UIOperator{

  ButtonOperator(){
    super();
    name = "button"; uiPayload = new UIPayload(false);
  }
  
  void initialize(){
    addOutPork(DataType.BOOL).setTargetFlow(new Flow(DataType.BOOL));
  }
  
  void execute(){
   outs.get(0).targetFlow.setBoolValue(uiPayload.getBoolValue());
  }
        
}
