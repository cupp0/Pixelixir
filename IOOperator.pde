class IOOperator extends PrimeOperator{
  
  void initialize(){}
  
  void addBoundPair(){
    EnumSet<DataAccess> readOrWrite = EnumSet.of(DataAccess.READONLY, DataAccess.READWRITE);
    
    InPork i =addInPork(DataType.UNDETERMINED);    
    OutPork o = addOutPork(DataType.UNDETERMINED);
    
    i.setAllowedAccess(readOrWrite);
    o.setAllowedAccess(readOrWrite);
    
    initializeTypeBinder(i, o);
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
  
  void execute(){}
  
  //composites also have some edge cases here.
  void postEvaluation(boolean executed){

    //this updates outs that dynamically affect evaluation
    //at "runtime" (mid evaluation sequence)
    if (executed){
      for (InPork i : ins){
        if (i.getSource() != null){
          outs.get(i.index).setDataStatus(i.getSource().getDataStatus());
        }
      }
    }    
  }

  @Override
  void setDefaultDataAccess(){   
    
    EnumSet<DataAccess> readOrWrite = EnumSet.of(DataAccess.READONLY, DataAccess.READWRITE);
    
    for (InPork i : ins){
      i.setAllowedAccess(readOrWrite);
      i.setCurrentAccess(DataAccess.NONE);
    }
    
    for (OutPork o : outs){
      o.setAllowedAccess(readOrWrite);
      o.setCurrentAccess(DataAccess.NONE);
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
