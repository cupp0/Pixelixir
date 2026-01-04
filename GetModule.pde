class GetModuleOperator extends PrimeOperator{
   
  GetModuleOperator(){
    super();
    name = "getModule"; 
  }
  
  void initialize(){
    addInPork(DataType.WINDOW); addInPork(DataType.TEXT); 
    addOutPork(DataType.MODULE).setTargetFlow(new Flow(DataType.MODULE));
    
  }

  void execute(){
    Window w = windowByBoundaryID.get(ins.get(0).targetFlow.getWindowValue());
    String s = ins.get(1).targetFlow.getTextValue();

    if (w == null) return;
    
    for (Module m : w.modules){
      if (m.getUserLabel().equals(s)){
        outs.get(0).targetFlow.setModuleValue(m.id);
      }
    }
  }
  
}
