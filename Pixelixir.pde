
/*

\\ video synthesizer //

Click the triangle to run.

~  ~  ~  ~  ~

BUGS 

-iterator sometimes stackoverflows with filter depending on connection order
-feedback not initiating properly sometimes
-why does adding a rotate module glitch
-random NullPointerException in Constant, copied big chunk, rerouted a few things, then hooked up to a display
-Modules upstream are sometimes operating unnecessarily after changes downstream
-when loading patches, we get concurrentmodificationexception when using the fileSelect prompt. Issue seems to
go away when we type the file name instead.

IMPROVEMENTS

- add a comment feature

- currently, saving records module info including type, position and signal connections. Modifier
connections and other module info (slider position, imagePath, etc) aren't being recorded. Let's not
complete the saving/loading situation until we rewrite the Module class

- accomodate larger convolution kernels. Maybe leave kernel as a Gen for example kernels
but generalize structuring element to accomodate both binary/ternary elements and conv. kernels

- method of synchronizing videos, displays, recording, etc.

- some sort of instructional graphic beyond the help boxes

- modules inside loops should communicate to the parent iterator when they should headsUp(). Maybe 
int loopId = -1 in Module that gets reassigned to every Module that is contained in a loop? Then we override
headsUp() and just call headsUp in the Iterator? Loop logic is still not tight. Could rewrite the whole mess

- 3D is better, dropped all three in favor of a more general 3d module

- fix fast median and test it against (the currently implemented) quickSelect

- Try/Catch list
  - creating a closed loop with module connections
  - typing a string into the save path text box
  - invalid inputs for the exp eval
  - if onMousePressed() in inputNode, try (array index out of bounds)
  
~ ~ ~ REFACTOR NOTES ~ ~ ~

- double precision might be necessary

- get rid of Flow. It does nothing. stack should be an arrayList of float[]

- collapse() method in Module. Look at number of ins, outs, modIns and modOuts to determine size
Only draw nodes, no CP5. Maybe shift+click the grabber collapes? 

- make a node initialization method in Module

- iterator and filter need reconceived. unreliable, bad

- automate Module UI based on number of ins/outs, module name, etc. Every Module has a collapse
that just shows ins/outs and name

- pass module id into constructor for flexibility

- Can we store every Node in a container in Module? Then have overwritten methods
like we do in lots of Module extensions? 

- make a cp5Handler method in Module

- make an abstract InputNode and OutputNode from which SignalInputNode and ModInputNode extend?

- address double counting scenarios in headsUp()

-For elements that use a structuring element and only care about the on state for their neighborhood,
should we store only PVectors pointing to the neighborhood instead of iterating through the whole 
dimension of the neighborhood for every pixel? Seems faster. Test it.

~ ~ ~ DREAM WORK ~ ~ ~
  
- subpatches (once saving/loading is figured out, subpatches should be straightforward)
  - build module for subpatches, where user indicates number of inputs and outputs
  - idk how to do it

- resolution is determined by each display instead of globally. If module dimensions
  disagree, scale the larger one down to the smaller one
  
- Start thinking about Modules that store multiple signals.

*/

//if only, if only
//import processing.video.*;
import controlP5.*;
import java.io.*;
import themidibus.*;

ControlP5 cp5;
MidiBus myBus;
OpenSimplexNoise noise;

String[] generators = {"GENERATE", "constant", "math", "noise", "random", "video", "image", "text", "kernel", "structure", "large structure"};
String[] arithmetic = {"MATH/LOGIC", "and", "or", "xor", "not", "<", ">", "=", "+", "-", "x", "/", "^", "log", "%", "abs", "convolve"};
String[] analysis = {"ANALYZE", "dilate", "erode", "peak", "valley", "hit and miss", "local min", "local max", "global min", "global max", "mean", "median", "variance", "center", "distance", "gray dilate", "gray erode", "blob", "histograb", "DFT", "IDFT"};
String[] transformation = {"TRANSFORM", "translate", "scale", "rotate", "reflect"};
String[] utility = {"UTILITY", "feedback", "interval", "iterator"};
String[] miscellaneous = {"MISC", "celato", "3D"};
String[] modifiers = {"MODIFY", "basicMod", "sampler", "midi"};
String[] output = {"OUTPUT", "display"};

