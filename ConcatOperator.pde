class ConcatOperator extends PrimeOperator implements DynamicPorks{  
  
  ConcatOperator(){
    super();
    name = "concat";
  }
  
  void initialize(){
    addInPork(DataType.UNDETERMINED); addOutPork(DataType.LIST).setTargetFlow(new Flow(DataType.LIST));
  }
  
  @Override
  boolean shouldExecute(){
    //if any data is hot, we should execute
    for (InPork i : ins){
      if (i.getSource() != null){
        if (i.getSource().getDataStatus() == DataStatus.HOT){
          return true;
        }
      }
    }
    
    //if there are no hot ins, don't execute
    return false;
  }
  
  void execute(){
    outs.get(0).targetFlow.clearList();
    
    for (int i = 0; i< ins.size(); i++){ 
      if (ins.get(i).getSource() != null){
        Flow in = ins.get(i).targetFlow.copyFlow();
        outs.get(0).targetFlow.addToList(in);
      }    
    }
  }
  
  //index_ tells us which Sender Pork just built a new connection
  void onConnectionAdded(InPork where){ 
    if (inPorksFull()){
      addCanonicalPork();
    }    
  }
  
  void addCanonicalPork(){
    EnumSet<DataAccess> readOnly = EnumSet.of(DataAccess.READONLY);
    InPork i = addInPork(DataType.UNDETERMINED);
    i.setAllowedAccess(readOnly);
    i.setCurrentAccess(DataAccess.NONE);
    ((Module)listener).getWindow().registerPorts((Module)listener);
  }
  
}
