class SliderOperator extends UIOperator{
      
  SliderOperator(){
    super();
    name = "slider"; uiPayload = new UIPayload(0f);
  }
  
  void initialize(){
    addOutPork(DataCategory.FLOAT).setTargetFlow(new Flow(DataCategory.FLOAT));
  }
  
  void execute(){
   outs.get(0).targetFlow.setFloatValue(uiPayload.getFloatValue());
  }
        
}