String[][] UIText = {generators, arithmetic, analysis, transformation, utility, miscellaneous, modifiers, output};

Accordion mainAcc;
Group mainMenu;

//list of UI objects for building patches
ArrayList<Module> modules = new ArrayList<Module>();

//list of data that is manipulated in order to generate displays
ArrayList<Flow> stack = new ArrayList<Flow>();

//add to this each time a module that uses noise is added. Each of these
//modules has a textfield you can use to sync seeds with other modules
ArrayList<Float> seeds = new ArrayList<Float>();

boolean menuActive = true;
boolean helpMode = false;
boolean messageActive = false;
boolean shiftPressed;
boolean wPressed;
boolean aPressed;
boolean sPressed;
boolean dPressed;
MessageBox message;
//stores a Node.id when we click it. Used to build node connections.
PVector cue;
//shape for making a selection
PShape selectionRect;
//stores where the mouse was clicked. For selecting groups
PVector click;
int globalWidth = 300;
int globalHeight = 300;

public void settings(){
  //PApplet extension for draw module does not like P2D.
  size(1440, 855, P3D);
}

void setup(){
  cp5 = new ControlP5(this);
  // List all our MIDI devices
  MidiBus.list();
  // Connect to input, output
  myBus = new MidiBus(this, 1, 1);
  noise = new OpenSimplexNoise();
  gui();
  stroke(0);
  strokeWeight(1);
  
  // bottom of stack is all 0s. Nodes without a connection point to it.
  stack.add(new Flow());
  stack.get(0).blankFlow();  
}

void toggleHelp(){
  helpMode = flick(helpMode);
}

void toggleMenu(){
  menuActive = flick(menuActive);
  if (!menuActive){
    mainMenu.hide();
  } else {
    mainMenu.show();
  }
  //println(menuActive);
}

void draw(){
  background(100);
  
  //all this does is display each active module
  for (Module m : modules){
    //active just means it hasn't been deleted, no clean way of deleting objects idk
    if(m.active){
      //feedback, modifier, and movie modules have responsibilities every loop.
      if (m.isModifier){
        m.sendModValue();
      }
      if (m.isFeedback){
        m.feedbackPrimer();
      }
      if (m.isMovie && m.allSystemsGo()){
        m.headsUp();
      }
      //See Displayer.display() in output tab, this method drives all the calculation 
      m.display();
    }
  }
  
  //temporary lines for when the user is building a connection
  if (cue != null){
    
    //stroke(red(modules.get((int)cue.x).c)-50, green(modules.get((int)cue.x).c)-50, blue(modules.get((int)cue.x).c-50));
    strokeWeight(4);
    if (cue.z == -1){
      stroke(modules.get((int)cue.x).modOuts[(int)cue.y].cableCol);
      line(modules.get((int)cue.x).modOuts[(int)cue.y].pos.x+4, modules.get((int)cue.x).modOuts[(int)cue.y].pos.y+4, mouseX, mouseY);
    } else {
      stroke(modules.get((int)cue.x).outs[(int)cue.y].cableCol);
      line(modules.get((int)cue.x).outs[(int)cue.y].pos.x+4, modules.get((int)cue.x).outs[(int)cue.y].pos.y+4, mouseX, mouseY);
    }    
  }
  if (selectionRect != null){
    shape(selectionRect, click.x, click.y);
  }
  
  //this is all the menu items
  if (menuActive){
    drawUI();
  }
  
  //for if a user goofs
  if (messageActive){
    message.display();
  }
  
  stroke(0);
  strokeWeight(1);
  text((int)frameRate, 1416, 18);
}

