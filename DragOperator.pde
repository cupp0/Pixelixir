class DragOperator extends PrimeOperator {
  
  DragOperator(){
    super();
    name = "drag";
  }
  
  void initialize(){    
    addInPork(DataCategory.MODULE);
    addInPork(DataCategory.FLOAT);
    addInPork(DataCategory.FLOAT);
  }
  
  void execute(){
    if (ins.get(0).targetFlow.getModuleValue() != null){
      Module m = getModule(ins.get(0).targetFlow.getModuleValue());
      
      if (m != null){
        //limit max drag, if we put a too big number in, we break the tessellator!
        float x = constrain(ins.get(1).targetFlow.getFloatValue(), -50, 50);
        float y = constrain(ins.get(2).targetFlow.getFloatValue(), -50, 50);
        if (Float.isNaN(x)) x = 0;
        if (Float.isNaN(y)) y = 0;
        m.drag(new PVector(x, y));
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
