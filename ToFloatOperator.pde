//attempts to cast input to a float 
class ToFloatOperator extends PrimeOperator{
  
  ToFloatOperator(){
    super();
    name = "toFloat";
  }
  
  void initialize(){
    addInPork(DataCategory.UNKNOWN); addOutPork(DataCategory.FLOAT);
  }
  
  float valueToFloat(Flow f){
    switch(f.getType()){

      case FLOAT:
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
    outs.get(0).data.setFloatValue(valueToFloat(inFlows.get(0)));   
  } 
}