void gui(){
  
  mainMenu = cp5.addGroup("mainMenu")
    .setPosition(10, 100)
    .hideBar()    
    .disableCollapse()
    ; 
    
  cp5.addButton("hideMenu")
    .setPosition(10, 10)
    .setSize(15, 15)
    .setLabel("menu")
    .plugTo(this, "toggleMenu")
    ; 
    
  cp5.addButton("helpMode")
    .setPosition(35, 10)
    .setSize(15, 15)
    .setLabel("help")
    .plugTo(this, "toggleHelp")
    ;  
  
  cp5.addButton("resize")
    .setPosition(60, 10)
    .setSize(15, 15)
    .setLabel("res")
    .plugTo(this,"resizeAll")
    ;   
    
  cp5.addTextfield("dataWidth")
    .setLabel("")     
    .setPosition(80, 10)
    .setSize(25, 15)
    .setColor(color(255,0,0))
    .show()
    .setText("300")
    ; 
  
  cp5.addTextfield("dataHeight")
    .setLabel("")     
    .setPosition(110, 10)
    .setSize(25, 15)
    .setColor(color(255,0,0))
    .show()
    .setText("300")
    ; 
    
  cp5.addButton("save")
    .setPosition(150, 10)
    .setSize(15, 15)
    .setLabel("save")
    .plugTo(this,"savePatch")
    ;   
    
  cp5.addTextfield("savePath")
    .setLabel("")     
    .setPosition(170, 10)
    .setSize(75, 15)
    .setColor(color(255,0,0))
    .show()
    .setText("pix")
    ;
    
  cp5.addButton("load")
    .setPosition(255, 10)
    .setSize(15, 15)
    .setLabel("load")
    .plugTo(this,"loadPatch")
    ;
    
  cp5.addTextfield("loadPath")
    .setLabel("")     
    .setPosition(280, 10)
    .setSize(75, 15)
    .setColor(color(255,0,0))
    .show()
    .setText("pix")
    ;  
  
  //offset the entire menu vertically
  int sum = 0;
    
  for (int i = 1; i < generators.length; i++){
    cp5.addButton(generators[i])
    .setPosition(0, 15+sum+i*11)
    .setSize(10, 10)
    .setLabel("")
    .moveTo(mainMenu)
    ;
  }
  
  sum += 11*generators.length+8;
  
  for (int i = 1; i < arithmetic.length; i++){
    cp5.addButton(arithmetic[i])
    .setPosition(0, 15+sum+i*11)
    .setSize(10, 10)
    .setLabel("")
    .moveTo(mainMenu)
    ; 
  }
  
  sum += 11*arithmetic.length+8;
  
  for (int i = 1; i < analysis.length; i++){
    cp5.addButton(analysis[i])
    .setPosition(0, 15+sum+i*11)
    .setSize(10, 10)
    .setLabel("")
    .moveTo(mainMenu)
    ;      
  }
  
  sum += 11*analysis.length+8;

  
  for (int i = 1; i < transformation.length; i++){
    cp5.addButton(transformation[i])
    .setPosition(0, 15+sum+i*11)
    .setSize(10, 10)
    .setLabel("")
    .moveTo(mainMenu)
    ;      
  }
  
  sum += 11*transformation.length+8;

  for (int i = 1; i < utility.length; i++){
    cp5.addButton(utility[i])
    .setPosition(0, 15+sum+i*11)
    .setSize(10, 10)
    .setLabel("")
    .moveTo(mainMenu)
    ;      
  }
  
  sum += 11*utility.length+8;

  
  for (int i = 1; i < miscellaneous.length; i++){
    cp5.addButton(miscellaneous[i])
    .setPosition(0, 15+sum+i*11)
    .setSize(10, 10)
    .setLabel("")
    .moveTo(mainMenu)
    ;      
  }
  
  sum += 11*miscellaneous.length+8;

  
  for (int i = 1; i < modifiers.length; i++){
    cp5.addButton(modifiers[i])
    .setPosition(0, 15+sum+i*11)
    .setSize(10, 10)
    .setLabel("")
    .moveTo(mainMenu)
    ;      
  }  
  
  sum += 11*modifiers.length+8;

  
  for (int i = 1; i < output.length; i++){
    cp5.addButton(output[i])
    .setPosition(0, 15+sum+i*11)
    .setSize(10, 10)
    .setLabel("")
    .moveTo(mainMenu)
    ;      
  }  
  
  sum += 11*output.length+8;

       
   mainAcc = cp5.addAccordion("mainAcc")
     .setPosition(10, 10)
     .setWidth(100)
     .addItem(mainMenu)
     .disableCollapse()
     ;
     
   mainMenu.setOpen(true);  
}

