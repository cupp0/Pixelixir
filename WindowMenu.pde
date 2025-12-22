//WindowMenu
class WindowMenu extends Menu<Window>{
  
  WindowMenu(MenuListener ml, Window w){
    super(ml, w);
    build(); // subclass defines options
  }

  void build() {
    options.add(new MenuOption(this, "add modules", 0) {
      void execute() {
        addSubmenu(new ModuleTypeMenu(listener, (Window)target), this.index);
      }
    });
    
    if (selectionManager.modules.size() > 0){
      options.add(new MenuOption(this, "copy", 1) {
        void execute() {
          selectionManager.copyModules(selectionManager.modules);
          listener.onMenuExecution(parent);
        }
      });
    }
    
    if (selectionManager.clipboard != null){
      options.add(new MenuOption(this, "paste", 2) {
        void execute() {
          selectionManager.pasteModules(selectionManager.clipboard, (Window)target, parent.pos);
          listener.onMenuExecution(parent);
        }
      });
      
      options.add(new MenuOption(this, "paste with new id", 3) {
        void execute() {
          HashMap<String, Module> newMods = selectionManager.pasteModules(selectionManager.clipboard, (Window)target, parent.pos);       
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
          
          listener.onMenuExecution(parent);
        }
      });
    }
    
    if (currentWindow.boundary != bigbang){
      options.add(new MenuOption(this, "zoom out", 4) {
        void execute() {
          Operator oneOpOut = ((Window)target).windowManager.scope.boundary.parent;
          if (oneOpOut != null){
            currentWindow.setWindow(oneOpOut, false);
          }
          listener.onMenuExecution(parent);
        }
      });
    }
  }
  
  Window getWindow(){
    return (Window)target;
  }
}
