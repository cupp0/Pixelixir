//Pork is responsible for routing and between operators and storing data
//~Pork

enum DataStatus {
  HOT,
  COLD, 
  BAD
}

abstract class Pork {
  
  final Operator owner;
  int index;
  int lastEval = 0;
  Flow targetFlow;
  DataType defaultDataType;
  DataType currentDataType;
  EnumSet<DataAccess> allowedAccess;
  DataAccess currentAccess = DataAccess.NONE;
  DataStatus dataStatus;
  boolean hidden; 
  
  Pork(Operator owner_, int index_){
    owner = owner_;index = index_;
  }
  
  String getAddress(){
    return this.toString().substring(this.toString().indexOf('@'));
  }
  
  boolean isMutationPort(){
    if (owner.getExecutionSemantics() == ExecutionSemantics.MUTATES){
      return this.index == 0;
    }
    return false;
  }
  
  void setTargetFlow(Flow f){
    targetFlow = f;
    //owner.setTargetFlow(f);
  }
  
  void setCurrentDataType(DataType dt){
    currentDataType = dt;
    if (targetFlow != null){
      targetFlow.setType(dt); 
    }
  }
  
  DataType getCurrentDataType(){
    return currentDataType;
  }
  
  void setDefaultDataType(DataType dt){
    defaultDataType = dt;
    setCurrentDataType(dt);
  }
  
  DataType getDefaultDataType(){
    return defaultDataType;
  }
  
  void setCurrentAccess(DataAccess da){
    currentAccess = da; 
  }
  
  DataAccess getCurrentAccess(){
    return currentAccess; 
  }
  
  void setAllowedAccess(EnumSet<DataAccess> da){
    allowedAccess = da; 
  }
  
  EnumSet<DataAccess> getAllowedAccess(){
    return allowedAccess; 
  }
  
  void setDataStatus(DataStatus ds){
    dataStatus = ds;
    if (ds == DataStatus.HOT) lastEval = frameCount;
  }
  
  DataStatus getDataStatus(){
    return dataStatus;
  }
  
  void setHidden(boolean b){
    hidden = b;
  }
  
  abstract ArrayList<Pork> getConnectedPorks();
  
  abstract boolean elligibleForConnection();
  
  boolean isConnected(){ return getConnectedPorks().size() > 0; }
  
}

//~InPork
class InPork extends Pork {
  
  InPork(Operator owner_, int index_){ 
    super(owner_, index_);
  }
  
  OutPork getSource(){
    return graph.getSource(this);
  }

  
  ArrayList<Pork> getConnectedPorks(){
    ArrayList<Pork> connectedPorks = new ArrayList<Pork>();

    if (this.getSource() != null){
      connectedPorks.add(this.getSource());
    }
    
    return connectedPorks;
  }
  
  boolean elligibleForConnection(){
    return this.getSource() == null;
  }

}

//~OutPork
class OutPork extends Pork {
  
  OutPork(Operator owner_, int index_){
    super(owner_, index_);
  }
  
  ArrayList<InPork> getDestinations(){
    return graph.getDestinations(this);
  }
  
  //we are concerned here with propagating expected data type
  //and, if appropriate, propagating Flow identity
  void onConnection(InPork dest){
    
    DataType srcType = this.getCurrentDataType();
    DataType destType = dest.getCurrentDataType();
    
    //if types disagree, they need resolved
    //the only valid way for a type to disagree is if one is UNDETERMINED
    if (srcType != destType){
      Pork unresolvedPork = (srcType == DataType.UNDETERMINED) ? this : dest;
      DataType resolvedType = (srcType == DataType.UNDETERMINED) ? destType : srcType;
      unresolvedPork.owner.propagateCurrentDataType(unresolvedPork, resolvedType);
    } 
    
    //if targetFlow is not null, we need to propagate the Flow identity
    if (targetFlow != null){
      owner.tryResolveTargetFlow(this);
    }
    
    //ops with dynamic port count need to when when connections are made
    owner.onConnectionAdded(this);
    dest.owner.onConnectionAdded(dest);
    
  }
  
  void onConnectionRemoved(InPork dest){
    
    dest.owner.propagateTargetFlow(dest, null);
    
    owner.tryResetTypeBoundPorks();
    dest.owner.tryResetTypeBoundPorks();
    
    this.setCurrentAccess(DataAccess.NONE);
    dest.setCurrentAccess(DataAccess.NONE);

  }
  

  //these listeners are InPorks that have the capactity to provide new data to a 
  //different window (Composite ins, sends).
  void dataNotification() {    
    graph.addUpdater(this);
  }
  
  boolean elligibleForConnection(){
    
    if (currentAccess == DataAccess.READONLY) return true;
    
    if (currentAccess == DataAccess.READWRITE){
      return getDestinations().size() == 0;
    }
    
    if (currentAccess == DataAccess.NONE) return true;
    
    if (currentAccess == null){println("null access");}
    return false;
  }
  
  ArrayList<Pork> getConnectedPorks(){
    ArrayList<Pork> connectedPorks = new ArrayList<Pork>();
    
    for (InPork i : ((OutPork)this).getDestinations()){
      connectedPorks.add(i);
    }
    
    return connectedPorks;
  }
  
  //used to validate an attempted connection before building it
  DataAccess resolveDataAccess(InPork other, DataAccess attemptedAccess){
    EnumSet<DataAccess> outAccess = this.getAllowedAccess();
    EnumSet<DataAccess> inAccess = other.getAllowedAccess();
    
    if (outAccess.contains(attemptedAccess) && inAccess.contains(attemptedAccess)){
      return attemptedAccess;
    }
    
    return DataAccess.NONE;
    
  }

}
