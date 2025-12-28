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
        float x = min(1000, ins.get(1).targetFlow.getFloatValue());
        float y = min(1000, ins.get(2).targetFlow.getFloatValue());
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
