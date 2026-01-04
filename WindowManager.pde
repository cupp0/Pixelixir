//~WindowManager

class WindowManager implements MenuListener, GlobalEventListener{
  
  Window listener;
  HoverManager hoverManager;
  Window scope;                            //storing Window here as well cause I need camera access for world coords
  Menu activeMenu;
  
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
  
  void displayMenuIfActive(){
    if (activeMenu == null) return;
    activeMenu.display();
  }
  
  void switchMenu(Menu m, PVector p){
    activeMenu = m;
    activeMenu.setPosition(p);
  }
  
  void addModuleMenu(Module m, PVector p){
    activeMenu = new ModuleMenu(this, m, p);
  }
  
  void addModuleUIMenu(ModuleUI m, PVector p){
    activeMenu = new ModuleUIMenu(this, m, p);
  }
  
  void addWindowMenu(PVector p){
    activeMenu = new WindowMenu(this, scope, p);
  }
  
  void exitMenu(){
    activeMenu = null;
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
