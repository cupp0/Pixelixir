//~EventManager

//~HumanEvent
class HumanEvent {
  final GlobalInputEvent input;                  //raw input layer
  final float xMouse, yMouse, pxMouse, pyMouse;  //mouse info translated to world coords
  final HoverTarget hover;                       //currentWindow level info about what's hovered
  
  HumanEvent(GlobalInputEvent input_, float xMouse_, float yMouse_, float pxMouse_, float pyMouse_, HoverTarget hover_) {
    this.input = input_;
    this.xMouse = xMouse_;
    this.yMouse = yMouse_;
    this.pxMouse = pxMouse_;
    this.pyMouse = pyMouse_;
    this.hover = hover_;
  }
}

class EventManager {
  
  //this is who we are managing for
  final Window scope;
  
  //stores window level event (dragging UI, making selection, etc..)
  InteractionState state = InteractionState.NONE;
  
  StyleResolver styleResolver;
  InputManager inputManager = new InputManager();
  ModuleUI focusedUI;
  Connection focusedConnection;
  MenuOption hoveredOption;
  OutPortUI cuedPort;
  int grabbedCorner;

  EventManager(Window scope_){
    scope = scope_;
    styleResolver = new StyleResolver(this);
  }  

  void handle(HumanEvent e) {
    inputManager.update(e);
    switch (state) {

    case NONE:
      
      //key presses
      if(e.input.action == Action.KEY_PRESSED && state == InteractionState.NONE){
        if (inputManager.getState().isDown(CONTROL) && inputManager.getState().justPressed('C')){
          selectionManager.copyModules(selectionManager.modules);
        }
        if (inputManager.state.isDown(CONTROL) && inputManager.state.justPressed('V')){
          selectionManager.pasteModules(selectionManager.clipboard, scope, new PVector(e.xMouse, e.yMouse));
        }
        if (e.input.theKey == 'r'){
          scope.cam.resetCam();         
        }
        if (inputManager.getState().isDown(CONTROL) && inputManager.getState().justPressed('S')){
          saveSketch();         
        }
        if (inputManager.getState().isDown(CONTROL) && inputManager.getState().justPressed('L')){
          loadSketch();     
        }
        if (e.input.theKeyCode == BACKSPACE){
          selectionManager.onBackSpace();          
        }
      }
      
      //mouse moved
      if (e.input.action == Action.MOUSE_MOVED){
        updateNeutralHover(e);
      }
       
      //if left mouse pressed not on any UI
      if (e.input.action == Action.MOUSE_PRESSED && e.input.mouseButt == LEFT && e.hover.type == HoverType.NONE) {
        selectionManager.clearSelection();
        state = InteractionState.PANNING;              
      }
      
      //right mouse pressed
      if (e.input.action == Action.MOUSE_PRESSED && e.input.mouseButt == RIGHT) {    
        state = InteractionState.RIGHT_MOUSE_DOWN;    
      }
      
      //mouse wheel
      if (e.input.action == Action.MOUSE_WHEEL){
        scope.cam.zoom(e.input.wheelDelta);
        checkWindowTransition(e);
      }
      break;
    
    case RIGHT_MOUSE_DOWN:
      if (e.input.action == Action.MOUSE_DRAGGED){
        updateNeutralHover(e);
        state = InteractionState.SELECTING_MODULES;
        scope.addSelectionRectangle(e); 
      }
      
      if (e.input.action == Action.MOUSE_RELEASED){
        scope.windowManager.addWindowMenu(new PVector(mouseX, mouseY));
        state = InteractionState.MENU_OPEN;  
      }
      break;
      
    case HOVERING_UI:
    
      if (e.input.action == Action.MOUSE_MOVED){
        updateNeutralHover(e);
      }
      
      if (e.input.action == Action.MOUSE_PRESSED && e.input.mouseButt == RIGHT) { 
        if (inputManager.state.isDown(SHIFT)){
          if (e.hover.modUI.state instanceof DataBender){
            //prompt user to set identityToken
          }
        }
      }
      
      //right mouse pressed
      if (e.input.action == Action.MOUSE_PRESSED && e.input.mouseButt == RIGHT) {
        if (e.hover.modUI instanceof BodyUI && e.hover.type == HoverType.BODY){
          scope.windowManager.addModuleMenu(e.hover.modUI.parent, new PVector(mouseX, mouseY));
          state = InteractionState.MENU_OPEN;
        }
        
        if (e.hover.modUI instanceof DBUI){
          scope.windowManager.addModuleUIMenu(e.hover.modUI, new PVector(mouseX, mouseY));
          state = InteractionState.MENU_OPEN;
        }
      }
    
      //left mouse pressed
      if (e.input.action == Action.MOUSE_PRESSED && e.input.mouseButt == LEFT) { 
        if (inputManager.state.isDown(SHIFT)){
          if (!(e.hover.modUI instanceof BodyUI)){
            focusedUI = e.hover.modUI;
            state = InteractionState.DRAGGING_UI;
          }
        } else {
          //if left pressing body, add module to selection and set state DRAGGING_MODULES
          if (e.hover.modUI instanceof BodyUI && e.hover.type == HoverType.BODY){
                       
            selectionManager.addTo(e.hover.modUI.parent);
            state = InteractionState.DRAGGING_MODULES;
          }
          
          //if left pressing outport, cue it for connection
          if (e.hover.modUI instanceof OutPortUI){
            cuedPort = (OutPortUI)e.hover.modUI;
            state = InteractionState.DRAGGING_OPEN_CONNECTION;
            scope.addConnectionLine(cuedPort);
          }
          
          //left press button
          if (e.hover.modUI instanceof ButtonUI){
            focusedUI = e.hover.modUI;
            ((ButtonUI)e.hover.modUI).onInteraction(e);
            state = InteractionState.HOLDING_BUTTON;
          }
          
          //left press switch
          if (e.hover.modUI instanceof SwitchUI){
            focusedUI = e.hover.modUI;
            ((SwitchUI)e.hover.modUI).onInteraction(e);         
          }
          
          //left press slider
          if (e.hover.modUI instanceof SliderUI){
            focusedUI = e.hover.modUI;
            ((SliderUI)e.hover.modUI).onInteraction(e);
            state = InteractionState.DRAGGING_SLIDER;
          }
          
          //left press textfield
          if (e.hover.modUI instanceof TextfieldUI){
            focusedUI = e.hover.modUI;
            ((TextfieldUI)e.hover.modUI).onInteraction(e);
            state = InteractionState.TYPING;
          }          
        }
      }
          
      //mouse wheel
      if (e.input.action == Action.MOUSE_WHEEL){
        scope.cam.zoom(e.input.wheelDelta);
        checkWindowTransition(e);
      }
      
      break;
    case DRAGGING_MODULES:
      if (e.input.action == Action.MOUSE_DRAGGED) {       
        scope.dragModules(selectionManager.modules, e);
      }

      if (e.input.action == Action.MOUSE_RELEASED) {
        if (hoveringEye() != null){
          Window target = windows.get(hoveringEye().parent.owner);  
          selectionManager.copyModules(selectionManager.modules);
          selectionManager.onBackSpace();
          selectionManager.pasteModules(selectionManager.clipboard, target, new PVector(0, 0));
        }
        focusedUI = null;
        state = InteractionState.NONE;
      }
      break;
      
    case DRAGGING_UI:
      if (e.input.action == Action.MOUSE_DRAGGED && focusedUI != null) {       
        focusedUI.drag(new PVector(e.xMouse - e.pxMouse, e.yMouse - e.pyMouse));
      }
      if (e.input.action == Action.MOUSE_RELEASED) {
        state = InteractionState.HOVERING_UI;
      }
      break;
      
    case DRAGGING_SLIDER:
      if (e.input.action == Action.MOUSE_DRAGGED && focusedUI instanceof SliderUI) {
        ((SliderUI)focusedUI).onInteraction(e);
      }

      if (e.input.action == Action.MOUSE_RELEASED) {
        state = InteractionState.HOVERING_UI;
      }
      break;
      
    case HOLDING_BUTTON:
      if (e.input.action == Action.MOUSE_RELEASED) {       
        ((ButtonUI)focusedUI).onInteraction(e);
        state = InteractionState.HOVERING_UI;
      }
      break;
      
    case TYPING:
      if (e.input.action == Action.KEY_PRESSED) {       
        ((TextfieldUI)focusedUI).onInteraction(e);  
      }
      if (e.input.action == Action.MOUSE_PRESSED){
        ((TextfieldUI)focusedUI).onInteraction(e); 
        focusedUI = null;
        state = InteractionState.NONE;
      }
      break;   
      
    case SELECTING_MODULES:
      if (e.input.action == Action.MOUSE_DRAGGED) {
        //dragCurrent.set(e.mouseX, e.mouseY);
      }

      if (e.input.action == Action.MOUSE_RELEASED) {
          finalizeSelection(e);
          state = InteractionState.NONE;
      }
      break;
      
    case PANNING:
      if (e.input.action == Action.MOUSE_DRAGGED) {
        scope.cam.pan(new PVector(e.xMouse - e.pxMouse, e.yMouse - e.pyMouse));
      }

      if (e.input.action == Action.MOUSE_RELEASED) {
          state = InteractionState.NONE;
      }
      break;
      
    case DRAGGING_OPEN_CONNECTION:
      
      //if outport is qd, build connection
      if (e.input.action == Action.MOUSE_PRESSED && e.input.mouseButt == LEFT){
        if (e.hover.modUI instanceof InPortUI){
          if (((InPortUI)e.hover.modUI).getSource() == null){
            scope.attemptConnection(cuedPort, ((InPortUI)e.hover.modUI));
            if(!inputManager.getState().isDown(CONTROL)){
              scope.removeConnectionLine();
              cuedPort = null;
              state = InteractionState.NONE;
            }
          }
        }
      }
      
      if (e.input.action == Action.KEY_PRESSED && (e.input.theKeyCode == BACKSPACE)){
        scope.removeConnectionLine();
        cuedPort = null;
        state = InteractionState.NONE;
      }
      
      break;
      
    case HOVERING_CONNECTION:
      if (e.input.action == Action.MOUSE_MOVED){
        updateNeutralHover(e);
        break;
      }
      if (e.input.action == Action.KEY_PRESSED && (e.input.theKeyCode == BACKSPACE)){
        scope.removeConnection(scope.getEdgeByConnection(focusedConnection));
        focusedConnection = null;
        state = InteractionState.NONE;
        break;
      }
      //mouse wheel
      //if (e.action == Action.MOUSE_WHEEL){
      //  scope.cam.zoom(e.wheelDelta);
      //  checkWindowTransition(e);
      //}
      break;
      
    case MENU_OPEN:
      if (e.input.action == Action.MOUSE_MOVED){
        updateMenuHover(e);
      }
      if (e.input.action == Action.MOUSE_PRESSED && e.input.mouseButt == LEFT){
        if (hoveredOption != null){
          hoveredOption.execute();
        } else {
          //clears menus and sets state to NONE
          //probably bad to set interaction state in window manager instead of here.
          //not sure how to do it better. How does EventManager listen to WindowManager?
          scope.windowManager.closeAllMenus();
        }
      }
      break;



    }
    inputManager.endFrame();
  }
  
