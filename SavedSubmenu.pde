//~SavedMenu
//menu of saved patches found in data folder
class SavedSubmenu extends Menu<Window>{
  
  int menuId;
  ModuleTypeMenu immediateParent;
  String subfolder;
  
  SavedSubmenu(MenuListener ml, Window w, int menuId_, PVector p, String subfolder_){
    super(ml, w, p); menuId = menuId_; subfolder = subfolder_;
    build(); // subclass defines options
  }

  void build() {
    addRetreatOption(this, new SavedMenu(listener, ((WindowManager)listener).scope, pos));
    File folder = new File(dataPath("patches/"+subfolder+"/")); 
    File[] listOfFiles = folder.listFiles();
    for (int i = 0; i < listOfFiles.length; i++){
      options.add(new MenuOption(this, listOfFiles[i].getName(), i+1) {
        void execute() { 
          File file = new File(dataPath("patches/"+subfolder+"/"+label));
          if (file.exists()){
            String[] data = loadStrings(file);
            String appendedData = "";
            for (String s : data){ appendedData += s; }
            selectionManager.pasteModules(appendedData, currentWindow, currentWindow.cam.toWorld(pos.copy()));
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
