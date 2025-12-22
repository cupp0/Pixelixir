//~UIState
abstract class UIState{
  
  transient UIStateListener listener;                  //ModuleUI that subscribes to changes here
  String id = UUID.randomUUID().toString();   
  PVector pos = new PVector();
  
  UIState(){}
  
  void setListener(UIStateListener listener_){
    listener = listener_;
  }
  
  void setPosition(PVector p){
    pos = p.copy();  
  }

  abstract String getType();
  
  UIState getState(){
    return this;
  }
    
}

//~TextfieldUIState
class TextfieldUIState extends DBUIState{

  TextfieldUIState() {
    super();
    setData(new UIPayload("")); 
  }

  String getType(){ return "textfield"; }

}

class PortUIState extends UIState {
    
  PortUIState(){
    super();
  }

  String getType(){ return "port"; }

}

class InPortUIState extends PortUIState {
    
  InPortUIState(){
    super();
  }
  
  String getType(){ return "inPort"; }

}

class OutPortUIState extends PortUIState {
    
  OutPortUIState(){
    super();
  }
  
  String getType(){ return "outPort"; }

}
