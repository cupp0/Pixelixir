 void saveSketch(){
    
    String name = User.prompt("enter file name:", "");
  
    // Check if the user entered something and didn't cancel
    if (name != null && !name.isEmpty()) {
  
      // Save the input to a file
      String[] data = {gson.toJson(selectionManager.copyModules(windows.get(bigbang).modules))};
      saveStrings(sketchPath()+"/data/patches/"+name+".txt", data);
    } 
  }
  
  void loadSketch(){
    
    String name = User.prompt("enter file name:", "");
    
    if (name != null && !name.isEmpty()) {
      
      String filePath = dataPath("patches/"+name+".txt"); // For files within the Processing data folder
      File file = new File(filePath);
      if (file.exists()){
        String[] data = loadStrings(file);
        String appendedData = "";
        for (String s : data){ appendedData += s; }
        selectionManager.pasteModules(appendedData, currentWindow, new PVector(0, 0));
      } else {
        println("no such file");
      }
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
