class ConstrainOperator extends PrimeOperator{
    
  ConstrainOperator(){
    super();
    name = "constrain";
  }
  
  void initialize(){
    addInPork(DataType.NUMERIC); addInPork(DataType.NUMERIC); addInPork(DataType.NUMERIC);
    addOutPork(DataType.NUMERIC).setTargetFlow(new Flow(DataType.NUMERIC));
  }
  
  void execute(){  
    float i1 = ins.get(0).targetFlow.getFloatValue();
    float i2 = ins.get(1).targetFlow.getFloatValue();
    float i3 = ins.get(2).targetFlow.getFloatValue();
    outs.get(0).targetFlow.setFloatValue(constrain(i1, i2, i3));
  }
  
}
