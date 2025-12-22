class TextfieldOperator extends UIOperator{

  TextfieldOperator(){
    super();
    name = "textfield"; uiPayload = new UIPayload("");
  }
  
  void initialize(){
    addOutPork(DataCategory.TEXT);
  }

  void execute(){   
    outs.get(0).data.setTextValue(uiPayload.getTextValue());
  }
        
}