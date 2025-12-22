class ConcatOperator extends PrimeOperator implements DynamicPorts{  
  
  ConcatOperator(){
    super();
    name = "concat";
  }
  
  void initialize(){
    addInPork(DataCategory.UNKNOWN); addInPork(DataCategory.UNKNOWN);addOutPork(DataCategory.LIST);
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
 
    outs.get(0).data.clearList();
    
    for (int i = 0; i< ins.size(); i++){ 
      if (ins.get(i).getSource() != null){
        outs.get(0).data.addToList(inFlows.get(i).copyFlow());
      }    
    }
  }
  
  void resolvePorkDataType(Pork where, DataCategory dc){   
    where.data.setType(dc);
  }

}