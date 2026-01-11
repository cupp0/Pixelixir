//~ModuleMenu
class ModuleMenu extends Menu<Module>{
  
  ModuleMenu(MenuListener ml, Module m){
    super(ml, m);
    addOptions(); 
  }

  void addOptions() {
    options.add(new MenuOption(this, "copy", 0) {
      void execute() {
        SelectionMan sm = ((WindowMan)listener).stateMan.selectionMan;
        sm.copyModules(sm.modules);
        listener.exitMenu();
      }
    });
    
    options.add(new MenuOption(this, "set name", 1) {
      void execute() {
        nameModule(target);
        listener.exitMenu();
      }
    });
    
    if (((Module)target).composition == Composition.MANY){
      options.add(new MenuOption(this, "add ui", 2) {
        void execute() {
          listener.switchMenu(new CompositeUIMenu(listener, (Module)target), parent.targetPos);
        }
      });
    }
  }
  
  Window getWindow(){
    return ((Module)target).getWindow();
  }
}
