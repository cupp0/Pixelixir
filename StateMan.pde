//~StateMan
class StateMan{
 
  Window scope;                                                //per window state Man so we can do multi window later
  
  HumanEvent currentEvent;
  InputMan inputMan = new InputMan();                          //stores raw input state (mouse/keys)
  SelectionMan selectionMan;
  InteractionMan interactionMan;                               //what are we interacting with, what are we doing
  HoverMan hoverMan;                                           //what are we hovering
  Camera cam;                                                  //camera state
  float cx, cy, px, py, storedX, storedY;                      //current, previous, and stored mouse positions (world coords)

  StateMan(Window scope_){
    scope = scope_;
    selectionMan = new SelectionMan(scope_);
    interactionMan = new InteractionMan(scope_);
    hoverMan = new HoverMan(scope_); 
    cam = new Camera(scope_);  
  }
  
  void onInput(GlobalInputEvent e){
    
    //translate mouse coords to world coords
    updateMouse(e);
    
    //update hover
    hoverMan.update(cx, cy);
   
    currentEvent = new HumanEvent(
      e,
      cx,
      cy,
      px,
      py,
      hoverMan.getCurrent()
    );
    
    inputMan.update(currentEvent.input);                      //update input state
    interactionMan.update(hoverMan, currentEvent);  //interact with stuff if needed    
    inputMan.endFrame();                                      //clear transient state stuff, this doesn't go here
  }
  
  void updateMouse(GlobalInputEvent ge){
    px = cx; py = cy;               //store previous mouse positions, as well as new current pos
    int sx = ge.xMouse;
    int sy = ge.yMouse;
    
    cx = cam.toWorldX(sx);
    cy = cam.toWorldY(sy);
   
    //store mouse position if pressed
    if (ge.action == Action.MOUSE_PRESSED){
      storedX = cx; storedY = cy; 
    }
  }
  
  boolean isHovering(Interactable h){
    return h == hoverMan.currentHover.getUI();
  }
  
  boolean isMouseDoing(Action a, int whichButton){
    return (currentEvent.input.action == a && currentEvent.input.mouseButt == whichButton);
  }
  
  boolean isMouseDoing(Action a){
    return (currentEvent.input.action == a);
  }
  
  boolean isKeyBoardDoing(Action a, int whichKey){
    return (currentEvent.input.action == a && inputMan.state.justPressed(whichKey));
  }
  
  boolean isInteractionState(InteractionState s){
    return interactionMan.state == s;
  }
  
  boolean isInteractionState(InteractionState s, Interactable i){
    return (interactionMan.state == s && interactionMan.target == i);
  }

  InteractionMan getInteractionMan() { return interactionMan;}
  
  //where else to track if we are hovering an eye
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
 
}
