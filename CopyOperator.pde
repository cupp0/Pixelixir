class CopyOperator extends PrimeOperator implements DynamicPorts{  
  
  CopyOperator(){
    super();
    name = "copy";
  }
  
  void initialize(){
    addInPork(DataCategory.UNKNOWN);addOutPork(DataCategory.UNKNOWN);
  }
  
  OutPork addOutPork(DataCategory dc){
    OutPork o = super.addOutPork(dc);
    if (parent != null){
      InPork i = parent.addInPork(dc);
      //o.data = i.data;
    }
    return o;
  }

  void execute(){   
    for (int i = 0; i < outs.size(); i++){
      Flow.copyData(inFlows.get(0), outs.get(i).data);
    }
  } 
  
  void onConnectionAdded(Pork where){
    
    //if all outs are in use, add a new out
    boolean full = true;
    for (OutPork o : outs){
      if (o.getDestinations().size() == 0){
        full = false;
      }
    }

    if (full){
      addOutPork(ins.get(0).data.getType());
    }
    
  }
  
  void onConnectionRemoved(Pork where){
  }

}
