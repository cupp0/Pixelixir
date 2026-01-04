class AppendOperator extends PrimeOperator{
  
  AppendOperator(){
    super();
    name = "append"; setExecutionSemantics(ExecutionSemantics.MUTATES);
  }
  
  void initialize(){
    addInPork(DataType.LIST); 
    addInPork(DataType.UNDETERMINED); 
    addOutPork(DataType.LIST).setTargetFlow(new Flow(DataType.LIST));
    
    initializeTypeBinder(ins.get(1));
  }
  
  void execute(){    
    List<Flow> flowList = ins.get(0).targetFlow.getListValue();
    outs.get(0).targetFlow.addToList(ins.get(1).targetFlow);     
  }  
        
}
