//~CustomMenu
//for building add module submenus
class CustomMenu extends Menu<Window>{
  
  int menuId;
  
  CustomMenu(MenuListener ml, Window w, int menuId_){
    super(ml, w);
    menuId = menuId_; 
    addOptions(); 
  }

  void addOptions() {
    addRetreatOption(this, new ModuleTypeMenu(listener, ((WindowMan)listener).scope));
    for (int i = 0; i < UIText[menuId].length-1; i++){  
      options.add(new MenuOption(this, UIText[menuId][i+1], i+1) {
        void execute() {      
          Module last = ((WindowMan)listener).lastSpawned;
          Module m = ((WindowMan)listener).scope.addModule(this.label);
          InputState state = ((WindowMan)listener).stateMan.inputMan.state;
          
          if (state.isDown('W')){
            m.setBodyPosition(PVector.sub(last.getBodyPosition(), new PVector(0, m.uiBits.get(0).size.y + 16))); 
          }
          if (state.isDown('A')){
            m.setBodyPosition(PVector.sub(last.getBodyPosition(), new PVector(m.uiBits.get(0).size.x + 16, 0))); 
          }
          if (state.isDown('S')){
            m.setBodyPosition(PVector.add(last.getBodyPosition(), new PVector(0, m.uiBits.get(0).size.y + 16))); 
          }
          if (state.isDown('D')){
            m.setBodyPosition(PVector.add(last.getBodyPosition(), new PVector(m.uiBits.get(0).size.x + 16, 0))); 
          }
        }
      });
    }
  }
  
  Window getWindow(){
    return (Window)target;
  }
}
