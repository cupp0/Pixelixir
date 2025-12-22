//~Window
class Window{
  
  // ~ ~ ~ MANAGERS ~ ~ ~ //
  WindowManager windowManager;
  EventManager eventManager;
  
  // ~ ~ ~ DATA/ROUTING ~ ~ ~ //
  CompositeOperator boundary;                                //the delicious operator we are peering inside of
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
  
  Window(CompositeOperator from){
    boundary = from;
    boundary.graph.view = this;
    windowManager = new WindowManager(this);
    eventManager = new EventManager(this);
    cam = new Camera(this);
    col = color (50+random(50), 100 + random(50), 150 + random(50));
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
  void setWindow(Operator whichOne, boolean isZoomingIn){
    selectionManager.clearSelection();
    
    currentWindow = windows.get(whichOne);
    if (isZoomingIn){
      currentWindow.cam.setCamOnCompositeZoom();
    }
  }
  
  void attemptConnection(OutPortUI src, InPortUI dest){
    Flow srcData = ((OutPork)portMap.getPork(src)).data;
    Flow destData = ((InPork)portMap.getPork(dest)).data;
    
    if (Flow.compatible(srcData.getType(), destData.getType())){
      buildConnection(src, dest);
    } else {
      println("incompatible ports");
    }

  }

  //add edge to the graph, visible in this window, update references in porks, update listeners
  void buildConnection(OutPortUI src, InPortUI dest){
    
    //corresponding data ports
    OutPork srcPork = ((OutPork)portMap.getPork(src));
    InPork destPork = ((InPork)portMap.getPork(dest));
    
    //add connection, both in UI land and Data land
    connections.add(new Connection(src, dest));
    boundary.graph.addEdge(srcPork, destPork); 
    
    //update Window state stuff and call the newly connected op to update
    boundary.rebuildListeners();   
    ((OutPork)portMap.getPork(src)).dataNotification();
  }
  
  //remove edge from graph, update pork reference, remove edge UI
  void removeConnection(Edge e){
    boundary.graph.removeEdge(e);
    boundary.rebuildListeners();
    //e.destination.data = Flow.ofFloat(0);
    
    //find and remove connection
    for (Connection c : connections){
      if (c.source == portMap.getPort(e.source) && c.destination == portMap.getPort(e.destination)){
        connections.remove(c);
        break;
      }      
    }   
  }
  
  Edge getEdgeByConnection(Connection c){
    for (Edge e : boundary.graph.edges){
      if (c.source == portMap.getPort(e.source) && c.destination == portMap.getPort(e.destination)){
        return e;
      }
    }
    println("edge not found");
    return null;
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
  
  Module addModule(String what){
   
    //create the module, operator, and default UI
    Module newMod = partsFactory.createModule(what);
    
    //sets pos of BodyUIState
    setDefaultPosition(newMod);
    
    //store the object at the window level
    storeModule(newMod);
    
    //sets up ports, update graph
    newMod.owner.initialize();
    boundary.graph.computeTopoSort();
    
    newMod.organizeUI();
    
    //update next spawn position
    spawnCursor = PVector.add(newMod.getBodyPosition(), new PVector(0, newMod.uiBits.get(0).size.y+16));
    
    return newMod;
  }
  
  //just stores objects, doesn't build any UI or position anything
  Module storeModule(Module mod){
    
    //add Operator to the boundary of this window
    boundary.addKid(mod.owner);
    
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