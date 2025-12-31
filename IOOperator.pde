class IOOperator extends PrimeOperator{
  
  void initialize(){}
  
  @Override
  boolean shouldExecute(){
    //if any data is hot, we should execute
    for (InPork i : ins){
      if (i.getSource() != null){
        if (i.getSource().getHot()){
          return true;
        }
      }
    }
    
    //if there are no hot ins, don't execute
    return false;
  }
  
  void execute(){}
  
  //composites also have some edge cases here.
  void postEvaluation(boolean executed){

    //this updates outs that dynamically affect evaluation
    //at "runtime" (mid evaluation sequence)
    if (executed){
      for (InPork i : ins){
        if (i.getSource() != null){
          outs.get(i.index).setHot(i.getSource().getHot());
        }
      }
    }
    
  }


  @Override
  void setDefaultDataAccess(){    
    for (InPork i : ins){
      if (i.getDefaultAccess() == null){
        i.setDefaultAccess(DataAccess.READWRITE);
        i.setCurrentAccess(i.getDefaultAccess());
      }
    }
  }

  @Override
  void propagateCurrentDataCategory(Pork where, DataCategory dc){
    where.setCurrentDataCategory(dc);
    if (where instanceof InPork){
      outs.get(where.index).setCurrentDataCategory(dc);
      for (Pork p : outs.get(where.index).getConnectedPorks()){
        p.owner.propagateCurrentDataCategory(p, dc);
      }
    }
    if (where instanceof OutPork){
      ins.get(where.index).setCurrentDataCategory(dc);
      for (Pork p : ins.get(where.index).getConnectedPorks()){
        p.owner.propagateCurrentDataCategory(p, dc);
      }
    }
  }
  
  //when we remove a connection, check if our type requirement can
  //get reset. I think this requires a more robust system
  @Override
  void tryResetTypeBoundPorks(){
    for (InPork i : ins){
      if (i.getConnectedPorks().size() == 0 && outs.get(i.index).getConnectedPorks().size() == 0){
        i.setCurrentDataCategory(DataCategory.UNKNOWN);
        outs.get(i.index).setCurrentDataCategory(DataCategory.UNKNOWN);
        i.setCurrentAccess(i.getDefaultAccess());
        outs.get(i.index).setCurrentAccess(outs.get(i.index).getDefaultAccess());
      }
    }
  }
  
  //this should only ever set targetFlow of in1 and out1 to f,
  //then propagate down from out1
  @Override
  void propagateTargetFlow(InPork where, Flow f){
    
    where.setTargetFlow(f);    
    outs.get(where.index).setTargetFlow(f);
    
    for (InPork p : outs.get(where.index).getDestinations()){
      p.owner.propagateTargetFlow(p, f);
    }
  
  }

}
