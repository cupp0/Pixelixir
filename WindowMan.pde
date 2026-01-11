//~WindowMan
enum MenuType {
  MODULE,
  MODULE_UI,
  WINDOW
}

class WindowMan implements MenuListener, GlobalEventListener{
  
  Window scope;
  StateMan stateMan;
  StyleResolver styleResolver;
  Menu activeMenu;
  Module lastSpawned;
    
  WindowMan(Window scope_){
    scope = scope_;
    stateMan = new StateMan(scope_);
    styleResolver = new StyleResolver(scope);
  }
  
  void displayMenuIfActive(){
    if (activeMenu == null) return;
    activeMenu.display();
  }
  
  void switchMenu(Menu m, PVector p){
    activeMenu = m;
    activeMenu.setTargetPosition(p);
  }
  
  Menu addModuleMenu(Module m, PVector p){
    activeMenu = new ModuleMenu(this, m); 
    activeMenu.setTargetPosition(p);
    return activeMenu;
  }
  
  Menu addModuleUIMenu(ModuleUI m, PVector p){
    activeMenu = new ModuleUIMenu(this, m);
    activeMenu.setTargetPosition(p);
    return activeMenu;
  }
  
  Menu addWindowMenu(PVector p){
    activeMenu = new WindowMenu(this, scope);
    activeMenu.setTargetPosition(p);
    return activeMenu;
  }
  
  void exitMenu(){
    activeMenu = null;
  }
  
  void onGlobalInputEvent(GlobalInputEvent e){
    stateMan.onInput(e);
  }
  
}