void keyPressed(){
  //delete stuff
  if (keyCode == BACKSPACE){
    if (cue != null){
      cue = null;
    }
    for (Module m : modules){
      if (m.active){
        if (m.grabber.mouseOver){
          deleteSelectedModules();
        }
        for (OutputNode n : m.outs){
          for (int i = n.receivers.size() - 1; i >= 0; i--){
            if (connectionHovered(n.id, modules.get((int)n.receivers.get(i).x).ins[(int)n.receivers.get(i).y].id)){
              n.removeReceiver(n.receivers.get(i));
            }
          }
        }
        for (ModOutput n : m.modOuts){
          for (int i = n.receivers.size() - 1; i >= 0; i--){
            if (connectionHovered(n.id, modules.get((int)n.receivers.get(i).x).modIns[(int)n.receivers.get(i).y].id)){
              n.removeReceiver(n.receivers.get(i));
            }
          }
        }
      }
    }
  }
  if (key == 'c'){
    copySelectedModules(); 
  }
  if (key == 'q'){
    messageActive = false;
  }
  
  //setKeyState handles multi-key interactions
  setKeyState(key, keyCode, true);
  if (keyCode == UP){
    for (Module m : modules){
      if (m.active && m.selected){  
        if (shiftPressed){
          m.drag(new PVector(0, -11));
        } else {
          m.drag(new PVector(0, -1));
        }
      }
    }
  }
  if (keyCode == DOWN){
    for (Module m : modules){
      if (m.active && m.selected){  
        if (shiftPressed){
          m.drag(new PVector(0, 11));
        } else {
          m.drag(new PVector(0, 1));
        }
      }
    }
  }
  if (keyCode == LEFT){
    for (Module m : modules){
      if (m.active && m.selected){  
        if (shiftPressed){
          m.drag(new PVector(-11, 0));
        } else {
          m.drag(new PVector(-1, 0));
        }
      }
    }
  }
  if (keyCode == RIGHT){
    for (Module m : modules){
      if (m.active && m.selected){  
        if (shiftPressed){
          m.drag(new PVector(11, 0));
        } else {
          m.drag(new PVector(1, 0));
        }
      }
    }
  }
}

void keyReleased(){
  setKeyState(key, keyCode, false);
}

void setKeyState(int k, int kc, boolean isPressed){
  if (kc == SHIFT){
    shiftPressed = isPressed;
  }
  if (k == 'w'){
    wPressed = isPressed;
  }
  if (k == 'a'){
    aPressed = isPressed;
  }
  if (k == 's'){
    sPressed = isPressed;
  }
  if (k == 'd'){
    dPressed = isPressed;
  }
}

//is there a cleaner way to handle interaction?

void mousePressed(){ 
  for (Module m : modules){
    if (m.active){
      if (m.grabber.mouseOver){
        m.selected = true;
        m.grabber.onMousePressed();
        return;
      }
      for (InputNode n : m.ins){
        if (n.mouseOver){
          n.onMousePressed();
          return;
        }
      }
      for (OutputNode n : m.outs){
        if (n.mouseOver){
          n.onMousePressed();
          return;
        }    
      }
      for (ModInput n : m.modIns){
        if (n.mouseOver){
          n.onMousePressed();
          return;
        }  
      }
      if (m.isModifier){
        for (ModOutput n : m.modOuts){
          if (n.mouseOver){
            n.onMousePressed();
            return;
          } 
        }
      }
    }
  }
  if (mouseButton == RIGHT){
    for (Module m : modules){
      m.selected = false;
    }
    click = new PVector(mouseX, mouseY);
  }
}

void mouseClicked(){
  click = new PVector(mouseX, mouseY);
  for (Module m : modules){
    m.selected = false;
  }
}

void mouseDragged(){
  if (mouseButton == RIGHT){    
    stroke(0);
    strokeWeight(1);
    noFill();
    selectionRect = createShape(RECT, 0, 0, mouseX-click.x, mouseY-click.y);
  }  
}

void resizeAll(){
  globalWidth =  int(cp5.get(Textfield.class, "dataWidth").getText());
  globalHeight = int(cp5.get(Textfield.class, "dataHeight").getText());
  for (Flow f : stack){
    f.data = new float[globalWidth*globalHeight];
  }
  stack.get(0).blankFlow();
  for (Module m : modules){
    m.changeDataDimensions();
  }
}



