//~Window
class Window {
  
  // ~ ~ ~ MANAGERS ~ ~ ~ //
  WindowManager windowManager;
  EventManager eventManager;
  
  // ~ ~ ~ DATA/ROUTING ~ ~ ~ //
  Module boundary;                                           //the module we are looking inside of
  ArrayList<Module> modules = new ArrayList<>();             //the UI that represents our operator's juicy innards
  ArrayList<Connection> connections = new ArrayList<>();     //ui class for edges
  BiMap portMap = new BiMap();                               //Port / pork bimap 
  
  // ~ ~ ~ DISPLAY ~ ~ ~ //
  color col;
  Camera cam;
  
  //these two should probably be a part of some Overlays layer along with menus in WindowManager
  ConnectionLine connectionLine;
  SelectionRectangle selectionRectangle;                                                  
  PVector spawnCursor = new PVector(200, 200);              //where we spawn the next module underdefault conditions                                          
  
  Window(Module from){
    boundary = from;
    windowManager = new WindowManager(this);
    eventManager = new EventManager(this);
    cam = new Camera(this);
    col = color (25+random(100), 75 + random(100), 125 + random(100));
  } 
  
  void onHumanEvent(HumanEvent e){
    eventManager.handle(e);
  }

  void display(){    
    background(col);
    noiseGen.stepColor(); 
    cam.update();
    
    pushMatrix();
    translate(cam.xOff, cam.yOff);
    scale(cam.scl);
    for (Module m : modules) {
      m.display();
      displayConnections(m);
    }    
    displayAnimations();  
    popMatrix();
    
    for (Menu m : windowManager.activeMenus){
      m.display();
    };
  }
  
  void displayAnimations(){
    if (selectionRectangle != null){
      selectionRectangle.display(windowManager.getCurrentMouse());
    }
    if (connectionLine != null){
      connectionLine.display(windowManager.getCurrentMouse());
    }
  }
  
  //returns the address of the boundary
  String getAddress(){
    return this.toString().substring(this.toString().indexOf('@'));
  }
  
  ArrayList<Module> getModulesInside(PVector tl, PVector br){
    
    ArrayList<Module> mods = new ArrayList<Module>();
    for (Module m : modules){
      if (isInside(m.getBodyPosition(), tl, br)){
        mods.add(m);
      }
    }
    
    return mods;
  }
    
  //need to set the new window's offset wherever the mouse is so we are always zooming in/out on/from
  //the center of the window
  void setWindow(Module whichOne, boolean isZoomingIn){
    selectionManager.clearSelection();
    
    currentWindow = windows.get(whichOne);
    if (isZoomingIn){
      currentWindow.cam.setCamOnCompositeZoom();
    }
  }
  
  void attemptConnection(OutPortUI src, InPortUI dest, DataAccess da){
    
    OutPork srcPork = ((OutPork)portMap.getPork(src));
    InPork destPork = ((InPork)portMap.getPork(dest));
    
    //determine if the ports have compatible access requirements (a read only out can't be plugged into an in that wants to write)
    //access resolution could be static
    DataAccess accessRequirement = srcPork.resolveDataAccess(destPork, da);
    
    if (accessRequirement == DataAccess.NONE){
      println("one wants to read, one wants to write. One thing's for sure, they don't want to fight");
      println("The port access requirements are incompatible with the edge type you attempted. try a READONLY edge (left click)");
      return;
    }
    
    //are the data types compatible (float vs text, etc)
    boolean compatibleDataType = Flow.compatible(srcPork.getCurrentDataCategory(), destPork.getCurrentDataCategory());
    
    if (!compatibleDataType){
      println("if you try to STRING a LIST to a BOOL's tail, you'll soon NUMERIC away to heaven (that connection's a fail)");
      return;
    }
    
    //if compatible, set both ports to the resolved access requirement, then build the connection
    srcPork.setCurrentAccess(accessRequirement);
    destPork.setCurrentAccess(accessRequirement);
    
    buildConnection(src, dest, accessRequirement);
  }

  //add edge to the graph, visible in this window, update references in porks, update listeners
  void buildConnection(OutPortUI src, InPortUI dest, DataAccess da){
    
    //corresponding data ports
    OutPork srcPork = ((OutPork)portMap.getPork(src));
    InPork destPork = ((InPork)portMap.getPork(dest));
    
    //add connection, both in UI land and Data land
    connections.add(new Connection(src, dest, da));
    graph.addEdge(srcPork, destPork, da); 
    
    //if the newly connected outport has data
    if (srcPork.targetFlow != null){
      ((OutPork)portMap.getPork(src)).dataNotification();
    }
  }
  
