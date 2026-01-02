class TextfieldOperator extends UIOperator{

  TextfieldOperator(){
    super();
    name = "textfield"; uiPayload = new UIPayload("");
  }
  
  void initialize(){
    addOutPork(DataType.TEXT).setTargetFlow(new Flow(DataType.TEXT));
  }

  void execute(){   
   outs.get(0).targetFlow.setTextValue(uiPayload.getTextValue());
  }
        
}
