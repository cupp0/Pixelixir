class RemoveOperator extends PrimeOperator{
  
  RemoveOperator(){
    super();
    name = "remove"; setExecutionSemantics(ExecutionSemantics.MUTATES);
  }
  
  void initialize(){
    addInPork(DataType.LIST); 
    addInPork(DataType.NUMERIC); 
    addOutPork(DataType.LIST).setTargetFlow(new Flow(DataType.LIST));
    
    initializeTypeBinder(ins.get(1));
  }
  
  void execute(){    
    List<Flow> flowList = ins.get(0).targetFlow.getListValue();
    outs.get(0).targetFlow.removeFromList((int)ins.get(1).targetFlow.getFloatValue());     
  }  
        
}
