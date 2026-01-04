//~SavedMenu
//menu of saved patches found in data folder
class SavedMenu extends Menu<Window>{
  
  int menuId;
  ModuleTypeMenu immediateParent;
  
  SavedMenu(MenuListener ml, Window w, PVector p){
    super(ml, w, p);// menuId = menuId_; 
    build(); // subclass defines options
  }

  void build() {
    addRetreatOption(this, new ModuleTypeMenu(listener, ((WindowManager)listener).scope, pos));
    File folder = new File(dataPath("patches/")); 
    File[] listOfFiles = folder.listFiles();
    for (int i = 0; i < listOfFiles.length; i++){
      options.add(new MenuOption(this, listOfFiles[i].getName(), i+1) {
        void execute() { 
          listener.switchMenu(new SavedSubmenu(listener, (Window)target, this.index, pos, label), parent.pos);
        }
      });
    }
  }
  
  Window getWindow(){
    return (Window)target;
  }
}