void savePatch(){
  String[] patchInfo = new String[0];
  String[] connections = new String[0];
  int total = 0;
  for (Module m : modules){
    if (m.active){
      total++;
    }
  }
  
  //first line of the save file is number of modules so we know which line to look at
  //when it's time to build the appropriate connections
  patchInfo = append(patchInfo, str(total));      

  //save name, id, and position. Also save connections separately
  for (int i = 0; i < modules.size(); i++){
    if (modules.get(i).active){
      String theName = modules.get(i).name+",";
      String theId = str(modules.get(i).id)+",";
      String xPos = str((int)modules.get(i).pos.x)+",";
      String yPos = str((int)modules.get(i).pos.y)+",";      
      for (int j = 0; j < modules.get(i).outs.length; j++){
        for (PVector p : modules.get(i).outs[j].receivers){
          connections = append(connections, theId+str(j)+","+str((int)p.x)+","+str((int)p.y));
        }
      }
      String info = theName+theId+xPos+yPos;
      patchInfo = append(patchInfo, info);      
    }
  }
  
  //after the modules, a line that tells us how many connections are being made so we know where
  //to look to update Module UI
  //patchInfo = append(patchInfo, str(connections.length)); 
  
  //append all connections present in the patch to the end of the info String[]
  for (int i = 0; i < connections.length; i++){
    patchInfo = append(patchInfo, connections[i]);
  }

  //save the project as a text file
  String savePath =  "patches/"+cp5.get(Textfield.class, "savePath").getText()+".txt";
  saveStrings(savePath, patchInfo);
}

void loadPatch(){
  String loadPath =  "patches/"+cp5.get(Textfield.class, "loadPath").getText()+".txt";
  int prevCount = modules.size();
  try {
    String[] moduleInfo = loadStrings(loadPath);
    buildModulesFromSaveFile(moduleInfo);
    buildConnections(moduleInfo, prevCount);
  } catch (NullPointerException e){
    message = new MessageBox("no such file", new PVector(150, 50));
    messageActive = true;
  }
}

void mouseReleased(){
  for (Module m : modules){
    if (m.moving){
      m.moving = false;
    }
    for (ModInput n : m.modIns){
      if (n.pauseInput){
        n.pauseInput = false;
      }
    }
  }
  if (mouseButton == RIGHT){
    PVector release = new PVector(mouseX, mouseY);
    for (Module m : modules){
      if (isInsidePoints(m.pos, click, release)){
        m.selected = true;
      }
    }
    selectionRect = null;
  }
}

//is there a way to do this in module? would that be beneficial?
int getFileCount(String directory){
  File theDir = new File(directory);
  String[] fileList = theDir.list();
  return fileList.length;
}

void drawUI(){ 
  fill(255);
  textAlign(LEFT);
  textSize(12);
  for (int i = 0; i < UIText.length; i++){
    PVector headerPos = new PVector(cp5.getController(UIText[i][1]).getPosition()[0], cp5.getController(UIText[i][1]).getPosition()[1]);
    text(UIText[i][0], headerPos.x+10, headerPos.y+15);
    for (int j = 1; j < UIText[i].length; j++){
      PVector pos = new PVector(cp5.getController(UIText[i][j]).getPosition()[0], cp5.getController(UIText[i][j]).getPosition()[1]);
      text(UIText[i][j], pos.x+25, pos.y+28);
    }
  }
 
}

//this is completely unnecessary lol

class Flow{
 
  float[] data;
  
  Flow(){
    data = new float[globalWidth*globalHeight];
  }
  
  void blankFlow(){
    for (int i = 0; i < globalWidth; i++){
      for (int j = 0; j < globalHeight; j++){
        data[i+j*globalWidth] = 0;
      }
    }
  }
   
}

// Called by TheMidiBus library each time a knob, slider or button
// changes on the MIDI controller.
void controllerChange(int channel, int number, int value) {
  //println(channel, number, value);
  for (Module m : modules){
    if (m.active && m.isMidi){
      m.sendMidi(constrain(number, 0, 7), value);
    }
  }
}


