//~SelectionManager
class SelectionManager{
  
  ArrayList<Module> modules = new ArrayList<Module>();            //what is selected
  ArrayList<Module> copiedModules = new ArrayList<Module>();      //stored for copy/paste and what not
  String clipboard;
  
  boolean containsModule(Module m){
    if (modules.contains(m)){return true;}
    return false;
  }

  //returns string representaion of selection
  WindowData copyModules(ArrayList<Module> mods) {
    WindowData wdata = new WindowData();
    
    //store module info
    for (Module m : mods) {
      
      //module name and id
      ModuleData mdata = new ModuleData();
      mdata.name = m.name;
      mdata.id = m.id;
      mdata.ins = m.ins.size();
      mdata.outs = m.outs.size();
      mdata.position = m.getBodyPosition();
      
      //info for each piece of UI that isn't default (so not ports, body)
      for (ModuleUI ui : m.uiBits){    
        if (ui.state instanceof DataBender){
          mdata.uiElements.add(ui.state); 
        }
      }
            
      // If this module has a subwindow (composite), recurse:      
      if (mdata.name.equals("composite")) {
        Window subWin = windows.get(m); 
        if (subWin != null){
          mdata.subwindow = copyModules(subWin.modules);
        }
      }
      wdata.modules.add(mdata);
    }
    
    //store connection info
    if (mods.size() > 0){  //could copy an empty composite
      Window where = mods.get(0).getWindow();
      for (Connection c : where.connections) {      
        if (mods.contains(c.source.parent) && mods.contains(c.destination.parent)) {
          ConnectionData cdata = new ConnectionData();
          cdata.fromModule = c.source.parent.id;
          cdata.fromPortIndex = c.source.index;
          cdata.toModule = c.destination.parent.id;
          cdata.toPortIndex = c.destination.index;
          wdata.connections.add(cdata);
        }
      }
    }
    
    clipboard = gson.toJson(wdata);
    //println(clipboard);
    return wdata;
  }
  
 
  //doing everything separately & recursively to keep everything isolated  and (hopefully) easier to maintain
  HashMap<String, Module> pasteModules(String json, Window where, PVector offset) {
    
    WindowData wdata = gson.fromJson(json, WindowData.class);
    
    //create mod/op pairs and any new windows. return a map from old Module.id -> new Module
    HashMap<String, Module> newMods = addModules(wdata, where, offset); 

    //rebuild ports
    rebuildPorts(wdata, newMods);
    
    //populate each new Module with the stored UI
    buildUI(wdata, newMods);  

    //only the outermost scope has a nonzero offset, typically based on where the cursor is on paste
    positionMods(wdata, newMods, offset);
        
    //rebuild connections
    rebuildConnections(wdata, newMods); 

    //update the graph that manages operation order
    graph.computeTopoSort();
    
    //tell every primitive data provider to update
    primer(newMods);
    
    return newMods;
  } 
  
  //this method creates the module/operator pairs, and returns a map from old module id to new module
  HashMap<String, Module> addModules(WindowData wdata, Window where, PVector offset){
    
    //WindowData wdata = gson.fromJson(json, WindowData.class);            //module data
    HashMap<String, Module> oldIdstoNewMods = new HashMap<String, Module>();  
    for (ModuleData mdata : wdata.modules) { 
      
      //build, position module, and update module map
      Module newMod = where.addModule(mdata.name); 
      newMod.drag(mdata.position);
      oldIdstoNewMods.put(mdata.id, newMod);

      if (newMod.isComposite()){
        //here, we recurse, adding all modules to the subwindow and appending the results to our id->module map.
        oldIdstoNewMods.putAll(addModules(mdata.subwindow, windows.get(newMod), new PVector(0, 0)));
      }
    }
    
    return oldIdstoNewMods;
  }
  
