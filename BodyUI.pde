//~BodyUI
public class BodyUI extends ModuleUI<BodyUIState>{
  
  float radius = 5;       //roundover on corners
  
  BodyUI(){
    super();
    name = "body";
  }

  void display(){
    shape(shape, state.pos.x, state.pos.y);
    
    //little edge that shows if the operator is writing or just reading
    if (parent.isComposite())return;
    if (!(parent.owner.hasOutput()) || !(parent.owner.hasInput())) return;
    if(!parent.owner.isMutating()) return;
    color edgeColor = getWindow().windowMan.styleResolver.getConnectionColorByPork(parent.owner.ins.get(0).getSource());
    if (edgeColor != color(0)){
      stroke(edgeColor);
      strokeWeight(2);      
      line(state.pos.x, state.pos.y+radius, state.pos.x, state.pos.y+size.y-radius);
    }
  }
  
  //returns index of new corner
  int addCorner(){
    //cornerPoints.add(getEdgeIndex(), new CornerPoint(PVector.sub(currentWindow.cam.wMouse, state.pos), this));
    //updateShape();
    //return getEdgeIndex();
    return 1;
  }
  
  int getEdgeIndex() {
    int closestIndex = -1;
    float closestDist = Float.MAX_VALUE;
  
    int count = cornerPoints.size();
    for (int i = 0; i < count; i++) {
      PVector a = PVector.add(state.pos, cornerPoints.get(i).pos);
      PVector b = PVector.add(state.pos, cornerPoints.get((i+1) % count).pos); // wrap for closed shape

    }
    return closestIndex;
  }
  
  int cornerHovered(){
    int which = -1;
    for (int i = 0; i < cornerPoints.size(); i++){
      //if (cornerPoints.get(i).isHovered()){ return i; }
    }
    return which;
  }
  
  //just checks if mouse is inside the UI element
  @Override
  boolean isBodyHovered(float x, float y){
    // Invert the transform to get the mouse position in shape space
    PMatrix2D mat = new PMatrix2D();
    mat.invert();
  
    PVector m = mat.mult(PVector.sub(new PVector(x, y), state.pos), null); //don't know why this works
    boolean hovered = false;
    int n = cornerPoints.size();
    for (int i = 0, j = n - 1; i < n; j = i++) {
      PVector vi = cornerPoints.get(i).pos;
      PVector vj = cornerPoints.get(j).pos;
      if (((vi.y > m.y) != (vj.y > m.y)) &&
          (m.x < (vj.x - vi.x) * (m.y - vi.y) / (vj.y - vi.y) + vi.x)) {
        hovered = !hovered;
      }
    }
    
    return hovered;    
  }
  
  StateChange onInteraction(HumanEvent e){
    StateMan sm = getWindow().windowMan.stateMan;
    
    if (sm.isInteractionState(InteractionState.NONE)){
        if (sm.isMouseDoing(Action.MOUSE_PRESSED, LEFT)){
          sm.selectionMan.addTo(this.parent);
          return new StateChange(StateAction.ADD, InteractionState.DRAGGING_MODULES, this);
        }
        
        if (sm.isMouseDoing(Action.MOUSE_PRESSED, RIGHT)){
          getWindow().windowMan.addModuleMenu(parent, new PVector(e.input.xMouse, e.input.yMouse));
          return new StateChange(StateAction.ADD, InteractionState.MENU_OPEN, this);
        }
    }
    
    if (sm.isInteractionState(InteractionState.DRAGGING_MODULES)){
        if(e.input.action == Action.MOUSE_DRAGGED) { 
          //println(frameCount+ ": dragging " + e.xMouse);
          getWindow().dragModules(sm.selectionMan.modules, e);
          return new StateChange(StateAction.DO_NOTHING);
        }
        if (e.input.action == Action.MOUSE_RELEASED) {
          CompositeUI eye = sm.hoveringEye();
          if (eye != null){
            Window target = windows.get(eye.parent);  
            sm.selectionMan.moveSelection(sm.selectionMan.modules, currentWindow, target);
          }
          return new StateChange(StateAction.REMOVE, InteractionState.DRAGGING_MODULES, this);
        }
    }
    
    return new StateChange(StateAction.DO_NOTHING);
  }
  
}
