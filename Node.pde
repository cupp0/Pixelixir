//This extends to InputNode, OutputNode, ModInput, ModOutput, and Grabber
//Idk if this structure is best but we're making it work

public abstract class Node{
  
  int flowId = 0;
  PVector id;
  PVector pos;
  int size = 8; 
  color col;
  color cableCol;
  //this vector reflects whether designated color channels (from video or image) are upstream
  PVector colorChannels = new PVector(0, 0, 0);
  boolean mouseOver = false;
  
  //id - module, #, input/output
  Node(PVector id_, PVector pos_){
    id = id_.copy();
    pos = pos_.copy();
  }
  
  public void display(){
    fill(col);
    stroke(0);
    if (isInside(new PVector(mouseX, mouseY), new PVector(pos.x+4, pos.y+4), new PVector(6, 6))){
      mouseOver = true;
      strokeWeight(3);
    } else {
      mouseOver = false;
      strokeWeight(1);
    }
    rect(pos.x, pos.y, size, size);
  } 
  
  void onMousePressed(){
  }
  
  void drag(PVector dragAmount){
    pos.add(dragAmount);
  }
}

class InputNode extends Node{
  PVector sender;
  boolean lookUp;
    
  InputNode(PVector id_, PVector pos_){
    super(id_, pos_);  
    col = color(250);
  }
  
  void onMousePressed(){
    //only build connection if there is an output node cued, this node
    //doesn't already have a connection, the cue isn't from the same
    //module, and the node isn't a modulation node!
    if (cue != null){
      if (isClosedLoop((int)cue.x, (int)id.x)){
        cue = null;
        message = new MessageBox("Don't do that!", new PVector(310, 50));
        messageActive = true;
        return;
      } else {
        if (flowId == 0 && cue.z != -1){
          flowId = modules.get((int)cue.x).outs[(int)cue.y].flowId;
          sender = cue.copy();
          modules.get((int)cue.x).outs[(int)cue.y].addReceiver(id);
          if (modules.get((int)id.x).isModifier){
            lookUp = true;
            modules.get((int)cue.x).operate();
          }
          if (!(keyPressed && key == CODED && keyCode == SHIFT)){
            cue = null;
          }
        }
      }
    }
  }
  
  boolean isConnected(){
    if (flowId == 0){
      return false;
    } else {
      return true;
    }
  } 
}

class OutputNode extends Node{
  
  ArrayList<PVector> receivers = new ArrayList<PVector>();
  
  OutputNode(PVector id_, PVector pos_){
    super(id_, pos_);
    col = color(250);
    stack.add(new Flow());
    flowId = stack.size()-1;
  }
  
  //out of convenience, we often piggyback display() to check for interaction. 
  //Is there a way to handle interactivity without calling an additional
  //method on every outputNode every frame? Seems wasteful not to do it here.
  void display(){
    super.display();    
    //OutputNode is responsible for drawing all connections here  
    stroke(cableCol);
    for (int i = 0; i < receivers.size(); i++){
      PVector p = receivers.get(i).copy();
      if (connectionHovered(id, modules.get((int)p.x).ins[(int)p.y].id)){
        strokeWeight(4);  
      } else {
        strokeWeight(2);
      }
      line(pos.x+4, pos.y+4, modules.get((int)p.x).ins[(int)p.y].pos.x+4, modules.get((int)p.x).ins[(int)p.y].pos.y+4);
    }   
  }
  
  void onMousePressed(){
    //assigning cable color here because Module Nodes are built before Module color is assigned in Module constructor
    //causes issue when Modules are copied
    if (red(col) == 255){
      cableCol = color(200, 0, 0);
    } else if (green(col) == 255){
      cableCol = color(0, 200, 0);
    } else if (blue(col) == 255){
      cableCol = color(0, 0, 200);
    } else {
      color modCol = modules.get((int)id.x).c;
      cableCol = color(red(modCol)-50, green(modCol)-50, blue(modCol)-50);
    }
    //cue is held to build a connection once an input is pressed
    if (cue == null){
      cue = id.copy();
    }
  }
  
  
  //outputNode is responsible for making dimensions congruent. silliness
  void addReceiver(PVector nodeId){
    //check list to see if it's a duplicate
    boolean duplicate = false;
    for (PVector p : receivers){
      if (p.x == nodeId.x && p.y == nodeId.y){
        duplicate = true;
      }
    }
    if (!duplicate){
      receivers.add(nodeId);
      modules.get((int)nodeId.x).changeDataDimensions();
      modules.get((int)id.x).headsUp();
    }
  }
  
