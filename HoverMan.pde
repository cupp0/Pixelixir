//~Hover
enum HoverType {
  NONE,
  CANVAS,
  MODULE_UI,
  CONNECTION,
  COMMENT,
  MENU_OPTION
}

class HoverMan {
  
  Window scope;
  HoverTarget currentHover = new HoverTarget();
  HoverTarget previousHover = new HoverTarget();
  
  HoverMan(Window scope_){
    scope = scope_;
  }

  //args are current world coords of mouse
  void update(float cx, float cy) {
    previousHover = currentHover;
    currentHover = new HoverTarget();

    //if menu open, only check menu options for hover
    if (scope.windowMan.activeMenu != null){
      ArrayList<MenuOption> l = scope.windowMan.activeMenu.getOptions();
      HumanEvent he = scope.windowMan.stateMan.currentEvent;
      PVector screenCoords = new PVector(he.input.xMouse, he.input.yMouse);
      currentHover.setUI(checkListForHover(l, screenCoords.x, screenCoords.y));
    } else {    
      
      //check each ModuleUI list in Window
      for (Module m : scope.modules){
        Interactable i = checkListForHover(m.uiBits, cx, cy);
        if (i != null){
          currentHover.setUI(i);
          break;
        }
      }
      
      //check connection list in window
      if (currentHover.getUI() == null){
         Interactable i = checkListForHover(scope.connections, cx, cy);
         if (i != null){
           currentHover.setUI(i); 
         }
      } 
    }
    
    if (currentHover.getUI() == null){
      currentHover.setUI(scope);
    }
  }
  
  //checks in reverse order by default
  public <T extends Interactable> Interactable checkListForHover(List<T> hoverableList, float x, float y){
    for (int i = hoverableList.size() - 1; i >= 0; i--){
      HoverTarget t = hoverableList.get(i).hitTest(x, y);
      if (t.getUI() != null) {
        return t.getUI();
      }
    }
    
    return null;
  }
  
  HoverTarget getCurrent(){
    return currentHover;
  }
  
  HoverTarget getPrevious(){
    return previousHover;
  }
  
}

class HoverTarget {

  Interactable ui;
  HoverType type;

  HoverTarget(Interactable h) {
    ui = h;
    type = determineType(h);
  }
  
  HoverTarget(){
    type = HoverType.NONE;
  }
  
  HoverType determineType(Interactable h){
    if (h instanceof ModuleUI) return HoverType.MODULE_UI;
    if (h instanceof Window) return HoverType.CANVAS;
    if (h instanceof Connection) return HoverType.CONNECTION;
    if (h instanceof MenuOption) return HoverType.MENU_OPTION;
    
    return HoverType.NONE;
  }
  
  Interactable getUI(){ return ui; }
  
  void setUI(Interactable h){ ui = h; }

}
