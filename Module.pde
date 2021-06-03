/*

main class that extends to all the bits of UI that comprise the patch 
(NoiseGenerators, functions, displays, modifiers).

headsUp(), lookDown(), and operate() are responsible for all the routing.
Changes in the UI call headsUp() inside the Module, which recurs down
the patch, signalling to the modules below that they are receiving new data

Once headsUp() is done (this is done at the end of the frame, I think cp5 
does stuff after draw()), the patch is primed. Before a display module is
displayed, it will check if it is expecting new data. If no, it displays the
image it has stored. Otherwise, it tells the module above it to operate().

Operate() recurs upward in correspondence with headsUp(). If a module has 
inputs that are expecting new data, operate() on the module above, etc.
Eventually we reach an unchanged module or a generator (Module with no
data input). Then we work our way back down the patch, updating the data
stack as we travel.

After operate() has completed within a module, that module calls lookDown(),
which will tell every input that receives its output that it is done 
operating.

TODO (?) :

maybe we need onConnection() and onDisconnection() for modules like Video and Feedback

collapse() (for the big modules), select() (for grouping and drag()ing 
multiple modules), 

*/

public abstract class Module{
  
  InputNode[] ins;
  OutputNode[] outs;  
  ModInput[] modIns;
  ModOutput[] modOuts;
  GrabberNode grabber;
  HelpBox helper;
  
  String name;  
  int id;
  PVector pos;
  PVector size;
  color c;
  
  //used to point to the MacroPatch Module that contains this module
  int macroId = -1;
  
  //made false when a module is deleted
  boolean active = true;
  
  //made false when a module is collapsed into a MacroPatch
  boolean visible = true;
  
  //for moving, copying, deleting etc.
  boolean selected = true;
  
  boolean moving = false;
  
  //these fields and the ones below are used in extensions. Is this the cleanest way?
  PImage img;
  PShape model;
  
  //at what point do we decide to extend module further before concrete classes? Would that help?
  //all this garbage is a symptom of what bad practice? Like what about the class structure is bad?
  //how do i do it different????
  boolean isModifier = false;
  boolean isMidi = false;
  boolean isDisplay = false;
  boolean isFeedback = false;
  boolean newData = false;
  boolean loopReady = false;
  boolean isIterator = false;
  boolean isMovie = false;
  boolean isMacro = false;
  boolean isMacroIn = false;
  boolean isMacroOut = false;
  int[][] structuringElement = new int[3][3];
  float[][] kernel = new float[3][3];
  
  Module(PVector pos_){    
    id = modules.size(); 
    pos = pos_.copy();
    
    ins = new InputNode[0];
    outs = new OutputNode[0];
    modIns = new ModInput[0];
    modOuts = new ModOutput[0];
    cp5.addGroup("g"+str(id))
      .setPosition(pos.x, pos.y)
      .hideBar()
      ;    
  }
  
  void display(){      
    stroke(0);
    fill(c);
    if (selected){
      strokeWeight(3);
    } else {
      strokeWeight(1);      
    } 
    
    if (moving){
      drag(new PVector(mouseX-pmouseX, mouseY-pmouseY));
    }
    rect(pos.x, pos.y, size.x, size.y);
    grabber.display();
    for (InputNode n : ins){
      n.display();
    }
    for (OutputNode n : outs){
      n.display();
    }
    for (ModInput n : modIns){
      n.display();
    }
    for (ModOutput n : modOuts){
      n.display();
    }
    
    fill(0);
    
    if (name.length() < 5){
      textAlign(CENTER);
      text(name, pos.x+size.x/2, pos.y+size.y/2+5);
    } else {    
      textAlign(LEFT);
      text(name, pos.x+10, pos.y-3);
    }
  }
  
  //If InputNode.lookUp, there is a module above it that needs to operate before
  //this module can operate. So we travel up the patch until !InputNode.lookUp.
  //Then, we perform the operation and set lookUp false for everything that's in
  //OutputNode.receivers, making sure that A) all operations are performed in an 
  //orderly fashion, and B) no operations are performed twice in a loop.
  
  void operate(){
    for (InputNode n : ins){
      if (n.lookUp){
        if (modules.get((int)n.sender.x).allSystemsGo()){
          if(!(modules.get((int)n.sender.x).isFeedback && (int)n.sender.y == 1)){
            //maybe we should grab feedback data here instead of in Feedback.operate()??
            //modules.get((int)n.sender.x).operate();
            try{        
              modules.get((int)n.sender.x).operate();
            }
            catch(StackOverflowError e){
              message = new MessageBox("oh no! overflow!", new PVector(180, 60));
              messageActive = true;
            }
          }
        }
      }
    }
  }
  
  //this is called any time UI in a module changes in a way that changes its output.
  //It looks down the patch and makes sure every input implicated by it has 
  //lookUp=true. After all UI modulators are handled and the patch is primed, 
  //we call operate() inside each display. Also handles some feedback logic.
  
