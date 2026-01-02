class SliderOperator extends UIOperator{
      
  SliderOperator(){
    super();
    name = "slider"; uiPayload = new UIPayload(0f);
  }
  
  void initialize(){
    addOutPork(DataType.NUMERIC).setTargetFlow(new Flow(DataType.NUMERIC));
  }
  
  void execute(){
   outs.get(0).targetFlow.setFloatValue(uiPayload.getFloatValue());
  }
        
}
