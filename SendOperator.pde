//send and receive are the linkage between scopes
class SendOperator extends PrimeOperator implements DynamicPorts{  
  
  SendOperator(){
    super();
    name = "send";
  }
  
  void initialize(){
    addInPork(DataCategory.UNKNOWN);
  }

  InPork addInPork(DataCategory dc){
    InPork i = super.addInPork(dc);
    if (windows.get(parent.parent) != null){
      OutPork o = parent.addOutPork(DataCategory.UNKNOWN);
      //o.data = i.data;
    }

    return i;
  }

  //data copied through for now. maybe long term, we have some kind of terminal object per window
  //that handles routing between scopes. Or, just flesh out onConnectionAdded, onConnectionRemoved
  void execute(){
    //println("evaluating send " + frameCount);
    
     
    for (int i = 0; i < ins.size(); i++){
      if (parent.outs.size() > i){
        Flow.copyData(inFlows.get(i), parent.outs.get(i).data);
      }
    }
  } 
  
  //InPork where is the input of the send that is receiving new data.
  //it calls notify listeners at the appropriate out of the composite we are in
  void onSpeaking(InPork where){
    int whichPort = where.index;
    if (parent.outs.size() > whichPort){
      parent.outs.get(whichPort).dataNotification();
    } 
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

  @Override
  void resolvePorkDataType(Pork where, DataCategory dc){
    
    where.data.setType(dc);
    //println("resolving from send");
    
    //propagate up
    OutPork src = ((InPork)where).getSource();
    if (src != null){
      if (src.data.getType() == DataCategory.UNKNOWN){
        src.owner.resolvePorkDataType(src, dc);
      }
    }
    
    //propagate down/out
    //parent.listener is only initialized if this send is inside a composite mod, kinda hack
    if (parent.listener != null){
      if (parent.outs.get(where.index).data.getType() == DataCategory.UNKNOWN){
        parent.resolvePorkDataType(parent.outs.get(where.index), dc);     
      }
    }
    
  }
  
  boolean isListener() { return true; }

}