void controlEvent(ControlEvent theEvent) {
  
  //radiobutton can't plugTo(), as plugTo is a Controller method, and 
  //radioButton is a Group. thus, we must use the name of the group
  //to point to the correct module and call the oppropriate method here.
  //this is why controllers have str(id) pinned to the end of their name
  
  //also worth noting that building a new Module that has radioButtons
  //will throw an indexOutOfBounds, as the creation of the radioButton
  //will call this method, and the module will attempt to operate
  //before it has been added to the ArrayList modules
  
  if (theEvent.isGroup()){
    if (theEvent.getName().substring(0, 7).equals("modType")){
      modules.get(int(theEvent.name().substring(7))).operate();
    }
    if (theEvent.getName().substring(0, 9).equals("noiseMode")){
      modules.get(int(theEvent.name().substring(9))).headsUp();
    }
    if (theEvent.getName().substring(0, 11).equals("comparisons")){
      modules.get(int(theEvent.name().substring(11))).headsUp();
    } 
    if (theEvent.getName().substring(0, 10).equals("kernelType")){
      modules.get(int(theEvent.name().substring(10))).presetKernel();
    } 
  }
  PVector pos_;
  if (modules.size() == 0){
    pos_ = new PVector(500, 20);
  } else{
    
    //lets the user choose where the module spawns with respect to the previously spawned module
    pos_ = new PVector(modules.get(modules.size()-1).pos.x, modules.get(modules.size()-1).pos.y);
    if (wPressed){
      pos_.add(new PVector(0, -modules.get(modules.size()-1).size.y-14));
    }
    if (aPressed){
      pos_.add(new PVector(-modules.get(modules.size()-1).size.x-14, 0));  
    }
    if (sPressed){
      pos_.add(new PVector(0, modules.get(modules.size()-1).size.y+14));
    }
    if (dPressed){
      pos_.add(new PVector(modules.get(modules.size()-1).size.x+14, 0));   
    } 
    
    //default puts the module below the previous one
    if (!(wPressed || aPressed || sPressed || dPressed)){
      pos_ = new PVector(modules.get(modules.size()-1).pos.x, modules.get(modules.size()-1).pos.y+modules.get(modules.size()-1).size.y+14);
    }
    pos_.set(constrain(pos_.x, 4, width-4), constrain(pos_.y, 4, height-4));
  }
  switch(theEvent.getController().getName()){
  case "noise" :
    modules.add(new NoiseGenerator(pos_));
    break;
  case "constant" :
    modules.add(new Constant(pos_));
    break;  
  case "display" :
    modules.add(new Displayer(pos_));
    break;
  case "basicMod" :
    modules.add(new Modifier(pos_));
    break;  
  case "image" :
    modules.add(new Image(pos_));
    break;
  case "video" :
    modules.add(new Vid(pos_));
    break;  
  case "math" :
    modules.add(new Math(pos_));
    break; 
  case "abs" :
    modules.add(new AbsoluteValue(pos_));
    break; 
  case "sampler" :
    modules.add(new Sampler(pos_));
    break;
  case "and" :
    modules.add(new And(pos_));
    break;
  case "or" :
    modules.add(new Or(pos_));
    break;
  case "xor" :
    modules.add(new XOr(pos_));
    break; 
  case "not" :
    modules.add(new Not(pos_));
    break;   
  case "+" :
    modules.add(new Add(pos_));
    break;
  case "-" :
    modules.add(new Subtract(pos_));
    break; 
  case "x" :
    modules.add(new Multiply(pos_));
    break;  
  case "/" :
    modules.add(new Divide(pos_));
    break; 
  case "feedback" :
    modules.add(new Feedback(pos_));
    break;
  case "rotate" :
    modules.add(new Rotate(pos_));
    break;
  case "reflect" :
    modules.add(new Reflect(pos_));
    break;   
  case "random" :
    modules.add(new Random(pos_));
    break;
  case "3D" :
    modules.add(new ThreeD(pos_));
    break; 
  case "scale" :
    modules.add(new Scale(pos_));
    break;
  case "convolve" :
    modules.add(new Convolve(pos_));
    break;
  case "interval" :
    modules.add(new Interval(pos_));
    break;
  case "translate" :
    modules.add(new Translate(pos_));
    break; 
  case "iterator" :
    modules.add(new Iterator(pos_));
    break;  
  case "kernel" :
    modules.add(new Kernel(pos_));
    break;
  case "structure" :
    modules.add(new StructuringElement(pos_));
    break;
  case "large structure" :
    modules.add(new LargeStructuringElement(pos_));
    break;  
  case "midi" :
    modules.add(new MidiMod(pos_));
    break;
  case "celato" :
    modules.add(new Celato(pos_));
    break;
  case "median" :
    modules.add(new MedianFilter(pos_));
    break;
  case "mean" :
    modules.add(new Mean(pos_));
    break; 
  case "variance" :
    modules.add(new Variance(pos_));
    break;   
  case "text" :
    modules.add(new TextGen(pos_));
    break;
  case "center" :
    modules.add(new CenterOfMass(pos_));
    break;  
  case "distance" :
    modules.add(new DistanceTransform(pos_));
    break; 
  case "histograb" :
    modules.add(new Histograb(pos_));
    break;
  case "dilate" :
    modules.add(new Dilate(pos_));
    break;
  case "erode" :
    modules.add(new Erode(pos_));
    break; 
  case "valley" :
    modules.add(new Valley(pos_));
    break; 
  case "peak" :
    modules.add(new Peak(pos_));
    break;
  case "local min" :
    modules.add(new LocalMin(pos_));
    break;   
  case "local max" :
    modules.add(new LocalMax(pos_));
    break;
  case "global min" :
    modules.add(new GlobalMin(pos_));
    break;   
  case "global max" :
    modules.add(new GlobalMax(pos_));
    break;  
  case "gray dilate" :
    modules.add(new GrayDilate(pos_));
    break;
  case "gray erode" :
    modules.add(new GrayErode(pos_));
    break;
  case "blob" :
    modules.add(new Blob(pos_));
    break;   
  case "DFT" :
    modules.add(new DFTModule(pos_));
    break; 
  case "IDFT" :
    modules.add(new IDFTModule(pos_));
    break;   
  case "hit and miss" :
    modules.add(new HitAndMiss(pos_));
    break;
  case "<" :
    modules.add(new LessThan(pos_));
    break;  
  case ">" :
    modules.add(new GreaterThan(pos_));
    break;  
  case "=" :
    modules.add(new Equal(pos_));
    break;  
  case "%" :
    modules.add(new Modulo(pos_));
    break; 
  case "log" :
    modules.add(new Log(pos_));
    break; 
  case "^" :
    modules.add(new Exp(pos_));
    break;   
  }
}

