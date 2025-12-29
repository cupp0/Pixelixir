//Pork is responsible for routing and between operators and storing data
//~Pork
abstract class Pork {
  
  final Operator owner;
  int index;
  Flow targetFlow;
  DataCategory requiredDataCategory;
  DataAccess defaultAccess;
  DataAccess currentAccess;
  boolean speaking = false;
  
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
  }
  
  void setRequiredDataCategory(DataCategory dc){
    requiredDataCategory = dc;
    if (targetFlow != null){
      targetFlow.setType(dc); 
    }
  }
  
  DataCategory getRequiredDataCategory(){
    return requiredDataCategory;
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
  
  abstract ArrayList<Pork> getConnectedPorks();
  
}

//~InPork
class InPork extends Pork  implements PorkListener{
  
  InPork(Operator owner_, int index_){ 
    super(owner_, index_);
  }
  
  OutPork getSource(){
    if (owner.parent != null){
      return owner.parent.graph.getSource(this);
    } else { return null; }
  }
  
  void onSpeaking(){
    speaking = true;
    owner.onSpeaking(this);
  }
  
  ArrayList<Pork> getConnectedPorks(){
    ArrayList<Pork> connectedPorks = new ArrayList<Pork>();

    if (((InPork)this).getSource() != null){
      connectedPorks.add(((InPork)this).getSource());
    }
    
    return connectedPorks;
  }

}

//~OutPork
class OutPork extends Pork {
  
  boolean hotData;
  int lastEval = 0;
  List<PorkListener> listeners = new ArrayList<>();  //InPorks that need to know about speaking
  
  OutPork(Operator owner_, int index_){
    super(owner_, index_);
  }
  
  ArrayList<InPork> getDestinations(){
    return owner.parent.graph.getDestinations(this);
  }
  
  //we are concerned here with propagating expected data category
  //and, if appropriate, propagating Flow identity
  void onConnection(InPork dest){
    
    DataCategory srcCat = this.getRequiredDataCategory();
    DataCategory destCat = dest.getRequiredDataCategory();
    
    //if types disagree, they need resolved
    //the only valid way for a type to disagree is if one is UNKNOWN
    if (srcCat != destCat){
      if (srcCat == DataCategory.UNKNOWN ){
        this.owner.propagateRequiredDataCategory(this, destCat);
      } else {
        dest.owner.propagateRequiredDataCategory(dest, srcCat);
      }
    } 
    
    //if targetFlow is not null, we need to propagate the Flow identity
    if (targetFlow != null){
      dest.owner.propagateTargetFlow(dest, this.targetFlow);
    }
    
    if (this.owner instanceof DynamicPorts){
      ((DynamicPorts)owner).onConnectionAdded(this);
    }
    if (dest.owner instanceof DynamicPorts){
      ((DynamicPorts)dest.owner).onConnectionAdded(dest);
    }

  }
  
  void onConnectionRemoved(InPork dest){
    
    dest.owner.propagateNullFlow(dest);
    
    owner.tryResetTypeBoundPorks();
    dest.owner.tryResetTypeBoundPorks();
    
    this.setCurrentAccess(this.getDefaultAccess());
    dest.setCurrentAccess(dest.getDefaultAccess());

  }
  
  void addListener(PorkListener listener) {
    listeners.add(listener);
  }

  void clearListeners() {
    listeners.clear();
  }

  //these listeners are InPorks that have the capactity to provide new data to a 
  //different window (Composite ins, sends).
  void dataNotification() {    
    speaking = true;
    
    if (owner != bigbang){
      owner.parent.addUpdater(new UpdateObject(this));
    }
    
    if (listeners.size() > 0){
      for (PorkListener listener : listeners) {
        listener.onSpeaking();
      }
    } 
    
    //if no listeners, we still need to notify the enclosing composite. Otherwise
    //we could have internal patch islands that don't update. bad.
    else {
      if (owner != bigbang){
        owner.parent.addUpdater(new UpdateObject(this.owner));
      }
    }
  }
  
  void setHot(boolean b){
    hotData = b;
    if (b){ lastEval = frameCount; }
  }
  
  boolean getHot(){
    return hotData;
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
