class ReceiveOperator extends PrimeOperator implements DynamicPorts{  
  
  ReceiveOperator(){
    super();
    name = "receive";
  }
  
  void initialize(){
    addOutPork(DataCategory.UNKNOWN);
  }
  
  OutPork addOutPork(DataCategory dc){
    OutPork o = super.addOutPork(dc);
    if (parent != null){
      InPork i = parent.addInPork(dc);
      //o.data = i.data;
    }
    
    return o;
  }

  //data copied through for now. maybe long term, we have some kind of terminal object per window
  //that handles routing between scopes. Or, just flesh out onConnectionAdded, onConnectionRemoved
  void execute(){
    inFlows.clear();
    for (int i = 0; i < outs.size(); i++){
      if (parent.ins.size() > i){
        if (parent.ins.get(i).getSource() != null){
          inFlows.add(parent.ins.get(i).getSource().data);
        } else {
          inFlows.add(parent.ins.get(i).data);
        }
      }
    }
    
    for (int i = 0; i < outs.size(); i++){
      Flow.copyData(inFlows.get(i), outs.get(i).data);
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
      addOutPork(DataCategory.UNKNOWN);
    }
    
  }
  
  void onConnectionRemoved(Pork where){
  }
  
  @Override
  void resolvePorkDataType(Pork where, DataCategory dc){
    
    where.data.setType(dc);
    //println("resolving from rec");
    
    //propagate up/out
    //parent.listener is only initialized if this send is inside a composite mod, kinda hack
    if (parent.listener != null){
      if (parent.ins.get(where.index).data.getType() == DataCategory.UNKNOWN){
        parent.resolvePorkDataType(parent.ins.get(where.index), dc);     
      }
    }
    
    //propagate down
    for (InPork i : ((OutPork)where).getDestinations()){
      if (i.data.getType() == DataCategory.UNKNOWN){
        i.owner.resolvePorkDataType(i, dc);
      }
    }
    
  }

  boolean isSpeaker() { return true; }
  
}
