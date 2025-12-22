class DBUIState extends UIState implements DataBender{
  
  String identityToken;   // user can assign to link separate UI
  UIPayload data;    
  
  DBUIState(){
    super(); trySetIdentityToken(UUID.randomUUID().toString());
  }
  
  void tryUpdateOperator(){
    if (((ModuleUI)listener).parent.owner instanceof PrimeOperator){
      ((ModuleUI)listener).onUIPayloadChange(this);
    }
  }

  void trySetIdentityToken(String newName){
    
    if (identityManager.identityGroupExists(newName)){
      if (identityManager.groups.get(newName).getType() != this.getType()){
        println("that name already taken by a different type");
        return;
      } 
    }
    
    identityToken = newName;    
    identityManager.submitToken(identityToken, this); 
  }

  void setData(UIPayload p){
    data = p;    
  }
  
  UIPayload getData(){
    return data;
  }

  void onLocalEvent(UIPayload p){
    //set value of this state with UIPayload in UIEvent
    setData(p);
      
    if (identityManager.identityGroupExists(identityToken)){
      identityManager.propagateIdentityEvent(identityToken, this); 
    } else {   
      //if this state is attached to a prime operator (this states' ui is on a module whose operator is prime)
      tryUpdateOperator();
    }
  }
  
  void onIdentityEvent(UIPayload p){
    //set value of this state with UIPayload in UIEvent
    setData(p);
    
    //if this state is attached to a prime operator (this states' ui is on a module whose operator is prime)
    tryUpdateOperator();
  }
  
  void copyData(DBUIState db){
    setData(db.getData());
    if (db.identityToken != null){
      trySetIdentityToken(db.identityToken);
    }
  }
  
  //so far, just for DisplayUI, when its op changes, the image it displays needs to change.
  //in general, this can be used for UI that need to react to changes in op
  void onDataChange(Operator op){}
    
  String getType(){ return "db"; }
  
  String getIdentityToken(){
    return identityToken;
  }
}