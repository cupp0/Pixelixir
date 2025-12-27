class GreaterThanOperator extends ComparisonOperator{
 
  GreaterThanOperator(){
    super();name = "greaterThan";expSymbol =  ">";
  }
 
  void execute(){   
    float i1 = ins.get(0).targetFlow.getFloatValue();
    float i2 = ins.get(1).targetFlow.getFloatValue();
    Flow o = outs.get(0).targetFlow;
    o.setBoolValue(i1 > i2);
  }
  
}
