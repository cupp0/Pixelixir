class ModuleHeightOperator extends PrimeOperator {
  
  ModuleHeightOperator(){
    super();
    name = "moduleHeight";
  }
  
  void initialize(){    
    addInPork(DataType.MODULE);
    addOutPork(DataType.NUMERIC).setTargetFlow(new Flow(DataType.NUMERIC));
  }
  
  void execute(){
    
    if (ins.get(0).targetFlow != null){
      Module m = getModule(ins.get(0).targetFlow.getModuleValue());

      if (m != null){
        float x = m.uiBits.get(0).size.y;
        outs.get(0).targetFlow.setFloatValue(x);
      }
    }
  }
  
  Module getModule(String id){
    for (Window w : windows.values()){
      for (Module m : w.modules){
        if (m.getId() == id){
          return m;
        }
      }
    }
    
    println("module not found");
    return null;
  }
 
}
