//Pork is responsible for routing and between operators and storing data
//~Pork
abstract class Pork {
  
  final Operator owner;
  int index;
  Flow targetFlow;
  DataCategory defaultDataCategory;
  DataCategory currentDataCategory;
  DataAccess defaultAccess;
  DataAccess currentAccess;
  boolean hidden; 
  
  Pork(Operator owner_, int index_){
    owner = owner_;index = index_;
  }
  
  String getAddress(){
    return this.toString().substring(this.toString().indexOf('@'));
  }
  
  boolean isMutationPort(){
    if (owner.getExecutionSemantics() == ExecutionSemantics.MUTATES){
      if (index == 0){
        return true;
      }
    }
    return false;
  }
  
  void setTargetFlow(Flow f){
    targetFlow = f;
    owner.setTargetFlow(f);
  }
  
  void setCurrentDataCategory(DataCategory dc){
    currentDataCategory = dc;
    if (targetFlow != null){
      targetFlow.setType(dc); 
    }
  }
  
  DataCategory getCurrentDataCategory(){
    return currentDataCategory;
  }
  
  void setDefaultDataCategory(DataCategory dc){
    defaultDataCategory = dc;
  }
  
  DataCategory getDefaultDataCategory(){
    return defaultDataCategory;
  }
  
  void setCurrentAccess(DataAccess da){
    currentAccess = da; 
  }
  
  DataAccess getCurrentAccess(){
    return currentAccess; 
  }
  
  void setDefaultAccess(DataAccess da){
    defaultAccess = da; 
  }
  
  DataAccess getDefaultAccess(){
    return defaultAccess; 
  }
  
  void setHidden(boolean b){
    hidden = b;
  }
  
  abstract ArrayList<Pork> getConnectedPorks();
  
  abstract boolean elligibleForConnection();
  
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

enum DataStatus {HOT, COLD, BAD}

//~OutPork
class OutPork extends Pork {
  
  DataStatus dataStatus;
  boolean speaking = false;
  int lastEval = 0;
  
  OutPork(Operator owner_, int index_){
    super(owner_, index_);
  }
  
  ArrayList<InPork> getDestinations(){
    return graph.getDestinations(this);
  }
  
  //we are concerned here with propagating expected data category
  //and, if appropriate, propagating Flow identity
  void onConnection(InPork dest){
    DataCategory srcCat = this.getCurrentDataCategory();
    DataCategory destCat = dest.getCurrentDataCategory();
    
    //if types disagree, they need resolved
    //the only valid way for a type to disagree is if one is UNDETERMINED
    if (srcCat != destCat){
      if (srcCat == DataCategory.UNDETERMINED ){
        this.owner.propagateCurrentDataCategory(this, destCat);
      } else {
        dest.owner.propagateCurrentDataCategory(dest, srcCat);
      }
    } 
    
    //if targetFlow is not null, we need to propagate the Flow identity
    if (targetFlow != null){
      dest.owner.propagateTargetFlow(dest, this.targetFlow);
    }
    
    owner.onConnectionAdded(this);
    dest.owner.onConnectionAdded(dest);
    
  }
  
  void onConnectionRemoved(InPork dest){
    
    dest.owner.propagateTargetFlow(dest, null);
    
    owner.tryResetTypeBoundPorks();
    dest.owner.tryResetTypeBoundPorks();
    
    this.setCurrentAccess(this.getDefaultAccess());
    dest.setCurrentAccess(dest.getDefaultAccess());

  }
  

  //these listeners are InPorks that have the capactity to provide new data to a 
  //different window (Composite ins, sends).
  void dataNotification() {    
    speaking = true;    
    graph.addUpdater(this);
  }
  
  void setDataStatus(DataStatus ds){
    dataStatus = ds;
    if (dataStatus == DataStatus.HOT) lastEval = frameCount;
  }
  
  DataStatus getDataStatus(){
    return dataStatus;
  }
  
  boolean elligibleForConnection(){
    if (currentAccess == DataAccess.READ) return true;
    
    if (currentAccess == DataAccess.READWRITE){
      return getDestinations().size() == 0;
    }
    
    if (currentAccess == null) return true;
    
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
  DataAccess resolveDataAccess(InPork other){
    DataAccess outAccess = this.getCurrentAccess();
    DataAccess inAccess = other.getCurrentAccess();
    
    //if both null, that means neither port has a WRITE requirement. return READ.
    if (outAccess == inAccess && inAccess == null){
      return DataAccess.READ;
    }
    
    //if one has a requirement and the other doesn't return that requirement.
    if (outAccess != null && inAccess == null){
      return outAccess;
    }
    if (inAccess != null && outAccess == null){
      return inAccess;
    }
    
    //if we are here, that means these ports have incompatible access requirements.
    return null;
    
  }

}
