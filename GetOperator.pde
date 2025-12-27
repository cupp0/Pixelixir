class GetOperator extends PrimeOperator{  
  
  GetOperator(){
    super();
    name = "get";
  }
  
  void initialize(){
    addInPork(DataCategory.LIST); addInPork(DataCategory.FLOAT); addOutPork(DataCategory.UNKNOWN).setTargetFlow(new Flow(DataCategory.UNKNOWN));
  }
    
  void execute(){ 

    //get target index from second input
    int index = (int)ins.get(1).targetFlow.getFloatValue();
    
    //get Flow at target index
    if (index >= 0 && ins.get(0).targetFlow.getListValue().size() > index){      
     outs.get(0).targetFlow = ins.get(0).targetFlow.getListValue().get(index).copyFlow();
    }
    
  } 

}
