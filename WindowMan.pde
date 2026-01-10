//~WindowMan

class WindowMan implements MenuListener, GlobalEventListener{
  
  Window scope;
  StateMan stateMan;
  StyleResolver styleResolver;
  Menu activeMenu;
    
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
    activeMenu.setPosition(p);
  }
  
  Menu addModuleMenu(Module m, PVector p){
    activeMenu = new ModuleMenu(this, m, p); 
    return activeMenu;
  }
  
  Menu addModuleUIMenu(ModuleUI m, PVector p){
    activeMenu = new ModuleUIMenu(this, m, p);
    return activeMenu;
  }
  
  Menu addWindowMenu(PVector p){
    activeMenu = new WindowMenu(this, scope, p);
    return activeMenu;
  }
  
  void exitMenu(){
    activeMenu = null;
  }
  
  void onGlobalInputEvent(GlobalInputEvent e){
    stateMan.onInput(e);
  }
  
}