  //Should we put a check to see if the module is already looking up? Cause if so, it has
  //already told everybody down below to look up as well. There's a lot of double counting.
  void headsUp(){
    //println(name);
    for (OutputNode n : outs){
      for (PVector p : n.receivers){
        modules.get((int)p.x).ins[(int)p.y].lookUp = true;
      }      
    }
    for (OutputNode n : outs){
      for (PVector p : n.receivers){
        if (!modules.get((int)p.x).isDisplay && !(modules.get((int)p.x).isFeedback && (int)p.y == 1) && !(modules.get((int)p.x).isIterator && (int)p.y == 1)){
          modules.get((int)p.x).headsUp();
          if(modules.get((int)p.x).isFeedback){
            modules.get((int)p.x).newData = true;
          }
        } 
      }      
    }
    for (ModOutput n : modOuts){
      for (PVector p : n.receivers){
        modules.get((int)p.x).modIns[(int)p.y].lookUp = true;
      }      
    }
    for (ModOutput n : modOuts){
      for (PVector p : n.receivers){
        modules.get((int)p.x).headsUp();
      }      
    }
  }
  
  
  //used to make sure every input beneath it is ready to operate().
  //have to make sure we don't set a display ins lookUp false prematurely.
  void lookDown(){
    for (OutputNode n : outs){
      for (PVector p : n.receivers){
        if (!modules.get((int)p.x).isDisplay){
          modules.get((int)p.x).ins[(int)p.y].lookUp = false;
        }
      }
    }
    for (ModOutput n : modOuts){
      for (PVector p : n.receivers){
        modules.get((int)p.x).modIns[(int)p.y].lookUp = false;
      }
    }
  }
  
  void drag(PVector dragAmount){
    pos.add(dragAmount);
    grabber.drag(dragAmount);
    for (OutputNode n : outs){
      n.drag(dragAmount);
    }
    for (InputNode n : ins){
      n.drag(dragAmount);
    }
    for (ModOutput n : modOuts){
      n.drag(dragAmount);
    }
    for (ModInput n : modIns){
      n.drag(dragAmount);
    }
    cp5.getGroup("g"+str(id)).setPosition(pos.x, pos.y);
    if (pos.x <= 0 || pos.x+size.x >= width || pos.y <= 0 || pos.y+size.y >= height){
      //don't worry about repositioning if we are working with a larger display. just make sure the grabber is always within reach
      if (!(isDisplay && (globalWidth > 1400 || globalHeight > 800))){
        setPosition(new PVector(constrain(pos.x, 1, width-size.x-1), constrain(pos.y, 1, height-size.y-1)));
      }
    }
  }
  
  void setPosition(PVector newPos){
    PVector difference = newPos.sub(pos);
    drag(difference);
  }
  
  //this method is only called in NoiseGenerators and recursively, here. It ~ should ~
  //result in all connected Flows being resized and recalculated, top down.
  //currently not all stack entries getting resized properly. 
  
  void changeDataDimensions(){
    headsUp();
  }
  
  //checks that every connection needed to operate() is made 
  boolean allSystemsGo(){
    for (OutputNode n : outs){
      if (n.flowId == 0){
        return false;
      }
    }
    //for (InputNode n : ins){
    //  if (n.flowId == 0){
    //    return false;
    //  }
    //}
    return true;
  }
  
  void feedbackPrimer(){
  }
  
  void moviePrimer(){
  }
  
  void sendModValue(){
  }
  
  void presetKernel(){
  }
  
  void sendMidi(int num, float val){
  }
  
  //we should write a general cp5Handler. Would need each module to have a String[] 
  //controllerNames that stores the names of all the cp5 that takes a ModInput.
  void cp5Handler(){
  }
  
  void openMacro(){
    for (Module m : modules){
      if (m.active){
        if (m.macroId == this.id){
          m.macroId = -1;
          m.show();
        }
      }
    }
    deleteModule();
  }
  
  void assignInput(int whichSignalIn, int flow){
  }
  
  void assignOutput(PVector receivingNode){
  }
  
