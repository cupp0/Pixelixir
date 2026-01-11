//WindowMenu
class WindowMenu extends Menu<Window>{
  
  WindowMenu(MenuListener ml, Window w){
    super(ml, w);
    addOptions();
  }

  void addOptions() {
    
    options.add(new MenuOption(this, "add modules", 0) {
      void execute() {
        listener.switchMenu(new ModuleTypeMenu(listener, (Window)target), parent.targetPos);
      }
    });
    
    int count = 1; 
    SelectionMan sm = ((WindowMan)listener).stateMan.selectionMan;
    if (sm.modules.size() > 0){
      options.add(new MenuOption(this, "copy", count) {
        void execute() {
          sm.copyModules(sm.modules);
          listener.exitMenu();
        }
      });
      count++;
    }
    
    if (sm.clipboard != null){
      options.add(new MenuOption(this, "paste", count) {
        void execute() {
          sm.pasteModules(sm.clipboard, (Window)target, currentWindow.windowMan.stateMan.cam.toWorld(parent.targetPos.copy()));
          listener.exitMenu();
        }
      });
      count++;
      
      options.add(new MenuOption(this, "paste with new id", count) {
        void execute() {
          HashMap<String, Module> newMods = sm.pasteModules(sm.clipboard, (Window)target, currentWindow.windowMan.stateMan.cam.toWorld(parent.targetPos.copy()));       
          HashMap<String, String> newIds = new HashMap<String, String>();
          
          for (Module m : newMods.values()){
            for (ModuleUI ui : m.uiBits){
              if (ui.state instanceof DBUIState){
                DBUIState db = (DBUIState)ui.state;
                if (newIds.containsKey(db.getIdentityToken())){
                  db.trySetIdentityToken(newIds.get(db.getIdentityToken()));
                } else {
                  String oldId = db.getIdentityToken();
                  String newId = UUID.randomUUID().toString();
                  newIds.put(oldId, newId);
                  db.trySetIdentityToken(newId);
                }
              }
            }
          }
          
          listener.exitMenu();
        }
      });
      count++;
    }
  }
  
  Window getWindow(){
    return (Window)target;
  }
}
