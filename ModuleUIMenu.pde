//~ModuleUIMenu
class ModuleUIMenu extends Menu<ModuleUI>{
  ModuleUIMenu(MenuListener ml, ModuleUI ui){
    super(ml, ui);
    build(); // subclass defines options
  }

  void build() {
    options.add(new MenuOption(this, "set identity", 0) {
      void execute() {
        DBUIState s = (DBUIState)((ModuleUI)target).state;
        nameUI(s);
        listener.onMenuExecution(parent);
      }
    });
    
    options.add(new MenuOption(this, "rename group", 1) {
      void execute() {
        DBUIState s = (DBUIState)((ModuleUI)target).state;
        renameUIGroup(s);
        listener.onMenuExecution(parent);
      }
    });
    
    options.add(new MenuOption(this, "remove ui", 2) {
      void execute() {
        ModuleUI ui = (ModuleUI)target;
        ui.parent.removeUI(ui);
        listener.onMenuExecution(parent);
      }
    });
  }
  
  Window getWindow(){
    return ((ModuleUI)target).parent.getWindow();
  }
}