  void copyModule(){
    PVector newPos = new PVector(50, 50).add(pos);
    switch(name){
    case "noise" :
      modules.add(new NoiseGenerator(newPos));
      break;
    case "constant" :
      modules.add(new Constant(newPos));
      break;  
    case "display" :
      modules.add(new Displayer(newPos));
      break;
    case "modulator" :
      modules.add(new Modifier(newPos));
      break;  
    case "image" :
      modules.add(new Image(newPos));
      break;
    case "video" :
      modules.add(new Vid(newPos));
      break;  
    case "math" :
      modules.add(new Math(newPos));
      break; 
    case "| |" :
      modules.add(new AbsoluteValue(newPos));
      break; 
    case "sampler" :
      modules.add(new Sampler(newPos));
      break;
    case "and" :
      modules.add(new And(newPos));
      break;
    case "or" :
      modules.add(new Or(newPos));
      break;
    case "xor" :
      modules.add(new XOr(newPos));
      break; 
    case "not" :
      modules.add(new Not(newPos));
      break;   
    case "+" :
      modules.add(new Add(newPos));
      break;
    case "-" :
      modules.add(new Subtract(newPos));
      break; 
    case "x" :
      modules.add(new Multiply(newPos));
      break; 
    case "/" :
      modules.add(new Divide(newPos));
      break;
    case "feedback" :
      modules.add(new Feedback(newPos));
      break;
    case "rotate" :
      modules.add(new Rotate(newPos));
      break; 
    case "reflect" :
      modules.add(new Reflect(newPos));
      break;  
    case "random" :
      modules.add(new Random(newPos));
      break;
    case "3D" :
      modules.add(new ThreeD(newPos));
      break;  
    case "scale" :
      modules.add(new Scale(newPos));
      break;
    case "convolve" :
      modules.add(new Convolve(newPos));
      break;
    case "interval" :
      modules.add(new Interval(newPos));
      break;
    case "translate" :
      modules.add(new Translate(newPos));
      break;      
    case "iterator" :
      modules.add(new Iterator(newPos));
      break;
    case "delay" :
      modules.add(new Delay(newPos));
      break; 
    case "kernel" :
      modules.add(new Kernel(newPos));
      break;  
    case "structure" :
      modules.add(new StructuringElement(newPos));
      break;
    case "large structure" :
      modules.add(new LargeStructuringElement(newPos));
      break;   
    case "midi" :
      modules.add(new MidiMod(newPos));
      break;
    case "celato" :
      modules.add(new Celato(newPos));
      break;
    case "mean" :
      modules.add(new MedianFilter(newPos));
      break;  
    case "median" :
      modules.add(new MedianFilter(newPos));
      break;
    case "variance" :
      modules.add(new Variance(newPos));
      break;
    case "text" :
      modules.add(new TextGen(newPos));
      break;
    case "distance" :
      modules.add(new DistanceTransform(newPos));
      break; 
    case "histograb" :
      modules.add(new Histograb(newPos));
      break;
    case "dilate" :
      modules.add(new Dilate(newPos));
      break;
    case "erode" :
      modules.add(new Erode(newPos));
      break; 
    case "hit and miss" :
      modules.add(new HitAndMiss(newPos));
      break;   
    case "valley" :
      modules.add(new Valley(newPos));
      break; 
    case "peak" :
      modules.add(new Peak(newPos));
      break;
    case "local min" :
      modules.add(new LocalMin(newPos));
      break;   
    case "local max" :
      modules.add(new LocalMax(newPos));
      break;
    case "global min" :
      modules.add(new GlobalMin(newPos));
      break;   
    case "global max" :
      modules.add(new GlobalMax(newPos));
      break;
    case "center" :
      modules.add(new CenterOfMass(newPos));
      break;   
    case "gray dilate" :
      modules.add(new GrayDilate(newPos));
      break;
    case "gray erode" :
      modules.add(new GrayErode(newPos));
      break; 
    case "blob" :
      modules.add(new Blob(newPos));
      break;  
    case "DFT" :
      modules.add(new DFTModule(newPos));
      break; 
    case "IDFT" :
      modules.add(new IDFTModule(newPos));
      break;    
    case "<" :
      modules.add(new LessThan(newPos));
      break;  
    case ">" :
      modules.add(new GreaterThan(newPos));
      break;  
    case "=" :
      modules.add(new Equal(newPos));
      break;  
    case "log" :
      modules.add(new Log(newPos));
      break; 
    case "^" :
      modules.add(new Exp(newPos));
      break;   
    case "%" :
      modules.add(new Modulo(newPos));
      break;
    case "in" :
      modules.add(new SignalIn(pos));
      break; 
    case "out" :
      modules.add(new SignalOut(pos));
      break;         
    }
    
    int moduleId = modules.size()-1;
    color theColor = color(red(modules.get(moduleId).c)-50, green(modules.get(moduleId).c)-50, blue(modules.get(moduleId).c)-50);
    if(modules.get(moduleId).isModifier){
      for(int i = 0; i < modules.get(modules.size()-1).modOuts.length; i++){
        modules.get(modules.size()-1).modOuts[i].cableCol = theColor;
      }
    } else {
      for(int i = 0; i < modules.get(modules.size()-1).outs.length; i++){
        modules.get(modules.size()-1).outs[i].cableCol = theColor;
      }
    }
  }
  
  void hide(){
    visible = false;
    cp5.getGroup("g"+str(id)).hide();
  }
  
  void show(){
    visible = true;
    cp5.getGroup("g"+str(id)).show();
  }
  
  // Remove connections, remove cp5, and set active = false. Missing anything?
  void deleteModule(){
    for (InputNode n : ins){
      if (n.flowId >= 1){
        modules.get((int)n.sender.x).outs[(int)n.sender.y].removeReceiver(n.id); 
      }
    }
    for (OutputNode n : outs){
      n.clearReceivers();          
    }
    for (ModInput n : modIns){
      if (n.sender != null){
        modules.get((int)n.sender.x).modOuts[(int)n.sender.y].removeReceiver(n.id); 
      }
    }
    for (ModOutput n : modOuts){
      n.clearReceivers();    
    }
    cp5.getGroup("g"+str(id)).remove();
    active = false;
  }  
}
