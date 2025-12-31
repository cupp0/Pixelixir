class CopyOperator extends PrimeOperator implements DynamicPorks{  
  
  CopyOperator(){
    super();
    name = "copy";
  }
  
  void initialize(){
    addInPork(DataCategory.UNKNOWN, true, false);
    addOutPork(DataCategory.UNKNOWN, true, false).setTargetFlow(new Flow(DataCategory.UNKNOWN));
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
    DataCategory dc = ins.get(0).getCurrentDataCategory();
    addOutPork(dc, true, false).setTargetFlow(new Flow(dc));
    ((Module)listener).getWindow().registerPorts((Module)listener);
  }

}
