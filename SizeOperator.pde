class SizeOperator extends PrimeOperator{
  
  SizeOperator(){
    super();
    name = "size";
  }
  
  void initialize(){
    addInPork(DataType.LIST); 
    addOutPork(DataType.NUMERIC).setTargetFlow(new Flow(DataType.NUMERIC));
  }
  
  void execute(){    
    outs.get(0).targetFlow.setFloatValue(ins.get(0).targetFlow.getListValue().size());     
  }  
        
}
