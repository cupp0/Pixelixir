//~ModuleTypeMenu
class ModuleTypeMenu extends Menu<Window>{
  
  PVector cursor;                  //for determining module spawn position
  boolean moduleAdded = false;    
  
  ModuleTypeMenu(MenuListener ml, Window w){
    super(ml, w); cursor = currentWindow.cam.toWorld(getRootMenu().pos.copy());
    build(); // subclass defines options
  }

  void build() {
    for (int i = 0; i < UIText.length; i++){
      options.add(new MenuOption(this, UIText[i][0], i) {
        void execute() { 
          addSubmenu(new CustomMenu(listener, (Window)target, this.index, (ModuleTypeMenu)parent), this.index);
        }
      });
    }
    
    options.add(new MenuOption(this, "SAVED", options.size()) {
      void execute() { 
        addSubmenu(new SavedMenu(listener, (Window)target, this.index, (ModuleTypeMenu)parent), this.index);
      }
    });
  }
  
  Window getWindow(){
    return (Window)target;
  }
  
  PVector getCursor(){
    return cursor;
  }
  
  void setCursor(PVector p){
    cursor.set(p); 
  }
}
