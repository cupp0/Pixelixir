 void saveSketch(){
   File patchesRoot = new File(sketchPath("data/patches"));
   File projectDir = User.promptSaveProjectDir(patchesRoot, "untitled");
   
   if (projectDir != null) {
     println(projectDir.getAbsolutePath());
     // savePatch(projectDir);
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
      if(identityManager.identityGroupExists(s.identityToken)){
        identityManager.renameGroup(s.identityToken, name);
      }
    }
  }
  
  void nameModule(Module m){
    println(m.userLabel);
    String name = User.prompt("enter module name:", "");
  
    if (name != null && !name.isEmpty()) {
      m.setUserLabel(name);
    }
  }
