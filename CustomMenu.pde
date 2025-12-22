//~CustomMenu
//for building add module submenus
class CustomMenu extends Menu<Window>{
  
  int menuId;
  ModuleTypeMenu immediateParent;
  
  CustomMenu(MenuListener ml, Window w, int menuId_, ModuleTypeMenu mtm){
    super(ml, w); immediateParent = mtm; menuId = menuId_; 
    build(); // subclass defines options
  }

  void build() {
    for (int i = 0; i < UIText[menuId].length-1; i++){  
      options.add(new MenuOption(this, UIText[menuId][i+1], i) {
        void execute() {         
          Module m = ((WindowManager)listener).scope.addModule(this.label);
          m.setBodyPosition(immediateParent.cursor);
          immediateParent.cursor = ((Window)target).spawnCursor.copy();
        }
      });
    }
  }
  
  Window getWindow(){
    return (Window)target;
  }
}
