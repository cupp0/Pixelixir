//~GlobalInput

enum GlobalEventType { MOUSE, KEY }

enum Action { 
  MOUSE_MOVED, MOUSE_DRAGGED, MOUSE_PRESSED, MOUSE_RELEASED, MOUSE_CLICKED, MOUSE_WHEEL,
  KEY_PRESSED, KEY_RELEASED, KEY_TYPED
}

class GlobalInputEvent {
  final GlobalEventType type;
  final Action action;
  final int timestamp;
  final int xMouse, yMouse, pxMouse, pyMouse;
  final int mouseButt;
  final float wheelDelta;
  final char theKey;
  final int theKeyCode;
  
  GlobalInputEvent(GlobalEventType type_, Action action_, int timestamp_,
    int xMouse_, int yMouse_, int pxMouse_, int pyMouse_, int mouseButt_, 
    float wheelDelta_, char theKey_, int theKeyCode_){
      
    this.type = type_;
    this.action = action_;
    this.timestamp = timestamp_;
    this.xMouse = xMouse_;
    this.yMouse = yMouse_;
    this.pxMouse = pxMouse_;
    this.pyMouse = pyMouse_;
    this.mouseButt = mouseButt_;
    this.wheelDelta = wheelDelta_;
    this.theKey = theKey_;
    this.theKeyCode = theKeyCode_;
  }
}

class GlobalInputMan{
  
  ArrayList<GlobalEventListener> globalListeners = new ArrayList<>(); //these are primitive ops that want raw input data
  int lx = 0;
  int ly = 0;
  
  void registerGlobalListener(GlobalEventListener l){
    globalListeners.add(l);  
  }
  
  //this dispatches to the current window, as well as directly to any Operators that want direct input data
  void dispatch(GlobalInputEvent e){
    for (GlobalEventListener l : globalListeners){
      l.onGlobalInputEvent(e);
    }
    currentWindow.windowMan.stateMan.onInput(e);  //perfectly reasonable
  }
  
   void handleMouseEvent(Action action) {
    GlobalInputEvent e = new GlobalInputEvent(
      GlobalEventType.MOUSE,
      action,
      millis(),
      mouseX, 
      mouseY,
      lx,
      ly,
      mouseButton,
      0.0f,
      '\0',
      0
    );
    
    lx = mouseX;
    ly = mouseY;
    dispatch(e);
  }
  
  void handleMouseWheel(float delta) {
        
    GlobalInputEvent e = new GlobalInputEvent(
      GlobalEventType.MOUSE,
      Action.MOUSE_WHEEL,
      millis(),
      mouseX,
      mouseY,
      lx,
      ly,
      mouseButton,
      -delta,
      '\0',
      0
    );
    
    lx = mouseX;
    ly = mouseY;
    dispatch(e);
  }
  
  void handleKeyEvent(Action action, char key, int keyCode) {
    GlobalInputEvent e = new GlobalInputEvent(
      GlobalEventType.KEY,
      action,
      millis(),
      mouseX, 
      mouseY,
      lx,
      ly,
      mouseButton,
      0.0f,
      key,
      keyCode
    );
    
    lx = mouseX;
    ly = mouseY;
    dispatch(e);
  }
  
}
