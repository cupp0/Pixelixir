 void saveSketch(){
   File patchesRoot = new File(sketchPath("data/patches"));
   File projectDir = User.promptSaveProjectDir(patchesRoot, "untitled");
   // Check if the user entered something and didn't cancel
    if (projectDir != null) {
  
      // Save the input to a file
      String[] data = {gson.toJson(bigbang.windowMan.stateMan.selectionMan.copyModules(bigbang.modules))};
      saveStrings(projectDir, data);
    } 
  }
  
  void nameUI(DBUIState s){
    String name = User.prompt("enter ui name:", s.identityToken);
  
    if (name != null && !name.isEmpty()) {
      s.trySetIdentityToken(name);
    }
  }
  
  void renameUIGroup(DBUIState s){
    String name = User.prompt("enter ui name:", s.identityToken);
  
    if (name != null && !name.isEmpty()) {
      if(identityMan.identityGroupExists(s.identityToken)){
        identityMan.renameGroup(s.identityToken, name);
      }
    }
  }
  
  void nameModule(Module m){
    String name = User.prompt("enter module name:", "");
  
    if (name != null && !name.isEmpty()) {
      m.setUserLabel(name);
    }
  }
