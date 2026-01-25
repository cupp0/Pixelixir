//~Window
class Window implements Interactable{
  
  // handle inputs, menus, interaction
  WindowMan windowMan;
  
  // organizational info
  Module boundary;                                           //the module we are looking inside of
  BiMap portMap = new BiMap();                               //Port / pork bimap 
  PVector spawnCursor = new PVector(200, 200);               //where we spawn the next module by default                                         
  
  // display
  ArrayList<Module> modules = new ArrayList<>();             //the UI that represents our operator's juicy innards
  ArrayList<Connection> connections = new ArrayList<>();     //ui class for edges
  Style style;
  ConnectionLine connectionLine;                            //where do these two belong?
  SelectionRectangle selectionRectangle;                                                  
  
  Window(Module from){
    boundary = from;
    windowMan = new WindowMan(this);
    style = new Style(color (random(150), 50 + random(150), 100 + random(150)));
  } 
  
  public Style getStyle(){
    return style;
  }

  void display(){    
    background(style.getFill());
    noiseGen.stepColor(); 
    windowMan.stateMan.cam.update();
    
    pushMatrix();
    translate(windowMan.stateMan.cam.xOff,windowMan.stateMan.cam.yOff);
    scale(windowMan.stateMan.cam.scl);
    for (Module m : modules) {
      m.display();
      displayConnections(m);
    }    
    displayAnimations();      
    popMatrix();   
    
    windowMan.displayMenuIfActive();
  }
  