  void removeReceiver(PVector nodeId){
    modules.get((int)nodeId.x).ins[(int)nodeId.y].flowId = 0;
    //modules.get((int)nodeId.x).ins[(int)nodeId.y].sender = null;
    receivers.remove(receivers.indexOf(nodeId));
  }
  
  void clearReceivers(){
    for (int i = receivers.size()-1; i >= 0; i--){
      modules.get((int)receivers.get(i).x).ins[(int)receivers.get(i).y].flowId = 0;
      //modules.get((int)receivers.get(i).x).ins[(int)receivers.get(i).y].sender = null;
      receivers.remove(i);
    }
  }  
}

class ModOutput extends Node{
  
  float[] modData;
  ArrayList<PVector> receivers = new ArrayList<PVector>();
  
  ModOutput(PVector id_, PVector pos_){
    super(id_, pos_);  
    col = color(127);  
  }
  
  void display(){
    super.display(); 
    stroke(cableCol);
    for (int i = 0; i < receivers.size(); i++){
      PVector p = receivers.get(i).copy();
      if (connectionHovered(id, modules.get((int)p.x).modIns[(int)p.y].id)){
        strokeWeight(4);  
      } else {
        strokeWeight(2);
      }
      line(pos.x+size/2, pos.y+size/2, modules.get((int)p.x).modIns[(int)p.y].pos.x+size/2, modules.get((int)p.x).modIns[(int)p.y].pos.y+size/2);
    } 
  }
  
  void onMousePressed(){
    //assigning cable color here because something breaks when we assign it in OutputNode constructor
    cableCol = color(red(modules.get((int)id.x).c)-50, green(modules.get((int)id.x).c)-50, blue(modules.get((int)id.x).c)-50);
    
    //cue is held to build a connection once an input is pressed
    if (cue == null){
      cue = id.copy();
    }
  }
  
  void addReceiver(PVector nodeId){
    //check list to see if it's a duplicate
    boolean duplicate = false;
    for (PVector p : receivers){
      if (p.x == nodeId.x && p.y == nodeId.y){
        duplicate = true;
      }
    }
    if (!duplicate){
      receivers.add(nodeId);
    }
  }
  
  //why does this sometimes return -1?
  void removeReceiver(PVector nodeId){
    if (receivers.indexOf(nodeId) >= 0){
      receivers.remove(receivers.indexOf(nodeId));
    }
  }
  
  void clearReceivers(){
    for (int i = receivers.size()-1; i >= 0; i--){
      receivers.remove(i);
    }
  } 
}

class ModInput extends Node{
  
  PVector sender;
  boolean lookUp;
  float baseVal;
  float min;
  float max;
  String controllerName;
  boolean pauseInput = false;
  
  ModInput(PVector id_, PVector pos_, String name){
    super(id_, pos_);  
    col = color(127);
    controllerName = name;
    min = cp5.getController(name).getMin();
    max = cp5.getController(name).getMax();
  }
  
  //only update slider values if the mouse isn't pressed. This way, we 
  //avoid the modifier setting the baseVal.
  void receiveModValue(float val){
    if (!pauseInput){
      val = map (val, 0, 1, min, max);
      cp5.getController(controllerName).setValue(baseVal+val);
    }
  }
  
  void onMousePressed(){
    if (cue != null && cue.z == -1){
      sender = cue.copy();
      modules.get((int)cue.x).modOuts[(int)cue.y].addReceiver(id);   
      if (!(keyPressed && key == CODED && keyCode == SHIFT)){
        cue = null;
      }
    }
  }
  
}

class GrabberNode extends Node{
  
  GrabberNode(PVector id_, PVector pos_){
    super(id_, pos_); 
    col = color(0);
  }
  
  void onMousePressed(){
    for (Module m : modules){
      if (m.selected){
        m.moving = true;
      }
    }
  }
  
  void onMouseReleased(){
    for (Module m : modules){
      if (m.selected){
        m.moving = false;
      }
    }
  }
  
  public void display(){
    fill(col);
    stroke(0);
    if (isInside(new PVector(mouseX, mouseY), new PVector(pos.x+4, pos.y+4), new PVector(6, 6))){
      mouseOver = true;
      strokeWeight(3);
      if (helpMode){
        modules.get((int)id.x).helper.display(new PVector(200, 10));
      }
    } else {
      mouseOver = false;
      strokeWeight(1);
    }
    rect(pos.x, pos.y, size, size);
    //text(flowId, pos.x, pos.y);
  }
}
