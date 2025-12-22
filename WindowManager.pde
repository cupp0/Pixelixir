//~WindowManager

class WindowManager implements MenuListener, GlobalEventListener{
  
  Window listener;
  HoverManager hoverManager;
  Window scope;                            //storing Window here as well cause I need camera access for world coords
  ArrayList<Menu> activeMenus = new ArrayList<Menu>();
  
  float cx, cy, px, py, storedX, storedY;  //current, previous, and stored mouse positions (world coords)
  
  WindowManager(Window scope_){
    listener = scope_;
    scope = scope_;
    hoverManager = new HoverManager(scope);
  }
    
  void dispatch(HumanEvent event) {
    listener.onHumanEvent(event);
  }
  
  HoverTarget updateHover(){

    px = scope.cam.toWorldX(pmouseX);
    py = scope.cam.toWorldY(pmouseY);
    cx = scope.cam.toWorldX(mouseX);
    cy = scope.cam.toWorldY(mouseY);
    
    return hoverManager.update(cx, cy);    
  }
  
  void addMenu(Menu m, PVector p){
    activeMenus.add(m);
    activeMenus.get(activeMenus.size()-1).setPosition(p);    
  }
  
  void addModuleMenu(Module m, PVector p){
    activeMenus.add(new ModuleMenu(this, m));
    activeMenus.get(activeMenus.size()-1).setPosition(p);
  }
  
  void addModuleUIMenu(ModuleUI m, PVector p){
    activeMenus.add(new ModuleUIMenu(this, m));
    activeMenus.get(activeMenus.size()-1).setPosition(p);
  }
  
  void addWindowMenu(PVector p){
    activeMenus.add(new WindowMenu(this, scope));
    activeMenus.get(activeMenus.size()-1).setPosition(p);
  }
  
  void removeMenu(Menu m){
    activeMenus.remove(m);
  }
  
  void onMenuExecution(Menu whichMenu){
    int menuIndex = -1;
    for (int i = 0; i < activeMenus.size(); i++){
      if (activeMenus.get(i) == whichMenu){
        menuIndex = i;
      }
    }
    
    for (int i = activeMenus.size()-1; i >= menuIndex; i--){
      activeMenus.remove(i);
    }
    
    if (activeMenus.size() == 0){
      scope.eventManager.state = InteractionState.NONE;
    }
  }
  
  void closeAllMenus(){
    for (int i = activeMenus.size()-1; i >= 0; i--){
      activeMenus.remove(i);
    }
    scope.eventManager.state = InteractionState.NONE;
  }
  
  void onGlobalInputEvent(GlobalInputEvent e){
    switch(e.type){
      case MOUSE:       
        handleGlobalMouseEvent(e);
        break;
      
      case KEY:
        handleGlobalKeyEvent(e);
        break;
    }    
  }

  void handleGlobalMouseEvent(GlobalInputEvent ge) {
    
    //update current and prvious mouse pos, check hover
    HoverTarget hover = updateHover();
    
    //stored where the mouse position if pressed
    if (ge.action == Action.MOUSE_PRESSED){
      storedX = cx; storedY = cy; 
    }

    HumanEvent e = new HumanEvent(
      ge,
      cx,
      cy,
      px,
      py,
      hover
    );
    dispatch(e);
  }
  
  void handleGlobalKeyEvent(GlobalInputEvent ge) {
    HumanEvent e = new HumanEvent(
      ge,
      cx, 
      cy,
      px,
      py,
      null
    );
    dispatch(e);
  }
  
  PVector getCurrentMouse(){
    return new PVector(cx, cy);
  }
  
  PVector getStoredMouse(){
    return new PVector(storedX, storedY);
  }
}
