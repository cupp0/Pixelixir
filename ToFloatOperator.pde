//attempts to cast input to a float 
class ToFloatOperator extends PrimeOperator{
  
  ToFloatOperator(){
    super();
    name = "toFloat";
  }
  
  void initialize(){
    addInPork(DataType.UNDETERMINED); addOutPork(DataType.NUMERIC).setTargetFlow(new Flow(DataType.NUMERIC));
  }
  
  float valueToFloat(Flow f){
    switch(f.getType()){

      case NUMERIC:
      return f.getFloatValue();
      
      case BOOL:
      if (f.getBoolValue() == true) return 1;
      return 0;
      
      case TEXT:
      if (f.getTextValue() != null){
        return float(f.getTextValue());
      } else {
        return Float.NaN;
      }
      
      case LIST:
      return  Float.NaN;
      
      default:
      return Float.NaN;
    }
  }
    
  void execute(){ 
   outs.get(0).targetFlow.setFloatValue(valueToFloat(ins.get(0).targetFlow));   
  } 
}
