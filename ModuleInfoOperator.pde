class ToModuleOperator extends PrimeOperator{
   ToModuleOperator(){
    super();
    name = "toModule";
  }
  
  void initialize(){
    addInPork(DataCategory.UNKNOWN); 
    addOutPork(DataCategory.MODULE).setTargetFlow(new Flow(DataCategory.MODULE));
  }
  
  void execute(){    
    OperatorListener m = ins.get(0).getSource().owner.getListener();
    String s = ((Module)m).getId();
    outs.get(0).targetFlow.setModuleValue(s);
  }
}
