class SetOperator extends PrimeOperator{  
  
  SetOperator(){
    super();
    name = "set"; setExecutionSemantics(ExecutionSemantics.MUTATES);
  }
  
  void initialize(){
    addInPork(DataCategory.LIST); addInPork(DataCategory.FLOAT); addInPork(DataCategory.UNKNOWN); 
    addOutPork(DataCategory.LIST);
  }
    
  void execute(){ 
    
    //copy data from first input to output
    outs.get(0).targetFlow = ins.get(0).targetFlow.copyFlow();
   
    //get target index from second input
    int index = (int)ins.get(1).targetFlow.getFloatValue();
    
    //set list at target to the Flow value of the third input
    outs.get(0).targetFlow.setListAtIndex(index, ins.get(2).targetFlow.copyFlow());
  } 

}
