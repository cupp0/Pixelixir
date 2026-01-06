class AddModuleOperator extends PrimeOperator{
   
  AddModuleOperator(){
    super();
    name = "addModule"; 
  }
  
  void initialize(){
    addInPork(DataType.TEXT); addInPork(DataType.WINDOW); 
    addOutPork(DataType.MODULE).setTargetFlow(new Flow(DataType.MODULE));
  }

  void execute(){
    if (!inputsAreValid())return;
    
    String n = ins.get(0).targetFlow.getTextValue();
    Window w = windowByBoundaryID.get(ins.get(1).targetFlow.getWindowValue());
    w.addModule(n);
  }
  
  boolean inputsAreValid(){

    String n = ins.get(0).targetFlow.getTextValue();
    if (!isAModule(n)) return false;
    if (ins.get(1).targetFlow == null){  return false; }
    Window w = windowByBoundaryID.get(ins.get(1).targetFlow.getWindowValue());
    if (w == null){ return false; }
    
    return true;
  }
  
  boolean isAModule(String s){
    for (String[] st : UIText){
      for (String str : st){
        if (s.equals(str)) return true;  
      }
    }
    
    return false;
  }
  
}
