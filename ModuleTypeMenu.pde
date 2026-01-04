//~ModuleTypeMenu
class ModuleTypeMenu extends Menu<Window>{
  
  //boolean moduleAdded = false;    
  
  ModuleTypeMenu(MenuListener ml, Window w, PVector p){
    super(ml, w, p);
    build(); // subclass defines options
  }

  void build() {
    addRetreatOption(this, new WindowMenu(listener, ((WindowManager)listener).scope, pos));
    for (int i = 0; i < UIText.length; i++){
      options.add(new MenuOption(this, UIText[i][0], i+1) {
        void execute() { 
          listener.switchMenu(new CustomMenu(listener, (Window)target, this.index-1, (ModuleTypeMenu)parent, pos), parent.pos);
        }
      });
    }
    
    options.add(new MenuOption(this, "SAVED", options.size()) {
      void execute() { 
        listener.switchMenu(new SavedMenu(listener, (Window)target,/* this.index,*/ pos), parent.pos);
      }
    });
  }
  
  Window getWindow(){
    return (Window)target;
  }

}
