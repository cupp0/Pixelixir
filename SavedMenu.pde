//~SavedMenu
//menu of saved patches found in data folder
class SavedMenu extends Menu<Window>{
  
  int menuId;
  ModuleTypeMenu immediateParent;
  
  SavedMenu(MenuListener ml, Window w, int menuId_, ModuleTypeMenu mtm){
    super(ml, w); immediateParent = mtm; menuId = menuId_; 
    build(); // subclass defines options
  }

  void build() {
    File folder = new File(dataPath("patches/")); // Replace with your path
    File[] listOfFiles = folder.listFiles();
    for (int i = 0; i < listOfFiles.length; i++){
      options.add(new MenuOption(this, listOfFiles[i].getName(), i) {
        void execute() { 
          File file = new File(dataPath("patches/"+label));
          if (file.exists()){
            String[] data = loadStrings(file);
            String appendedData = "";
            for (String s : data){ appendedData += s; }
            selectionManager.pasteModules(appendedData, currentWindow, currentWindow.cam.toWorld(getRootMenu().pos.copy()));
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
