class TextfieldOperator extends UIOperator{

  TextfieldOperator(){
    super();
    name = "textfield"; uiPayload = new UIPayload("");
  }
  
  void initialize(){
    addOutPork(DataCategory.TEXT).setTargetFlow(new Flow(DataCategory.TEXT));
  }

  void execute(){   
   outs.get(0).targetFlow.setTextValue(uiPayload.getTextValue());
  }
        
}