  //before building connections, we have to initialize ports. Some mods/ops can change PortUI count dynamically,
  //so we store PortUI count and create ports here (since we can't rely on default PortUI settings per mod/op
  void rebuildPorts(WindowData wdata, HashMap<String, Module> newMods){
    for (ModuleData mdata : wdata.modules){
      
      //let internal sends/receives build composite ports
      if (!mdata.name.equals("composite")){
        while(newMods.get(mdata.id).ins.size() < mdata.ins){
          newMods.get(mdata.id).owner.addInPork(DataCategory.UNKNOWN);
        }
        while(newMods.get(mdata.id).outs.size() < mdata.outs){
          newMods.get(mdata.id).owner.addOutPork(DataCategory.UNKNOWN);
        }
      } else {
        
        //if composite, recurse
        rebuildPorts(mdata.subwindow, newMods);
      }      
    }    
  }
  
  //adds DataBender UI elements to composites. Also copies UIState over to primitives
  //BodyUI is created in Module constructor. PortUI are created in rebuildPorts 
  //(Modules listen to their owners (Operator) and add ports iff owner does)
  void buildUI(WindowData wdata, HashMap<String, Module> newMods){
    
    for (ModuleData mdata : wdata.modules){
        
      //create UI on composites
      if (mdata.name.equals("composite")){
        for (UIState uis : mdata.uiElements){           
          ModuleUI newUI = (ModuleUI)partsFactory.createUI(uis.getType());
          ((DBUIState)newUI.state).copyData((DBUIState)uis);
          newMods.get(mdata.id).addUI(newUI);
        }
        
        //recurse and build UI inside
        buildUI(mdata.subwindow, newMods);
      } else {
        
        //if the code gets here, we are in a Primitive, which automatically add its
        //default UI upon creation, so we just have to copy the state data over
        //primitives can have at most 1 databender so this should be fine
        
        //better alternative is to not have primitive UI modules create their own UI by default
        for (UIState uis : mdata.uiElements){   //this will always be a databender
          for (ModuleUI ui : newMods.get(mdata.id).uiBits){
            if (ui.state instanceof DataBender){   //this is the target where we need to copy data over to
              ((DBUIState)ui.state).copyData((DBUIState)uis);
            }
          }
        }       
      }
      
      newMods.get(mdata.id).organizeUI();
    }
  }
  
  //add position offset to top layer modules (for copy/paste with mouse position). 
  //All other windows store module position in BodyUI.state 
  void positionMods(WindowData wdata, HashMap<String, Module> newMods, PVector offset){
       
    PVector tl = new PVector(Float.MAX_VALUE, Float.MAX_VALUE);
    for (ModuleData mdata : wdata.modules){
      tl.set(min(tl.x, mdata.position.x), min(tl.y, mdata.position.y));
    }
    for (ModuleData mdata : wdata.modules){
      newMods.get(mdata.id).uiBits.get(0).setPosition(mdata.position);
      newMods.get(mdata.id).uiBits.get(0).drag(PVector.sub(offset,tl));
      
      if (newMods.get(mdata.id).isComposite() && mdata.subwindow != null){
        positionMods(mdata.subwindow, newMods, new PVector(0, 0));
      }
    }

  }
  
  //have to build connections inside out, since some ops have dynamic ports.
  //for instance, building a connection on a send or receive inside a composite
  //can add a port to that composite. 
  
  //strategy: If connection is between primitives, send it. If there is a composite
  //involved, recurse on that composite first.
  void rebuildConnections(WindowData wdata, HashMap<String, Module> newMods){
    
    // Rebuild connections
    for (ConnectionData cdata : wdata.connections) {
      Window where = windows.get(newMods.get(cdata.fromModule).parent);
      
      //the two modules we are attempting to connect
      Module srcMod  = newMods.get(cdata.fromModule);
      Module destMod  = newMods.get(cdata.toModule);
      
      //if either are composite, recurse before building the connection
      if (srcMod.isComposite()){
        for (ModuleData mdata : wdata.modules){
          
          //find the correct module 
          Module comparison = newMods.get(mdata.id);
          if (srcMod == comparison){
            rebuildConnections(mdata.subwindow, newMods);
          }
        }
      }
      
      //repeat the process for the desitnation mod
      if (destMod.isComposite()){
        for (ModuleData mdata : wdata.modules){
          Module comparison = newMods.get(mdata.id);
          if (destMod == comparison){
            rebuildConnections(mdata.subwindow, newMods);
          }
        }
      }

      //build the connection
      OutPortUI src = newMods.get(cdata.fromModule).outs.get(cdata.fromPortIndex);
      InPortUI dest = newMods.get(cdata.toModule).ins.get(cdata.toPortIndex);
      where.attemptConnection(src, dest);
    }
    
    //find any composite and rebuild those connections too
    for (ModuleData mdata : wdata.modules){
      if (mdata.name.equals("composite")){
        rebuildConnections(mdata.subwindow, newMods);
      }
    }
  }
  
