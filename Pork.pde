//Pork is responsible for routing and between operators and storing data
//~Pork
abstract class Pork {
  
  final Operator owner;
  int index;
  Flow data;
  EnumSet<DataStatus> allowedStatuses;      //determined by Operator
  DataStatus currentStatus;                 //set on connection
  boolean speaking = false;
  
  Pork(Operator owner_, int index_){
    owner = owner_;index = index_;
  }
  
  String getAddress(){
    return this.toString().substring(this.toString().indexOf('@'));
  }
  
  void addAllowedStatus(DataStatus ds){
    allowedStatuses.add(ds);
  }
  
  void allowAllStatuses(){
    allowedStatuses = EnumSet.of(DataStatus.CONTINUATION, DataStatus.OBSERVATION);
  }
  
  boolean allowsStatus(DataStatus ds){
    return allowedStatuses.contains(ds);
  }
  
}

//~InPork
class InPork extends Pork  implements PorkListener{
  
  InPork(Operator owner_, int index_){ 
    super(owner_, index_);
    
    allowedStatuses = EnumSet.noneOf(DataStatus.class);
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
  
  void onConnection(OutPork source){
    if (owner instanceof DynamicPorts){
      ((DynamicPorts)owner).onConnectionAdded(this);
    }
  }

}

//~OutPork
class OutPork extends Pork {
  
  boolean hotData;
  List<PorkListener> listeners = new ArrayList<>();  //InPorks that need to know about speaking
  
  OutPork(Operator owner_, int index_){
    super(owner_, index_);
    
    //outs default to allowing any type of connection
    allowAllStatuses();
  }
  
  ArrayList<InPork> getDestinations(){
    return owner.parent.graph.getDestinations(this);
  }
  
  void onConnection(InPork dest){
    if (owner instanceof DynamicPorts){
      ((DynamicPorts)owner).onConnectionAdded(this);
    }
    
    DataCategory srcCat = this.data.getType();
    DataCategory destCat = dest.data.getType();
    
    //types need resolved
    if (srcCat != destCat){
      if (srcCat == DataCategory.UNKNOWN ){
        this.owner.resolvePorkDataType(this, destCat);
      } else {
        dest.owner.resolvePorkDataType(dest, srcCat);
      }
    } 

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
      owner.parent.addUpdater(new UpdateObject(this.owner));
    }
  }
  
  void setHot(boolean b){
    hotData = b;
  }
  
  boolean getHot(){
    return hotData;
  }

}