  void checkWindowTransition(HumanEvent e){

    if (e.hover.modUI instanceof CompositeUI){           
      //if hovering an eye and zooming in, transition to new window
      if (e.input.wheelDelta > 0 && scope.cam.scl > scope.cam.maxScl){
        currentWindow.setWindow(e.hover.modUI.parent.owner, true);
      }         
    }
    
    //if zooming out, check the window exists before transitioning
    if (e.input.wheelDelta < 0 && scope.cam.scl < scope.cam.minScl){
      if (windows.containsKey(scope.boundary.parent)){
        currentWindow.setWindow(scope.boundary.parent, false);
      }
    }
  }
  
  
  void finalizeSelection(HumanEvent e){
    selectionManager.modules = scope.getModulesInside(scope.windowManager.getStoredMouse(), new PVector(e.xMouse, e.yMouse));
    scope.removeSelectionRectangle();
  }
  
  boolean is(InteractionState s){
    return state == s;
  }
  
  //dumb, we need to maintain a z-list of what's hovered 
  CompositeUI hoveringEye(){
    for (Module m : scope.modules){
      for (ModuleUI ui : m.uiBits){
        if (ui instanceof CompositeUI){
          if (((CompositeUI)ui).isHovered()){
            return((CompositeUI)ui);
          }
        }
      }
    }
    return null;
  }
  
  void updateMenuHover(HumanEvent e){
    if (e.hover.type == HoverType.MENUOPTION){
      hoveredOption = e.hover.menuOption;
    } else {
      hoveredOption = null;
    }
  }
  
  void updateNeutralHover(HumanEvent e){
    if (e.hover.type == HoverType.CONNECTION){
      focusedUI = null;
      focusedConnection = e.hover.connection;
      state = InteractionState.HOVERING_CONNECTION;
    }
    if (e.hover.modUI != null){
      focusedConnection = null;
      focusedUI = e.hover.modUI;
      state = InteractionState.HOVERING_UI;
    }
    if (e.hover.type == HoverType.NONE){
      focusedConnection = null;
      focusedUI = null;
      state = InteractionState.NONE;
    }
  }
}
