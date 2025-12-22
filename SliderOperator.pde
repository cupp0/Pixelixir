class SliderOperator extends UIOperator{
      
  SliderOperator(){
    super();
    name = "slider"; uiPayload = new UIPayload(0f);
  }
  
  void initialize(){
    addOutPork(DataCategory.FLOAT);
  }
  
  void execute(){
    outs.get(0).data.setFloatValue(uiPayload.getFloatValue());
  }
        
}
