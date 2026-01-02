class ValveOperator extends PrimeOperator{
  
  ValveOperator(){
    super();
    name = "valve";
  }
  
  void initialize(){
    addInPork(DataType.UNDETERMINED); 
    addInPork(DataType.BOOL); 
    addOutPork(DataType.UNDETERMINED);
    setPorkSemantics(ins.get(0));
    setPorkSemantics(outs.get(0));
    outs.get(0).setTargetFlow(new Flow(DataType.UNDETERMINED));
  }
  
  void setPorkSemantics(Pork p){
    if (p instanceof InPork){
      typeBindings.add(new DataTypeBinder(p));
      return;
    }    
    typeBindings.get(0).addPork(p);
  }
  
  void execute(){    
    Flow.copyData(ins.get(0).targetFlow, outs.get(0).targetFlow);
  }

  @Override
  boolean shouldExecute(){
    if (!inPorksFull()){
      return false;
    }
    return ins.get(1).targetFlow.getBoolValue();
  }
  
  boolean isSpeaker(){ return true; }
  
  boolean isContinuous(){ return true; }
  
}
