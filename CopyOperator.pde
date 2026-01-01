class CopyOperator extends PrimeOperator implements DynamicPorks{  
  
  CopyOperator(){
    super();
    name = "copy";
  }
  
  void initialize(){
    setPorkSemantics(addInPork(DataCategory.UNDETERMINED));
    addOutPork(DataCategory.UNDETERMINED).setTargetFlow(new Flow(DataCategory.UNDETERMINED));
    setPorkSemantics(outs.get(0));
  }
  
  void setPorkSemantics(Pork p){
    if (p instanceof InPork){
      typeBindings.add(new DataTypeBinder(p));
      return;
    }    
    typeBindings.get(0).addPork(p);
  }

  void execute(){   
    Flow in = ins.get(0).targetFlow;
    for (int i = 0; i < outs.size(); i++){
      Flow o = outs.get(i).targetFlow;
      Flow.copyData(in, o);
    }
  } 
  
  void onConnectionAdded(OutPork where){
    if (outPorksFull()){
      addCanonicalPork();
    }    
  }
  
  void addCanonicalPork(){
    DataCategory dc = typeBindings.get(0).getDC();
    OutPork o = addOutPork(DataCategory.UNDETERMINED);
    o.setTargetFlow(new Flow(DataCategory.UNDETERMINED));
    o.setCurrentDataCategory(dc);
    setPorkSemantics(o);
    ((Module)listener).getWindow().registerPorts((Module)listener);
  }

}
