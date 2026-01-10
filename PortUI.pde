//~PortUI
//PortUI is responsible for managing and displaying connections between modules
//Pork is responsible for routing data between Operators
public abstract class PortUI extends ModuleUI<PortUIState>{
  
  Pork pair;
  int[] radii = new int[4];     //tells us which corners get rounded based on position of PortUI within the module
  int index;                    //for convenience
  
  PortUI(){
    super();
    setSize(new PVector(portSize, portSize)); style.fill = color(120);
  } 
  
  Pork getPorkPair(){
    return getWindow().portMap.getPork(this);
  }
  
  void setPorkPair(Pork p){
    pair = p;
  }
  
  void setIndex(int ind){
    index = ind;
  }
  
  //this method looks at a Ports position within the module to determine how to round over its corners
  void setCornerRadii(boolean isInPort){
    for (int i = 0; i < 4; i++){
      radii[i] = 0;
    }    

    if (isInPort){
      if (index == 0){
        radii[0] = roundOver;
        radii[2] = roundOver;
      } else if (index == parent.ins.size()-1){
        radii[1] = roundOver;
        radii[3] = roundOver;
      } else {
        radii[2] = roundOver;        
        radii[3] = roundOver;        
      }
    } else {
      if (index == 0){
        radii[1] = roundOver;
        radii[3] = roundOver;
      } else if (index == parent.outs.size()-1){
        radii[0] = roundOver;
        radii[2] = roundOver;
      } else {
        radii[1] = roundOver;        
        radii[0] = roundOver;        
      }
    }
  }
  
  void display(){   
    rect(getAbsolutePosition().x, getAbsolutePosition().y, size.x, size.y, radii[0], radii[1], radii[2], radii[3]);
    //if (parent.getWindow().portMap.getPork(this).targetFlow != null){
    //  text(parent.getWindow().portMap.getPork(this).targetFlow.getAddress(), getAbsolutePosition().x, getAbsolutePosition().y);
    //}
    //if (parent.getWindow().portMap.getPork(this).targetFlow == null){
    //  fill(255, 0, 0);    
    //  ellipse(getAbsolutePosition().x, getAbsolutePosition().y, size.x, size.y);
    //}
  }

}

//~InPortUI
class InPortUI extends PortUI{
   
  InPortUI(){
    super();
    name = "InPort"; 
  }
  
  OutPortUI getSource(){
    return ((OutPortUI)getWindow().portMap.getPort(((InPork)getPorkPair()).getSource()));
  }
  
  StateChange onInteraction(HumanEvent e){
    return new StateChange(StateAction.DO_NOTHING);  
  }

}

//~OutPortUI
class OutPortUI extends PortUI{
  
  OutPortUI(){
    super();
    name = "OutPort";
  } 
  
  ArrayList<InPortUI> getDestinations(){
    Window w = getWindow();
    ArrayList<InPortUI> ilist = new ArrayList<>();
    
    for (Connection c : w.connections){
      if (c.source == this){
        ilist.add((InPortUI)c.destination);
      }
    }
    
    return ilist;
  }
  
  StateChange onInteraction(HumanEvent e){
    StateMan sm = parent.getWindow().windowMan.stateMan;
    
    //create an open connection
    if (sm.isInteractionState(InteractionState.NONE)){
      if (sm.isMouseDoing(Action.MOUSE_PRESSED, LEFT)){
        
        Pork p = getPorkPair();
        if (p.elligibleForConnection()){
          parent.getWindow().addConnectionLine(this);
          return new StateChange(StateAction.ADD, InteractionState.DRAGGING_OPEN_CONNECTION, this);  
        }
      }
    }
    
    //drag open connection
    if (sm.isInteractionState(InteractionState.DRAGGING_OPEN_CONNECTION)){      
      //remove open connection
      if (e.input.theKeyCode == BACKSPACE){
        parent.getWindow().removeConnectionLine();
        return new StateChange(StateAction.REMOVE, InteractionState.DRAGGING_OPEN_CONNECTION, this); 
      }
      
      //attempt connection
      if (sm.isMouseDoing(Action.MOUSE_PRESSED)){
        
        HoverTarget ht = e.hover;       
        if (!(ht.ui instanceof InPortUI)) return new StateChange(StateAction.DO_NOTHING); 
        
        DataAccess da = (e.input.mouseButt == LEFT)? DataAccess.READONLY : DataAccess.READWRITE;
        if (((InPortUI)ht.ui).getSource() == null){
          parent.getWindow().attemptConnection(this, ((InPortUI)ht.ui), da);
          if(!sm.inputMan.getState().isDown(CONTROL)){
            parent.getWindow().removeConnectionLine();
            return new StateChange(StateAction.REMOVE, InteractionState.DRAGGING_OPEN_CONNECTION, this); 
          }
        }
      }
    }
    
    return new StateChange(StateAction.DO_NOTHING);  
  }

}
