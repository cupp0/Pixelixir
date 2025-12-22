//~Interfaces
  
//implemented by any UI that can be interacted with via mouse, currently ModuleUI and ConnectionUI, eventually MenuUI
interface Hoverable {
  HoverTarget hitTest(float x, float y);
  Style getStyle();
}

//only ModuleUI that you can directly interact with (slider, texfield, etc)
interface Interactable{
  void onInteraction(HumanEvent e);
}

//implemented by Module. Module needs to know about some changes to Operator
interface OperatorListener {  
  void onPorkAdded(Pork p);
  void onPorkRemoved(Pork p);
}

//implemented by InPorks of modules that provide data to a different window (composites, sends). 
//They listen to Outporks that can provide new data to the Window they are in so they can notify
//the other window
interface PorkListener {
  void onSpeaking();
}

//implemented by ModuleUI, listens to states for changes to data (UIPayloads) and UI (exposure changes)
interface UIStateListener{
  void onUIPayloadChange(DBUIState s);
}

//Implemented by WindowManager
interface MenuListener{
  void addMenu(Menu m, PVector p);
  void onMenuExecution(Menu whichMenu);
}

//for evaluating unary ops on floats, I think I'm doing something weird 
@FunctionalInterface
interface UnaryOperator<T> {
  float apply(float x);
}

@FunctionalInterface
interface LogicOperator<T> {
  boolean apply(boolean a, boolean b);
}

//implemented by UIStates that affect / are affected by Operators (sliders, textfields, displays etc..)
//These are UI that the user can choose to expose at different scopes
interface DataBender{
  void tryUpdateOperator();
  void setData(UIPayload p);
  UIPayload getData();
  void copyData(DBUIState db);
  void onLocalEvent(UIPayload pl);
  void onDataChange(Operator op);
  String getType();
}

interface DynamicPorts{
  void onConnectionAdded(Pork where);
  void onConnectionRemoved(Pork where);
}

//implemented by Window, whose eventManager handles any user interaction
//I guess 
interface HumanEventListener {
  void onHumanEvent(HumanEvent event);
}

interface GlobalEventListener {
  void onGlobalInputEvent(GlobalInputEvent event);  
}
