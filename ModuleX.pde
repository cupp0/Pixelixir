class ModuleXOperator extends PrimeOperator {
  
  ModuleXOperator(){
    super();
    name = "moduleX";
  }
  
  void initialize(){    
    addInPork(DataCategory.MODULE);
    addOutPork(DataCategory.FLOAT).setTargetFlow(new Flow(DataCategory.FLOAT));
  }
  
  void execute(){
    
    if (ins.get(0).targetFlow != null){
      Module m = getModule(ins.get(0).targetFlow.getModuleValue());

      if (m != null){
        float x = m.getWindow().cam.toScreenX(m.getBodyPosition().x);
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
