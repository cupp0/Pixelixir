//~SavedMenu
//menu of saved patches found in data folder
class SavedMenu extends Menu<Window>{
  
  int menuId;
  ModuleTypeMenu immediateParent;
  
  SavedMenu(MenuListener ml, Window w){
    super(ml, w);// menuId = menuId_; 
    addOptions();
  }

  void addOptions() {
    addRetreatOption(this, new ModuleTypeMenu(listener, ((WindowMan)listener).scope));
    File folder = new File(dataPath("patches/")); 
    File[] listOfFiles = folder.listFiles();
    for (int i = 0; i < listOfFiles.length; i++){
      options.add(new MenuOption(this, listOfFiles[i].getName(), i+1) {
        void execute() { 
          listener.switchMenu(new SavedSubmenu(listener, (Window)target, this.index, label), parent.targetPos);
        }
      });
    }
  }
  
  Window getWindow(){
    return (Window)target;
  }
}
