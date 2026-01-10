//~CustomMenu
//for building add module submenus
class CustomMenu extends Menu<Window>{
  
  int menuId;
  ModuleTypeMenu immediateParent;
  
  CustomMenu(MenuListener ml, Window w, int menuId_, ModuleTypeMenu mtm, PVector pos_){
    super(ml, w, pos_); immediateParent = mtm; menuId = menuId_; 
    build(); // subclass defines options
  }

  void build() {
    addRetreatOption(this, new ModuleTypeMenu(listener, ((WindowMan)listener).scope, pos));
    for (int i = 0; i < UIText[menuId].length-1; i++){  
      options.add(new MenuOption(this, UIText[menuId][i+1], i+1) {
        void execute() {         
          Module m = ((WindowMan)listener).scope.addModule(this.label);
        }
      });
    }
  }
  
  Window getWindow(){
    return (Window)target;
  }
}
