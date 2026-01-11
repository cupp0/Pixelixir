//~SavedMenu
//menu of saved patches found in data folder
class SavedSubmenu extends Menu<Window>{
  
  int menuId;
  String subfolder;
  
  SavedSubmenu(MenuListener ml, Window w, int menuId_, String subfolder_){
    super(ml, w); menuId = menuId_; subfolder = subfolder_;
    addOptions();
  }

  void addOptions() {
    addRetreatOption(this, new SavedMenu(listener, ((WindowMan)listener).scope));
    File folder = new File(dataPath("patches/"+subfolder+"/")); 
    File[] listOfFiles = folder.listFiles();
    for (int i = 0; i < listOfFiles.length; i++){
      options.add(new MenuOption(this, listOfFiles[i].getName(), i+1) {
        void execute() { 
          File file = new File(dataPath("patches/"+subfolder+"/"+label));
          if (file.exists()){
            SelectionMan sm = ((WindowMan)listener).stateMan.selectionMan;
            String[] data = loadStrings(file);
            String appendedData = "";
            for (String s : data){ appendedData += s; }
            sm.pasteModules(appendedData, currentWindow, currentWindow.windowMan.stateMan.cam.toWorld(pos.copy()));
          } else {
            println("no such file");
          }
        }
      });
    }
  }
  
  Window getWindow(){
    return (Window)target;
  }
}
