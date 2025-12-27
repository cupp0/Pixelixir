class ConcatOperator extends PrimeOperator implements DynamicPorts{  
  
  ConcatOperator(){
    super();
    name = "concat";
  }
  
  void initialize(){
    addInPork(DataCategory.UNKNOWN); addInPork(DataCategory.UNKNOWN);addOutPork(DataCategory.LIST).setTargetFlow(new Flow(DataCategory.LIST));
  }

  
  //index_ tells us which Sender Pork just built a new connection
  void onConnectionAdded(Pork where){ 
    //if all ins are full, add a new in
    boolean full = true;
    for (InPork i : ins){
      if (i.getSource() == null){
        full = false;
      }
    }
    
    if (full){
      addInPork(DataCategory.UNKNOWN);      
    }
    
  }
  
  void onConnectionRemoved(Pork where){
  }


  //clearing whole list for now. Would be better if list knew where it was updating an just overwrite that
  void execute(){
   Flow o = outs.get(0).targetFlow;
   o.clearList();
    
    for (int i = 0; i< ins.size(); i++){ 
      if (ins.get(i).getSource() != null){
        Flow in = ins.get(i).targetFlow.copyFlow();
        o.addToList(in);
      }    
    }
  }
  
  //void resolvePorkDataType(Pork where, DataCategory dc){   
  //  where.setRequiredDataCategory(dc);
  //}

}
