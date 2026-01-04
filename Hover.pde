//~Hover
enum HoverType {
  NONE,
  BODY,
  EDGE,
  CORNER,
  CONNECTION,
  MENUOPTION
}

class HoverTarget {

  HoverType type;

  ModuleUI modUI;
  Connection connection;
  MenuOption menuOption;
  int cornerIndex = -1;

  // Default: hovering nothing
  HoverTarget() {
    type = HoverType.NONE;
  }

  HoverTarget(ModuleUI m, HoverType t_, int index) {
    type = t_;
    modUI = m;
    cornerIndex = index;
  }

  HoverTarget(Connection c) {
    type = HoverType.CONNECTION;
    connection = c;
  }
  
  HoverTarget(MenuOption mo) {
    type = HoverType.MENUOPTION;
    menuOption = mo;
  }
}

class HoverManager {
  
  Window scope;
  HoverTarget current = new HoverTarget();
  HoverTarget previous = new HoverTarget();
  
  HoverManager(Window scope_){
    scope = scope_;
  }

  HoverTarget update(float cx, float cy) {

    previous = current;
    current = new HoverTarget();
  
    //first check menu hover 
    if (scope.windowManager.activeMenu != null){
      ArrayList<MenuOption> ops = scope.windowManager.activeMenu.getOptions();
      for (MenuOption mo : ops){
        HoverTarget t = mo.hitTest(mouseX, mouseY);
        if (t.type != HoverType.NONE) {
          current = t;
          return current;
        }
      }
    } 
    
    //then check ui hover
    else {
      for (int i = scope.modules.size()-1; i >= 0; i--){
        for (int j = scope.modules.get(i).uiBits.size()-1; j >= 0; j--){
          HoverTarget t = scope.modules.get(i).uiBits.get(j).hitTest(cx, cy);
          if (t.type != HoverType.NONE) {
            current = t;
            return current;
          }
        }
      }
  
      //last, connections
      for (Connection c : scope.connections) {
        HoverTarget t = c.hitTest(cx, cy);
        if (t.type != HoverType.NONE) {
          current = t;
          return current;
        }
      }
    }
  
    return current;
  }
  
  HoverTarget getCurrent(){
    return current;
  }
  
  HoverTarget getPrevious(){
    return previous;
  }
  
}
