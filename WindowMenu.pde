//WindowMenu
class WindowMenu extends Menu<Window>{
  
  WindowMenu(MenuListener ml, Window w, PVector p){
    super(ml, w, p);
    build(); // subclass defines options
  }

  void build() {
    
    options.add(new MenuOption(this, "add modules", 0) {
      void execute() {
        listener.switchMenu(new ModuleTypeMenu(listener, (Window)target, parent.pos), parent.pos);
      }
    });
    
    int count = 1; 
    if (selectionManager.modules.size() > 0){
      options.add(new MenuOption(this, "copy", count) {
        void execute() {
          selectionManager.copyModules(selectionManager.modules);
          listener.exitMenu();
        }
      });
      count++;
    }
    
    if (selectionManager.clipboard != null){
      options.add(new MenuOption(this, "paste", count) {
        void execute() {
          selectionManager.pasteModules(selectionManager.clipboard, (Window)target, currentWindow.cam.toWorld(parent.pos.copy()));
          listener.exitMenu();
        }
      });
      count++;
      
      options.add(new MenuOption(this, "paste with new id", count) {
        void execute() {
          HashMap<String, Module> newMods = selectionManager.pasteModules(selectionManager.clipboard, (Window)target, currentWindow.cam.toWorld(parent.pos.copy()));       
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
