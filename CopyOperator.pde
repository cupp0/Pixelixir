class CopyOperator extends PrimeOperator implements DynamicPorks{  
  
  CopyOperator(){
    super();
    name = "copy";
  }
  
  void initialize(){
    setPorkSemantics(addInPork(DataType.UNDETERMINED));
    addOutPork(DataType.UNDETERMINED).setTargetFlow(new Flow(DataType.UNDETERMINED));
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
    DataType dt = typeBindings.get(0).getDataType();
    OutPork o = addOutPork(DataType.UNDETERMINED);
    o.setTargetFlow(new Flow(DataType.UNDETERMINED));
    o.setCurrentDataType(dt);
    setPorkSemantics(o);
    ((Module)listener).getWindow().registerPorts((Module)listener);
  }

}
