//send and receive are the linkage between scopes
class SendOperator extends PrimeOperator implements DynamicPorts{  
  
  SendOperator(){
    super();
    name = "send"; setExecutionSemantics(ExecutionSemantics.MUTATES);
  }
  
  void initialize(){
    addInPork(DataCategory.UNKNOWN, false, true);
  }
  
  //send overrides typical shouldExecute(), execute(), postExecution scheme.
  //instead, we just set the appropriate ports hot at the enclosing outport
  @Override  
  void evaluate(){
    if (parent == bigbang) return;
    
    for (InPork i : ins){
      if (i.getSource() != null){
        if (i.getSource().getHot()){
          parent.outs.get(i.index).setHot(true);  
        }
      }
    }

  }
  
  void execute(){}
  
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
        
    //if we just made a connection that the parent doesn't have, we need to make one
    if (parent.outs.size() <= where.index){
      OutPork pOut = parent.addOutPork(where.getRequiredDataCategory());
    }
    
    //if all ins are full, add a new in
    if (inPorksFull()){
      addInPork(DataCategory.UNKNOWN);      
    }
    
  }
  
  //more jank see compositeOperator.propagateRequiredDataCategory for explanation
  @Override
  void propagateRequiredDataCategory(Pork where, DataCategory dc){
    where.setRequiredDataCategory(dc);
    
    if (parent == bigbang) return;
     
    //find corresponding port on the enclosing composite
    Pork p = parent.outs.get(where.index);      
    p.setRequiredDataCategory(dc);
    
    //propagate not on the composite, but what it connects to
    for (Pork po : p.getConnectedPorks()){
     po.owner.propagateRequiredDataCategory(po, dc);  
    }
   
  }
  
  @Override
  void propagateTargetFlow(InPork where, Flow f){
    where.setTargetFlow(f);
    
    if (parent == bigbang) return;
    
    //find corresponding port on enclosing composite
    OutPork p = parent.outs.get(where.index);
    
    p.setTargetFlow(f);
    
    //propagate not on the send/receive, but what it connects to
    for (InPork po : p.getDestinations()){
      po.owner.propagateTargetFlow(po, f);  
    }
  }
  
  @Override
  void propagateNullFlow(InPork where){
    where.setTargetFlow(null);
    
    if (parent == bigbang) return;
    
    //find corresponding port on enclosing composite
    OutPork p = parent.outs.get(where.index);
    
    p.setTargetFlow(null);
    
    //propagate not on the send/receive, but what it connects to
    for (InPork po : p.getDestinations()){
      po.owner.propagateNullFlow(po);  
    }
  }
  
  void onConnectionRemoved(Pork where){
  }
  
  boolean isListener() { return true; }

}
