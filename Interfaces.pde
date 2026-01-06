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

interface GraphListener{
  void onGraphChange();
}

//implemented by ModuleUI, listens to states for changes to data (UIPayloads) and UI (exposure changes)
interface UIStateListener{
  void onUIPayloadChange(DBUIState s);
}

//windowmanager 
interface MenuListener{
  void exitMenu();
  void switchMenu(Menu m, PVector p);
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

interface DynamicPorks{
  void addCanonicalPork();
  void rebuildPorks(int inCount, int outCount);
  boolean isInputDynamic();
  boolean isOutputDynamic();
}

//implemented by Window, whose eventManager handles any user interaction
//I guess 
interface HumanEventListener {
  void onHumanEvent(HumanEvent event);
}

interface GlobalEventListener {
  void onGlobalInputEvent(GlobalInputEvent event);  
}
