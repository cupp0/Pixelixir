//~ModuleMenu
class ModuleMenu extends Menu<Module>{
  
  ModuleMenu(MenuListener ml, Module m, PVector p){
    super(ml, m, p);
    build(); // subclass defines options
  }

  void build() {
    options.add(new MenuOption(this, "copy", 0) {
      void execute() {
        selectionManager.copyModules(selectionManager.modules);
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
          listener.switchMenu(new CompositeUIMenu(listener, (Module)target, pos), parent.pos);
        }
      });
    }
  }
  
  Window getWindow(){
    return ((Module)target).getWindow();
  }
}
