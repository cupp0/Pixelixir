class SliderOperator extends UIOperator{
      
  SliderOperator(){
    super();
    name = "slider"; uiPayload = new UIPayload(0f);
  }
  
  void initialize(){
    addOutPork(DataCategory.NUMERIC).setTargetFlow(new Flow(DataCategory.NUMERIC));
  }
  
  void execute(){
   outs.get(0).targetFlow.setFloatValue(uiPayload.getFloatValue());
  }
        
}
