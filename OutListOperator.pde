class OutListOperator extends PrimeOperator{
   
  OutListOperator(){
    super();
    name = "outList"; 
  }
  
  void initialize(){
    addInPork(DataType.MODULE); addOutPork(DataType.LIST).setTargetFlow(new Flow(DataType.LIST));
  }

  void execute(){
    Module m = getModule(ins.get(0).targetFlow.getModuleValue());
    outs.get(0).targetFlow.clearList();    
    if (m == null){ println("no in flow yo"); return; }
   
    for (OutPortUI ui : m.outs){
      outs.get(0).targetFlow.addToList(Flow.ofPort(ui.id)); 
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
