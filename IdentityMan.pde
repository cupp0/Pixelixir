
//~IdentityMan
//UI Identity group Man
public class IdentityMan {

    private Map<String, IdentityGroup> groups;  // token -> group

    public IdentityMan() {
        groups = new HashMap<>();
    }

    void propagateIdentityEvent(String token, DataBender db){
      if (identityGroupExists(token)){
        groups.get(token).setSharedValue(db.getData());
      }
    }

    public void submitToken(String token, DataBender db) {      
      //if this db is already in a group, unregister it
      for (IdentityGroup g : groups.values()){
        if (g.members.contains(db)){
          unregister(g.token, db);
          break;
        }
      }
      
      //if the token already exists, register it
      if (identityGroupExists(token)){
        register(token, db);
      } else {
        
        //otherwise, create new group and register
        IdentityGroup newGroup = createGroup(db.getType(), token);
        register(token, db);
      }
    }

    public IdentityGroup createGroup(String type, String token) {
      //if group already exists, return it
      if (identityGroupExists(token)){
        println("attempted to create a group that already exists");
        return groups.get(token);
      }
      
      //if not, make the group
      IdentityGroup newGroup = new IdentityGroup(type, token);
      
      //add the group
      groups.put(token, newGroup);
      
      return newGroup;
    }

    public void removeIdentityGroup(String token) {
        // TODO:
        // 1. Look up group by token
        // 2. Clear all members' references to this group (if needed)
        // 3. Remove group from map
    }

    public void register(String token, DataBender db) {
      
      //find group. If it doesn't exist, create it
      IdentityGroup g = groups.get(token);
      if (g == null){
        g = createGroup(token, (db.getType()));
      } 
      
      //register the state
      g.registerState(db);
    }
    
    void renameGroup(String oldKey, String newKey){
      IdentityGroup g = groups.get(oldKey);
      groups.remove(oldKey);
      groups.put(newKey, g);
      
      for (DataBender db : groups.get(newKey).members){
        ((DBUIState)db).identityToken = newKey;
      }
    }

    public void unregister(String token, DataBender state) {
      groups.get(token).unRegisterState(state);
      
      if (groups.get(token).members.size() == 0){
        groups.remove(token);
      }
    }

    public boolean identityGroupExists(String token) {
        return groups.containsKey(token);
    }

}

//~IdentityGroup
private class IdentityGroup{
  String type;                       // "slider", "switch", "textfield", etc.
  String token;                      // string identifier for the group
  UIPayload sharedValue;             // shared value for all members
  Set<DataBender> members;           // all UIStates registered to this token

  IdentityGroup(String type_, String token_) {
    this.type = type_; this.token = token_;
    this.members = new HashSet<>();
  }
  
  void registerState(DataBender db){
    //add state to the group
    members.add(db);
  }
  
  void unRegisterState(DataBender dbToRemove){
    for (DataBender db : members){
      if (((UIState)db).id == ((UIState)dbToRemove).id){
        members.remove(db);
        return;
      }
    }
  }
  
  //eventually this should resize UI as well. It should be setSharedState
  //and take a UIState, where each important state value is copied
  //alternatively, different methods setSharedData, setSharedParam, etc..
  void setSharedValue(UIPayload p){
    this.sharedValue = p;

    // propagate to all members
    for (DataBender db : members) {
      db.setData(sharedValue); 
      db.tryUpdateOperator();
    }
  }
  
  UIPayload getsharedValue(){
    return sharedValue;
  }
  
  String getType(){ return type; }
  
  String getToken(){ return token; }
  
  void setType(String s){ type = s; }
    
}
