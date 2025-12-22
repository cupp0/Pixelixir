class SetOperator extends PrimeOperator{  
  
  SetOperator(){
    super();
    name = "set";
  }
  
  void initialize(){
    addInPork(DataCategory.LIST); addInPork(DataCategory.FLOAT); addInPork(DataCategory.UNKNOWN); addOutPork(DataCategory.LIST);
  }
    
  void execute(){ 
    
    //copy data from first input to output
    outs.get(0).data = inFlows.get(0).copyFlow();
   
    //get target index from second input
    int index = (int)inFlows.get(1).getFloatValue();
    
    //set list at target to the Flow value of the third input
    outs.get(0).data.setListAtIndex(index, inFlows.get(2).copyFlow());
  } 

}