  //remove edge from graph, update pork reference, remove edge UI
  void removeConnection(Connection c){
    connections.remove(c);
    graph.removeEdge(graph.getEdge(this, c));    
  }
  
  //display cables
  void displayConnections(Module from){    
    for (Connection c : connections){
      if (c.source.parent == from){
        c.display();
      }
    }
  }
 
  void addConnectionLine(OutPortUI where){
    connectionLine = new ConnectionLine(where);
  } 
  
  void removeConnectionLine(){
    connectionLine = null;
  }
  
  void addSelectionRectangle(HumanEvent e){
    selectionRectangle = new SelectionRectangle(new PVector(e.xMouse, e.yMouse));
  }
  
  void removeSelectionRectangle(){
    selectionRectangle = null;
  }
  
  //registering module with window includes
  //setting the parent, 
  //registering ports with portMap
  //appending to modules
  Module addModule(String what){
   
    //create the module, operator, and default UI
    Module newMod = partsFactory.createModule(what);
    
    //sets pos of BodyUIState
    setDefaultPosition(newMod);
    
    //sets up ports, update graph
    if (!newMod.isComposite()){
      newMod.owner.initialize();
      newMod.owner.setDefaultDataAccess();
      graph.addOperator(newMod.owner);
    }
    
    //arranges module UI
    newMod.organizeUI();
    
    updateSpawnPosition(newMod);
    
    registerModule(newMod);
  
    return newMod;
  }
  
  void registerModule(Module m){
    //store the object at the window level
    modules.add(m);
    m.setParent(this.boundary);
    registerPorts(m);
    if (m.owner instanceof ReceiveOperator || m.owner instanceof SendOperator){
      m.owner.tryExposingHiddenPorts();
    }
  }
  
  void registerPorts(Module m){
    for (InPortUI i : m.ins){
      this.portMap.put(i, i.pair);
    }
    for (OutPortUI o : m.outs){
      this.portMap.put(o, o.pair);
    } 
  }
  
  void deregisterModule(Module m){
    //store the object at the window level
    modules.remove(m);
    m.setParent(null);
    deregisterPorts(m);
  }
  
  void deregisterPorts(Module m){
    for (InPortUI i : m.ins){
      this.portMap.removeUI(i);
    }
    for (OutPortUI o : m.outs){
      this.portMap.removeUI(o);
    }   
  }
  
  //sets to spawn below the argument module
  void updateSpawnPosition(Module m){
    spawnCursor = PVector.add(m.getBodyPosition(), new PVector(0, m.uiBits.get(0).size.y+16));
  }
  
  //just stores objects, doesn't build any UI or position anything
  Module storeModule(Module mod){
    
    //add Operator to the boundary of this window
    //boundary.addKid(mod.owner);
    
    //store module
    modules.add(mod);
    
    return mod;
  }
  
  void initializeModule(Module m){
    //initialize operator / module pair
    m.initializeUI();
    m.owner.initialize();
  }
  
  void setDefaultPosition(Module m){
    ((BodyUI)m.uiBits.get(0)).setPosition(spawnCursor);
  }
  
  void dragModules(ArrayList<Module> mods, HumanEvent e){
    PVector amount = new PVector(e.xMouse - e.pxMouse, e.yMouse - e.pyMouse);
    for (Module m : mods){
      m.drag(amount);
    }
  }
  
  void addPortToMap(PortUI p){
    if (p instanceof InPortUI){
      portMap.put(p, p.parent.owner.ins.get(p.index));
    }
    
    if (p instanceof OutPortUI){
      portMap.put(p, p.parent.owner.outs.get(p.index));
    } 
  }
  
  ModuleUI getUIByID(String theID){
    for (Module m : modules){
      for (ModuleUI ui : m.uiBits){
        if (ui.id.equals(theID)){
          return ui;
        }
      }
    }
    return null;
  }
  
  Module getModuleByOperator(Operator op){
    for (Module m : modules){
      if (m.owner == op){
        return m;
      }
    }
    return null;
  }
  
  
  //returns average position of all modules
  PVector avgModPos(){
    PVector p = new PVector(0, 0);
    int count = 0;
    for (Module m : modules){
      p.add(m.uiBits.get(0).state.pos);
      count++;
    }
    return p.div(count);
  }
  
  void setColor(color c){
    col = c;
  }
  
  color getColor(){
    return col;
  }
   
  PVector getCursor(){
    return spawnCursor; 
  }
  
  void setCursor(PVector p){
    spawnCursor.set(p);
  }
}