  void displayAnimations(){
    if (selectionRectangle != null){
      selectionRectangle.display(new PVector(windowMan.stateMan.cx, windowMan.stateMan.cy));
    }
    if (connectionLine != null){
      connectionLine.display(new PVector(windowMan.stateMan.cx, windowMan.stateMan.cy));
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

    currentWindow = windows.get(whichOne);
    if (isZoomingIn){
      currentWindow.windowMan.stateMan.cam.setCamOnCompositeZoom();
    }
  }
  
  void attemptConnection(OutPortUI src, InPortUI dest, DataAccess da){
    
    OutPork srcPork = ((OutPork)portMap.getPork(src));
    InPork destPork = ((InPork)portMap.getPork(dest));
    
    if (srcPork == null){
      return;//println(src.parent.name +" has unpaired output");return;
    }
    if (destPork == null){
      return;//println(dest.parent.name + " has unpaired input");return;
    }
    //determine if the ports have compatible access requirements (a read only out can't be plugged into an in that wants to write)
    //access resolution could be static
    DataAccess accessRequirement = srcPork.resolveDataAccess(destPork, da);
    
    if (accessRequirement == DataAccess.NONE){
      println("one wants to read, one wants to write. One thing's for sure, they don't want to fight");
      println("The port access requirements are incompatible with the edge type you attempted. try a READONLY edge (left click)");
      return;
    }
    
    //are the data types compatible (float vs text, etc)
    boolean compatibleDataType = Flow.compatible(srcPork.getCurrentDataType(), destPork.getCurrentDataType());
    
    if (!compatibleDataType){
      println("if you try to STRING a LIST to a BOOL's tail, you'll soon NUMERIC away to heaven (that connection's a fail)");
      return;
    }
    
    buildConnection(src, dest, accessRequirement);
  }

  //add edge to the graph, visible in this window, update references in porks, update listeners
  void buildConnection(OutPortUI src, InPortUI dest, DataAccess da){
    
    //corresponding data ports
    OutPork srcPork = ((OutPork)portMap.getPork(src));
    InPork destPork = ((InPork)portMap.getPork(dest));
    
    //if compatible, set both ports to the resolved access requirement, then build the connection
    srcPork.setCurrentAccess(da);
    destPork.setCurrentAccess(da);
    
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
    
    //store it
    registerModule(newMod);
    
    return newMod;
  }
  
  void registerModule(Module m){
    //store the object at the window level
    modules.add(m);
    m.setParent(this.boundary);
    registerPorts(m);
    windowMan.lastSpawned = m;
    updateSpawnPosition(PVector.add(m.getBodyPosition(), new PVector(0, m.uiBits.get(0).size.y+16)));
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
  
  //used after addModule to set default spawn pos
  void updateSpawnPosition(PVector p){
    spawnCursor = p.copy();
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
    style.fill = c;
  }
  
  color getColor(){
    return style.getFill();
  }
   
  PVector getCursor(){
    return spawnCursor; 
  }
  
  void setCursor(PVector p){
    spawnCursor.set(p);
  }
  
  StateChange onInteraction(HumanEvent e){
    
    StateMan sm = windowMan.stateMan;
    //if doing nothing, do stuff
    if (sm.isInteractionState(InteractionState.NONE)){      
        //key commands
        if (sm.inputMan.getState().isDown(CONTROL)){
          if(sm.inputMan.getState().justPressed('S'))saveSketch();
          if(sm.inputMan.getState().justPressed('C'))sm.selectionMan.copyModules(sm.selectionMan.modules);    
          if(sm.inputMan.getState().justPressed('V'))sm.selectionMan.pasteModules(clipboard, this, new PVector(e.xMouse, e.yMouse));    
        }
   
        if (e.input.theKey == 'r')windowMan.stateMan.cam.resetCam();
        if (e.input.theKeyCode == BACKSPACE)sm.selectionMan.onBackSpace();
          
        //right mouse  
        if (sm.inputMan.getState().isMouseDown(RIGHT)){
          if (sm.isMouseDoing(Action.MOUSE_DRAGGED, RIGHT)){
            addSelectionRectangle(e);
            return new StateChange(StateAction.ADD, InteractionState.SELECTING_MODULES, this);
          }
        }    
        
        if (sm.isMouseDoing(Action.MOUSE_RELEASED, RIGHT)){
          windowMan.addWindowMenu(new PVector(e.input.xMouse, e.input.yMouse));
          updateSpawnPosition(new PVector(e.xMouse-60, e.yMouse));
          return new StateChange(StateAction.ADD, InteractionState.MENU_OPEN, this);
        }
        
        //left mouse  
        if (sm.inputMan.getState().isMouseDown(LEFT)){
          if (sm.isMouseDoing(Action.MOUSE_DRAGGED, LEFT)){
            PVector panAmount = new PVector(e.input.xMouse - e.input.pxMouse, e.input.yMouse - e.input.pyMouse);
            panAmount.div(windowMan.stateMan.cam.scl);
            windowMan.stateMan.cam.pan(panAmount);
            return new StateChange(StateAction.ADD, InteractionState.PANNING, this);
          }
        }   
        //left mouse
        if (sm.isMouseDoing(Action.MOUSE_RELEASED, LEFT)){
          sm.selectionMan.clearSelection();
        }     
        
        if (sm.isMouseDoing(Action.MOUSE_WHEEL)){
          if(sm.inputMan.getState().isDown(CONTROL)){
            sm.cam.setZoomFactor(1.01);
          } else {
            sm.cam.setZoomFactor(1.1);
          }
          sm.cam.zoom(e.input.wheelDelta);
          checkWindowTransition(e);
        }
    }
    
    
    //if panning, we can pan or end pan
    if (sm.isInteractionState(InteractionState.PANNING)){      
        if (e.input.action == Action.MOUSE_DRAGGED){
          PVector panAmount = new PVector(e.input.xMouse - e.input.pxMouse, e.input.yMouse - e.input.pyMouse);
          panAmount.div(windowMan.stateMan.cam.scl);
          windowMan.stateMan.cam.pan(panAmount);
        }
        if (e.input.action == Action.MOUSE_RELEASED) {
          return new StateChange(StateAction.REMOVE, InteractionState.PANNING, this);
        }
    }
    
    //if menu open, we can exit menu
    if (sm.isInteractionState(InteractionState.MENU_OPEN)){
        if (e.input.action == Action.MOUSE_PRESSED){
          windowMan.exitMenu();
          return new StateChange(StateAction.REMOVE, InteractionState.MENU_OPEN, this);
        }
    }
      
      
    //if are selecting modules, we can finalze selection
    if (sm.isInteractionState(InteractionState.SELECTING_MODULES)){
        if (e.input.action == Action.MOUSE_RELEASED){
          sm.selectionMan.modules = getModulesInside(new PVector(windowMan.stateMan.storedX, windowMan.stateMan.storedY), new PVector(e.xMouse, e.yMouse));
          removeSelectionRectangle();
          return new StateChange(StateAction.REMOVE, InteractionState.SELECTING_MODULES, this);
        }
    }

    return new StateChange(StateAction.DO_NOTHING);
  }
  
  //dummy method, window is hovered (canvas) any time nothing else is hovered
  HoverTarget hitTest(float x, float y) {
    return new HoverTarget(this);
  }
  
  //on zoom, check if we need to change windows
  void checkWindowTransition(HumanEvent e){

    if (e.hover.ui instanceof CompositeUI){           
      //if hovering an eye and zooming in, transition to new window
      if (e.input.wheelDelta > 0 && windowMan.stateMan.cam.scl > windowMan.stateMan.cam.maxScl){
        setWindow(((ModuleUI)e.hover.ui).parent, true);
      }         
    }
    
    //if zooming out, check the window exists before transitioning
    if (e.input.wheelDelta < 0 && windowMan.stateMan.cam.scl < windowMan.stateMan.cam.minScl){
      if (windows.containsKey(boundary.parent)){
        setWindow(boundary.parent, false);
      }
    }
  }
  
}
