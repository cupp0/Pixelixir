class LessThanOperator extends PrimeOperator{
 
  LessThanOperator(){
    super();name = "lessThan";expSymbol =  "<";
  }
  
  void initialize(){
    addInPork(DataCategory.FLOAT); addInPork(DataCategory.FLOAT); addOutPork(DataCategory.BOOL);
  }
  
  void execute(){                   
    outs.get(0).data.setBoolValue(inFlows.get(0).getFloatValue() < inFlows.get(1).getFloatValue());
  }
  
}