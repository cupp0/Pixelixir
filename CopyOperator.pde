class CopyOperator extends PrimeOperator implements DynamicPorks{  
  
  CopyOperator(){
    super();
    name = "copy";
  }
  
  void initialize(){
    addInPork(DataType.UNDETERMINED);
    addOutPork(DataType.UNDETERMINED).setTargetFlow(new Flow(DataType.UNDETERMINED));
    
    initializeTypeBinder(ins.get(0), outs.get(0));
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
  
  void rebuildPorks(int inCount, int outCount){
    while (outs.size() < outCount) addCanonicalPork(); 
  }
  
  void addCanonicalPork(){
    DataType dt = typeBindings.get(0).getCurrentType();
    OutPork o = addOutPork(DataType.UNDETERMINED);
    o.setTargetFlow(new Flow(DataType.UNDETERMINED));
    o.setCurrentDataType(dt);
    typeBindings.get(0).addPork(o);
    ((Module)listener).getWindow().registerPorts((Module)listener);
  }
  
  boolean isInputDynamic(){ return false; }
  boolean isOutputDynamic(){ return true; }

}
