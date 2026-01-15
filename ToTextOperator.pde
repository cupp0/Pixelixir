//attempts to cast input to a float 
class ToTextOperator extends PrimeOperator{
  
  ToTextOperator(){
    super();
    name = "toText";
  }
  
  void initialize(){
    addInPork(DataType.UNDETERMINED); addOutPork(DataType.TEXT).setTargetFlow(new Flow(DataType.TEXT));
    initializeTypeBinder(ins.get(0));
  }
  
  String valueToText(Flow f){
    switch(f.getType()){

      case NUMERIC:
      return str(f.getFloatValue());
      
      case BOOL:
      if (f.getBoolValue() == true) return "true";
      return "false";
      
      case TEXT:
      if (f.getTextValue() != null){
        return f.getTextValue();
      }
      
      case LIST:
      return  "list";
      
      default:
      return "";
    }
  }
    
  void execute(){ 
   outs.get(0).targetFlow.setTextValue(valueToText(ins.get(0).targetFlow));   
  } 
}
