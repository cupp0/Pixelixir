class SetOperator extends PrimeOperator{  
  
  SetOperator(){
    super();
    name = "set"; setExecutionSemantics(ExecutionSemantics.MUTATES);
  }
  
  void initialize(){
    addInPork(DataType.LIST); addInPork(DataType.NUMERIC); addInPork(DataType.UNDETERMINED); 
    addOutPork(DataType.LIST);
    
    initializeTypeBinder(ins.get(2));
  }
    
  void execute(){ 
 
    //get target index from second input
    int index = (int)ins.get(1).targetFlow.getFloatValue();
    
    //set list at target to the Flow value of the third input
    outs.get(0).targetFlow.setListAtIndex(index, ins.get(2).targetFlow.copyFlow());
  } 

}
