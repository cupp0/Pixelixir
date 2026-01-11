//~ModuleTypeMenu
class ModuleTypeMenu extends Menu<Window>{
  
  //boolean moduleAdded = false;    
  
  ModuleTypeMenu(MenuListener ml, Window w){
    super(ml, w);
    addOptions();
  }

  void addOptions() {
    addRetreatOption(this, new WindowMenu(listener, ((WindowMan)listener).scope));
    for (int i = 0; i < UIText.length; i++){
      options.add(new MenuOption(this, UIText[i][0], i+1) {
        void execute() { 
          listener.switchMenu(new CustomMenu(listener, (Window)target, this.index-1), parent.targetPos);
        }
      });
    }
    
    options.add(new MenuOption(this, "SAVED", options.size()) {
      void execute() { 
        listener.switchMenu(new SavedMenu(listener, (Window)target), parent.targetPos);
      }
    });
  }
  
  Window getWindow(){
    return (Window)target;
  }

}
