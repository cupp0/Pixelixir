class ButtonOperator extends UIOperator{

  ButtonOperator(){
    super();
    name = "button"; uiPayload = new UIPayload(false);
  }
  
  void initialize(){
    addOutPork(DataCategory.BOOL).setTargetFlow(new Flow(DataCategory.BOOL));
  }
  
  void execute(){
   outs.get(0).targetFlow.setBoolValue(uiPayload.getBoolValue());
  }
        
}
