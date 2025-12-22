class GreaterThanOperator extends PrimeOperator{
 
  GreaterThanOperator(){
    super();name = "greaterThan";expSymbol =  ">";
  }
  
  void initialize(){
    addInPork(DataCategory.FLOAT); addInPork(DataCategory.FLOAT); addOutPork(DataCategory.BOOL);
  }
  
  void execute(){                   
    outs.get(0).data.setBoolValue(inFlows.get(0).getFloatValue() > inFlows.get(1).getFloatValue());
  }
  
}