  //push an update to any newly created data sources
  void primer(HashMap<String, Module> newMods){
    for (String s : newMods.keySet()){
      if (newMods.get(s).owner instanceof UIOperator){
        for (ModuleUI ui : newMods.get(s).uiBits){
          if (ui.state instanceof DataBender){
            ((DataBender)ui.state).tryUpdateOperator();
          }
        }
      }
    }
  }
  
  void moveSelection(ArrayList<Module> mods, Window origin, Window destination){
    
    //collected associated connections
    ArrayList<Connection> cons = new ArrayList<Connection>();
    for (Connection c : origin.connections){
      
      //if source and destination ar in mods, cue connection for the move
      if (mods.contains(c.source.parent) && mods.contains(c.destination.parent)){
        cons.add(c);
      }  else {   
        //if one or the other, remove the connection from the graph
        if (mods.contains(c.source.parent)){
          origin.removeConnection(c);
        }
        if (mods.contains(c.destination.parent)){
          origin.removeConnection(c);
        }
      }
      
    }
    
    //remove UI elements from origin 
    for (int i = origin.modules.size()-1; i >= 0; i--){
      if (mods.contains(origin.modules.get(i))){
        origin.deregisterModule(origin.modules.get(i)); 
      }
    }
    for (int i = origin.connections.size()-1; i >= 0; i--){
      if (cons.contains(origin.connections.get(i))){
        origin.connections.remove(origin.connections.get(i)); 
      }
    }
    
    //add UI to new Window
    for (Module m : mods){
      destination.registerModule(m);  
    }
    for (Connection c : cons){
      destination.connections.add(c);  
    }
  }

  //clear stored selection 
  void clearSelection(){
    modules.clear();
  }
  
  void addTo(Module m){
    if (!modules.contains(m)){
      modules.add(m);
    }
  }
  
  void drag(PVector amount){
    for (Module m : modules){
      m.uiBits.get(0).drag(amount);
    }
  }
  
  //remove connections, remove modules, remove windows
  void onBackSpace(){
    
    Window w = currentWindow;   
    for (int i = w.connections.size()-1; i >= 0; i--){    
      if (this.modules.contains(w.connections.get(i).source.parent) || this.modules.contains(w.connections.get(i).destination.parent)){
        w.removeConnection(w.connections.get(i));
      }    
    } 
    
    for (int i = this.modules.size()-1; i >= 0; i--){
      w.deregisterModule(this.modules.get(i));
      if (this.modules.get(i).isComposite()){
        windows.remove(this.modules.get(i));
      }
    }
    
    modules.clear();
  }
  
  PVector copiedPosition(Module m){
    PVector topLeft = topLeft(copiedModules).copy();
    PVector maus = currentWindow.cam.toWorld(new PVector (mouseX, mouseY)).copy();
    PVector mPos = m.uiBits.get(0).state.pos.copy().sub(topLeft);
    return mPos.add(maus);
  }
  
  //returns average position of selected modules
  PVector avgModPos(ArrayList<Module> mods){
    PVector p = new PVector(0, 0);
    int count = 0;
    for (Module m : mods){
      p.add(m.uiBits.get(0).state.pos);
      count++;
    }
    return p.div(count);
  }
  
  //returns the toppest leftest of whatever is selected
  PVector topLeft(ArrayList<Module> modList){
    List<Float> xList = new ArrayList<>();
    List<Float> yList = new ArrayList<>();

    for (Module m : modList){
      xList.add(m.uiBits.get(0).state.pos.x);
      yList.add(m.uiBits.get(0).state.pos.y);
    }
    
    return new PVector(Collections.min(xList), Collections.min(yList));    
  }
  
}
