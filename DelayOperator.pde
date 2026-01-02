class DelayOperator extends PrimeOperator{
  
  private Flow storedFlow = new Flow(DataType.UNDETERMINED);
  
  DelayOperator(){
    super();
    name = "delay";
  }
  
  void initialize(){
    setPorkSemantics(addInPork(DataType.UNDETERMINED));
    addOutPork(DataType.UNDETERMINED).setTargetFlow(new Flow(DataType.UNDETERMINED));
    setPorkSemantics(outs.get(0));
  }
  
  void setPorkSemantics(Pork p){
    if (p instanceof InPork){
      typeBindings.add(new DataTypeBinder(p));
      return;
    }    
    typeBindings.get(0).addPork(p);
  }
  
  void execute(){    
    Flow.copyData(storedFlow, outs.get(0).targetFlow);
    Flow.copyData(ins.get(0).targetFlow, storedFlow);
  }
  
}
