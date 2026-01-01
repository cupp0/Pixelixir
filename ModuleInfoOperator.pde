class ModuleListOperator extends PrimeOperator{
   
  ModuleListOperator(){
    super();
    name = "moduleList"; 
  }
  
  void initialize(){
    addInPork(DataCategory.WINDOW); addOutPork(DataCategory.LIST).setTargetFlow(new Flow(DataCategory.LIST));
  }

  void execute(){
    outs.get(0).targetFlow.clearList();    
    if (ins.get(0).targetFlow == null){ println("no in flow yo"); return; }
    Window w = windowByBoundaryID.get(ins.get(0).targetFlow.getWindowValue());
    if (w == null){ println("no window yo"); return; }
   
    for (Module m : w.modules){
      outs.get(0).targetFlow.addToList(Flow.ofModule(m.id)); 
    }
  }
  
  ArrayList<Flow> instantiateList(int listSize, DataCategory listType){
    ArrayList<Flow> newList = new ArrayList<Flow>();
    for (int i = 0; i < listSize; i++){
      Flow f = new Flow(listType);
      switch(listType){      
        case NUMERIC:
        f.setFloatValue(0);
        break;
        
        case BOOL:
        f.setBoolValue(false);
        break;
  
        case TEXT:
        f.setTextValue("");
        break;
        
      }
      newList.add(new Flow(listType));
    }
   outs.get(0).targetFlow.setListValue(newList);
    return newList;
  }
}
