//this is all of the shared behavior between SendOperator and ReceiveOperator
abstract class IOOperator extends PrimeOperator implements DynamicPorks{
  
  void initialize(){ addBoundPair(); }
  
  //send and receive call this then hide whichever port they need to
  void addBoundPair(){
    EnumSet<DataAccess> readOrWrite = EnumSet.of(DataAccess.READONLY, DataAccess.READWRITE);
    
    InPork i = addInPork(DataType.UNDETERMINED);    
    OutPork o = addOutPork(DataType.UNDETERMINED);
    
    i.setAllowedAccess(readOrWrite);
    o.setAllowedAccess(readOrWrite);
    
    initializeTypeBinder(i, o);
  }
  
  //pass through mutator
  void execute(){}
  
  //pass through the data status of whatever is upstream
  void postExecution(){
    for (OutPork o : outs){
      if (ins.get(o.index).getSource() == null) continue;
      o.setDataStatus(ins.get(o.index).getSource().getDataStatus());       
    }
  }
  
  //send and receive are the only Ops that can have multiple mutation pathways.
  //every other Op that can mutate does so exclusively through in1 and out1.
  //Send/Receive are just passthrough, so we have to build a parallel mutation bridge
  //thingy
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
  
  void addCanonicalPork(){
    addBoundPair();  
    ((Module)listener).getWindow().registerPorts((Module)listener);
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
  
  boolean isInputDynamic(){ return true; }
  boolean isOutputDynamic(){ return true; }

}
