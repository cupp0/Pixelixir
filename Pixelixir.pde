
/*

\\ video synthesizer //

Click the triangle to run.

~  ~  ~  ~  ~

~ ~ ~ PRE-RELEASE WORK ~ ~ ~

BUGS 

-iterator sometimes stackoverflows with filter depending on connection order
-feedback not initiating properly sometimes
-why does adding a rotate module glitch
-random NullPointerException in Constant, copied big chunk, rerouted a few things, then hooked up to a display

IMPROVEMENTS

- method of synchronizing video modules and starting recording in a display module when video playback is at frame 0

- improve Distance Transform algorithm and/or implement others

- bring the readme into the app

- modules inside loops should somehow communicate to the parent iterator when they should headsUp(). Maybe 
int loopId = -1 in Module that gets reassigned to every Module that is contained in a loop? Then we override
headsUp() and just call headsUp in the Iterator? Loop logic is still not tight. Could rewrite the whole mess

- HistMatch needs a better algorithm, it kinda sucks right now. I think it struggles with leftovers and outliers

- 3D modules need reworked. Honestly just make the camera usable

- implement fast median algorithm (almost done)

- Try/Catch list
  - creating a closed loop with module connections
  - typing a string into the save path text box
  - invalid inputs for the exp eval
  - if onMousePressed() in inputNode, try (array index out of bounds)
  
~ ~ ~ REFACTOR NOTES ~ ~ ~

- get rid of Flow. It does nothing. stack should be an arrayList of float[]

- collapse() method in Module. Look at number of ins, outs, modIns and modOuts to determine size
Only draw nodes, no CP5. Maybe shift+click the grabber collapes?

- make a node initialization method in Module

- Can we store every Node in a container in Module? Then have overwritten methods
like we do in lots of Module extensions? 

- make a cp5Handler method in Module

- make an abstract InputNode and OutputNode from which SignalInputNode and ModInputNode extend?

- address double counting scenarios in headsUp()

-For elements that use a structuring element and only care about the on state for their neighborhood,
should we store only PVectors pointing to the neighborhood instead of iterating through the whole 
dimension of the neighborhood for every pixel? Seems faster. Test it.

~ ~ ~ DREAM WORK ~ ~ ~

- saving patches 
  - figure out the best way to format and read text files
  - Store all relevant module info (id, pos, output receivers, slider positions)
  - build UI for saving and loading patches
  
- subpatches (once saving/loading is figured out, subpatches should be straightforward)
  - build module for subpatches, where user indicates number of inputs and outputs
  - idk how to do it

- resolution is determined by each display instead of globally. If module dimensions
  disagree, scale the larger one down to the smaller one
  
- fully fleshed out neighborhood functionality? Maybe a neighborhood logic/arithmetic section?

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
String[] arithmetic = {"MATH/LOGIC", "and", "or", "xor", "not", "<", ">", "=", "+", "-", "x", "/", "log", "exp", "%", "abs"};
String[] analysis = {"ANALYZE", "dilate", "erode", "peak", "valley", "hit and miss", "local min", "local max", "global min", "global max", "center", "distance", "gray dilate", "gray erode", "blob"};
String[] transformation = {"TRANSFORM", "translate", "scale", "rotate", "reflect"};
String[] filters = {"FILTER", "convolve", "mean", "median", "variance", "saturate"};
String[] utility = {"UTILITY", "feedback", "interval", "iterator", "histograb"};
String[] miscellaneous = {"MISC", "celato", "heightmap", "spheroid", "spindle"};
String[] modifiers = {"MODIFY", "basicMod", "sampler", "midi"};
String[] output = {"OUTPUT", "display"};

String[][] UIText = {generators, arithmetic, analysis, transformation, filters, utility, miscellaneous, modifiers, output};

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
  
  //offset the entire menu vertically
  int sum = 10;
    
  for (int i = 1; i < generators.length; i++){
    cp5.addButton(generators[i])
    .setPosition(0, 15+sum+i*10)
    .setSize(9, 9)
    .setLabel("")
    .moveTo(mainMenu)
    ;
  }
  
  sum += 10*generators.length+10;
  
  for (int i = 1; i < arithmetic.length; i++){
    cp5.addButton(arithmetic[i])
    .setPosition(0, 15+sum+i*10)
    .setSize(9, 9)
    .setLabel("")
    .moveTo(mainMenu)
    ; 
  }
  
  sum += 10*arithmetic.length+10;
  
  for (int i = 1; i < analysis.length; i++){
    cp5.addButton(analysis[i])
    .setPosition(0, 15+sum+i*10)
    .setSize(9, 9)
    .setLabel("")
    .moveTo(mainMenu)
    ;      
  }
  
  sum += 10*analysis.length+10;

  
  for (int i = 1; i < transformation.length; i++){
    cp5.addButton(transformation[i])
    .setPosition(0, 15+sum+i*10)
    .setSize(9, 9)
    .setLabel("")
    .moveTo(mainMenu)
    ;      
  }
  
  sum += 10*transformation.length+10;

  
  for (int i = 1; i < filters.length; i++){
    cp5.addButton(filters[i])
    .setPosition(0, 15+sum+i*10)
    .setSize(9, 9)
    .setLabel("")
    .moveTo(mainMenu)
    ;      
  }
  
  sum += 10*filters.length+10;

  
  for (int i = 1; i < utility.length; i++){
    cp5.addButton(utility[i])
    .setPosition(0, 15+sum+i*10)
    .setSize(9, 9)
    .setLabel("")
    .moveTo(mainMenu)
    ;      
  }
  
  sum += 10*utility.length+10;

  
  for (int i = 1; i < miscellaneous.length; i++){
    cp5.addButton(miscellaneous[i])
    .setPosition(0, 15+sum+i*10)
    .setSize(9, 9)
    .setLabel("")
    .moveTo(mainMenu)
    ;      
  }
  
  sum += 10*miscellaneous.length+10;

  
  for (int i = 1; i < modifiers.length; i++){
    cp5.addButton(modifiers[i])
    .setPosition(0, 15+sum+i*10)
    .setSize(9, 9)
    .setLabel("")
    .moveTo(mainMenu)
    ;      
  }  
  
  sum += 10*modifiers.length+10;

  
  for (int i = 1; i < output.length; i++){
    cp5.addButton(output[i])
    .setPosition(0, 15+sum+i*10)
    .setSize(9, 9)
    .setLabel("")
    .moveTo(mainMenu)
    ;      
  }  
  
  sum += 10*output.length+10;

       
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
  if (keyCode == UP){
    for (Module m : modules){
      if (m.active && m.selected){
        if (shiftPressed){      
          m.drag(new PVector(0, -12));
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
          m.drag(new PVector(0, 12));
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
          m.drag(new PVector(-12, 0));
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
          m.drag(new PVector(12, 0));
        } else {
          m.drag(new PVector(1, 0));
        }
      }
    }
  }
  setKeyState(keyCode, true);
}

void keyReleased(){
  setKeyState(keyCode, false);
}

void setKeyState(int k, boolean isPressed){
  if (k == SHIFT){
    shiftPressed = isPressed;
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
    pos_ = new PVector(modules.get(modules.size()-1).pos.x, (modules.get(modules.size()-1).pos.y+modules.get(modules.size()-1).size.y+15)%800);
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
  case "heightmap" :
    modules.add(new HeightMap(pos_));
    break;
  case "spheroid" :
    modules.add(new Spheroid(pos_));
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
  case "spindle" :
    modules.add(new Spindle(pos_));
    break;
  case "iterator" :
    modules.add(new Iterator(pos_));
    break;
  case "saturate" :
    modules.add(new Saturate(pos_));
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
  case "exp" :
    modules.add(new Exp(pos_));
    break;   
  }
}