void buildModulesFromSaveFile(String[] info) {
  
  for (int i = 1; i < info.length; i++){
    String[] splitInfo = split(info[i], ",");
    PVector pos = new PVector(int(splitInfo[2]), int(splitInfo[3]));
    switch(splitInfo[0]){
    case "noise" :
      modules.add(new NoiseGenerator(pos));
      break;
    case "constant" :
      modules.add(new Constant(pos));
      break;  
    case "display" :
      modules.add(new Displayer(pos));
      break;
    case "basicMod" :
      modules.add(new Modifier(pos));
      break;  
    case "image" :
      modules.add(new Image(pos));
      break;
    case "video" :
      modules.add(new Vid(pos));
      break;  
    case "math" :
      modules.add(new Math(pos));
      break; 
    case "abs" :
      modules.add(new AbsoluteValue(pos));
      break; 
    case "sampler" :
      modules.add(new Sampler(pos));
      break;
    case "and" :
      modules.add(new And(pos));
      break;
    case "or" :
      modules.add(new Or(pos));
      break;
    case "xor" :
      modules.add(new XOr(pos));
      break; 
    case "not" :
      modules.add(new Not(pos));
      break;   
    case "+" :
      modules.add(new Add(pos));
      break;
    case "-" :
      modules.add(new Subtract(pos));
      break; 
    case "x" :
      modules.add(new Multiply(pos));
      break;  
    case "/" :
      modules.add(new Divide(pos));
      break; 
    case "feedback" :
      modules.add(new Feedback(pos));
      break;
    case "rotate" :
      modules.add(new Rotate(pos));
      break;
    case "reflect" :
      modules.add(new Reflect(pos));
      break;   
    case "random" :
      modules.add(new Random(pos));
      break;
    case "3D" :
      modules.add(new ThreeD(pos));
      break; 
    case "scale" :
      modules.add(new Scale(pos));
      break;
    case "convolve" :
      modules.add(new Convolve(pos));
      break;
    case "interval" :
      modules.add(new Interval(pos));
      break;
    case "translate" :
      modules.add(new Translate(pos));
      break; 
    case "iterator" :
      modules.add(new Iterator(pos));
      break;  
    case "kernel" :
      modules.add(new Kernel(pos));
      break;
    case "structure" :
      modules.add(new StructuringElement(pos));
      break;
    case "large structure" :
      modules.add(new LargeStructuringElement(pos));
      break;  
    case "midi" :
      modules.add(new MidiMod(pos));
      break;
    case "celato" :
      modules.add(new Celato(pos));
      break;
    case "median" :
      modules.add(new MedianFilter(pos));
      break;
    case "mean" :
      modules.add(new Mean(pos));
      break; 
    case "variance" :
      modules.add(new Variance(pos));
      break;   
    case "text" :
      modules.add(new TextGen(pos));
      break;
    case "center" :
      modules.add(new CenterOfMass(pos));
      break;  
    case "distance" :
      modules.add(new DistanceTransform(pos));
      break; 
    case "histograb" :
      modules.add(new Histograb(pos));
      break;
    case "dilate" :
      modules.add(new Dilate(pos));
      break;
    case "erode" :
      modules.add(new Erode(pos));
      break; 
    case "valley" :
      modules.add(new Valley(pos));
      break; 
    case "peak" :
      modules.add(new Peak(pos));
      break;
    case "local min" :
      modules.add(new LocalMin(pos));
      break;   
    case "local max" :
      modules.add(new LocalMax(pos));
      break;
    case "global min" :
      modules.add(new GlobalMin(pos));
      break;   
    case "global max" :
      modules.add(new GlobalMax(pos));
      break;  
    case "gray dilate" :
      modules.add(new GrayDilate(pos));
      break;
    case "gray erode" :
      modules.add(new GrayErode(pos));
      break;
    case "blob" :
      modules.add(new Blob(pos));
      break;   
    case "DFT" :
      modules.add(new DFTModule(pos));
      break; 
    case "IDFT" :
      modules.add(new IDFTModule(pos));
      break;   
    case "hit and miss" :
      modules.add(new HitAndMiss(pos));
      break;
    case "<" :
      modules.add(new LessThan(pos));
      break;  
    case ">" :
      modules.add(new GreaterThan(pos));
      break;  
    case "=" :
      modules.add(new Equal(pos));
      break;  
    case "%" :
      modules.add(new Modulo(pos));
      break; 
    case "log" :
      modules.add(new Log(pos));
      break; 
    case "^" :
      modules.add(new Exp(pos));
      break;   
    }
  }
}

