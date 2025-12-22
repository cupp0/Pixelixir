class GetOperator extends PrimeOperator{  
  
  GetOperator(){
    super();
    name = "get";
  }
  
  void initialize(){
    addInPork(DataCategory.LIST); addInPork(DataCategory.FLOAT); addOutPork(DataCategory.UNKNOWN);
  }
    
  void execute(){ 

    //get target index from second input
    int index = (int)inFlows.get(1).getFloatValue();
    
    //get Flow at target index
    if (index >= 0 && inFlows.get(0).getListValue().size() > index){      
      outs.get(0).data = inFlows.get(0).getListValue().get(index).copyFlow();
    }
    
  } 

}