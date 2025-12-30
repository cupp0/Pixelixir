//~ModuleMenu
class ModuleMenu extends Menu<Module>{
  
  ModuleMenu(MenuListener ml, Module m){
    super(ml, m);
    build(); // subclass defines options
  }

  void build() {
    options.add(new MenuOption(this, "copy", 0) {
      void execute() {
        selectionManager.copyModules(selectionManager.modules);
        listener.onMenuExecution(parent);
      }
    });
    
    if (((Module)target).composition == Composition.MANY){
      options.add(new MenuOption(this, "add ui", 1) {
        void execute() {
          addSubmenu(new CompositeUIMenu(listener, (Module)target), this.index);
        }
      });
    }
  }
  
  Window getWindow(){
    return ((Module)target).getWindow();
  }
}