//this method takes the total number of modules prior to the load,
//the id of the module as written in the save file, and a mapping
//from the old to new id in order to create a vector pointing to 
//the appropriate node in the current sketch.
int getIdFromMap(int count, int id, int[] map){
  int newId = 0;
  for (int i = 0; i < map.length; i++){
    if (map[i] == id){
      newId = count+i;
      //println(map[i], newId);
    }
  }
  return newId;
}

void buildConnections(String[] info, int prevCount){
  
  int totalAdded = int(info[0]);
  int[] idMap = new int[totalAdded];
  
  //build a connection mapping from old id to new id
  for (int i = 1; i <= totalAdded; i++){
    String[] splitInfo = split(info[i], ",");
    idMap[i-1] = int(splitInfo[1]);
  }
    
  for (int i = totalAdded+1; i < info.length; i++){    
    String[] splitInfo = split(info[i], ",");
    //println(splitInfo);
    PVector senderId = new PVector(getIdFromMap(prevCount, int(splitInfo[0]), idMap), int(splitInfo[1]));
    PVector receiverId = new PVector(getIdFromMap(prevCount, int(splitInfo[2]), idMap), int(splitInfo[3]));
    cue = new PVector(senderId.x, senderId.y);
    modules.get((int)receiverId.x).ins[(int)receiverId.y].onMousePressed();
  }
  
}
