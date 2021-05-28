void deleteSelectedModules(){
  for (Module m : modules){
    if (m.active && m.selected){
      m.deleteModule();
    }
  }
}

void copySelectedModules(){
  ArrayList<Integer> selection = new ArrayList<Integer>();
  int currentSize = modules.size();
  for (int i = 0; i < currentSize; i++){
    if (modules.get(i).active && modules.get(i).selected){
      modules.get(i).copyModule();
      selection.add(modules.get(i).id);
    }
  }
  
  // *** mildly obnoxious ***  
  // build appropriate connections here
  
  // for every receiver of every module in the selection
  for (int i = 0; i < selection.size(); i++){
    for (int o = 0; o < modules.get(selection.get(i)).outs.length; o++){       
      for (int p = 0; p < modules.get(selection.get(i)).outs[o].receivers.size(); p++){
        //only build connections with other modules that were selected
        if (modules.get((int)modules.get(selection.get(i)).outs[o].receivers.get(p).x).selected){
          //new Sender
          int newSendId = modules.size()-(selection.size()-i);
          
          //old receiver
          PVector oldRecId = modules.get(selection.get(i)).outs[o].receivers.get(p).copy();
          
          //new receiver
          PVector newRecId = new PVector(modules.size()-(selection.size()-selection.indexOf((int)oldRecId.x)), oldRecId.y, oldRecId.z);
         
          cue = new PVector(newSendId, o);
          //println((int)newRecId.y);
          modules.get((int)newRecId.x).ins[(int)newRecId.y].onMousePressed();
        }
      }
    }
    if (modules.get(selection.get(i)).isModifier){
      for (int o = 0; o < modules.get(selection.get(i)).modOuts.length; o++){      
        for (int p = 0; p < modules.get(selection.get(i)).modOuts[o].receivers.size(); p++){
          
          //new Sender
          int newSendId = modules.size()-(selection.size()-i);
          
          //old receiver
          PVector oldRecId = modules.get(selection.get(i)).modOuts[o].receivers.get(p).copy();
          
          //new receiver
          PVector newRecId = new PVector(modules.size()-(selection.size()-selection.indexOf((int)oldRecId.x)), oldRecId.y, oldRecId.z);
         
          cue = new PVector(newSendId, o, -1);
          //println(modules.get(selection.get(i)).name);
          modules.get((int)newRecId.x).modIns[(int)newRecId.y].onMousePressed();
        }
      }
    } 
  }
  cue = null;
  for (int i : selection){
    modules.get(i).selected = false;
  }
}

//this method determines if a patch contains a closed loop
//current = the output that was cued for connection
//id = the input that was just pressed

boolean isClosedLoop(int current, int id){
  if (id == current){
    return true;
  }
  
  //for modules that are intended to contain closed loops at their ins/outs,
  //check only those nodes which shouldn't contain closed loops
  if (modules.get(id).isFeedback || modules.get(id).isIterator){
    for (int j = 0; j < modules.get(id).outs[0].receivers.size(); j++){
      int newb = (int)modules.get(id).outs[0].receivers.get(j).x;
      if (newb == current){
        return true;
      } else {
        return isClosedLoop(current, newb);
      }
    }
  } else {
    for (int i = 0; i < modules.get(id).outs.length; i++){    
      for (int j = 0; j < modules.get(id).outs[i].receivers.size(); j++){
        int newb = (int)modules.get(id).outs[i].receivers.get(j).x;
        if (newb == current){
          return true;
        } else {
          return isClosedLoop(current, newb);
        }
      }
    }
  }
  return false;
}

boolean isInside(PVector point, PVector target, PVector range){
  PVector p1 = target.copy().sub(abs(range.x), abs(range.y));
  PVector p2 = target.copy().add(abs(range.x), abs(range.y));
  boolean x = false;
  boolean y = false;
  if (p1.x < point.x){
    if (point.x <= p2.x){
      x = true;
    }
  }else if(point.x >= p2.x){
    x= true;
  }
  if (p1.y < point.y){
    if (point.y <= p2.y){
      y = true;
    }
  }else if(point.y >= p2.y){
    y= true;
  }
  if (x && y){
    return true;
  }else{
    return false;
  }
}

boolean isInsidePoints(PVector p, PVector p1, PVector p2){
  if (p1.y <= p.y){
    if (p.y <= p2.y){
    } else{
      return false;
    }      
  }else if(p.y >= p2.y){
  } else {
    return false;
  }
  if (p1.x <= p.x){
    if (p.x <= p2.x){
    } else{
      return false;
    }      
  }else if(p.x >= p2.x){
  } else {
    return false;
  }
  return true;
}

boolean flick(boolean switcher){
  if (switcher){
    return false;
  }else{
    return true;
  }   
}

PVector rotatePV(PVector point, PVector axis, float angle){
  float s = sin(angle);
  float c = cos(angle);
  point.x -= axis.x;
  point.y -= axis.y;
  float xnew = point.x * c - point.y * s;
  float ynew = point.x * s + point.y * c;
  point.x = xnew + axis.x;
  point.y = ynew + axis.y;
  return point;
}

//checks if we are hovering a connection between two provided nodes
//make it so that the hover region for vertically stacked Nodes is
//more than a pixel wide
boolean connectionHovered(PVector id1, PVector id2){
  PVector p = new PVector(mouseX, mouseY);
  PVector l1;
  PVector l2;
  
  //if the Node Classes were better this wouldn't be necessary
  if(id1.z < 0){
    l1 = modules.get((int)id1.x).modOuts[(int)id1.y].pos.copy();
    l1.add(4, 4);
    l2 = modules.get((int)id2.x).modIns[(int)id2.y].pos.copy();
    l2.add(4, 4);
  } else {
    l1 = modules.get((int)id1.x).outs[(int)id1.y].pos.copy();
    l1.add(4, 4);
    l2 = modules.get((int)id2.x).ins[(int)id2.y].pos.copy();
    l2.add(4, 4);
  }

  if (isInsidePoints(p, l1, l2)){
    if(abs((l1.y-l2.y)*p.x+(l2.x-l1.x)*p.y+l1.x*l2.y-l2.x*l1.y)/sqrt(pow(l2.x-l1.x, 2)+pow(l2.y-l1.y, 2)) < 4){
    return true;
    };  
  } 
  return false;
}

PVector scalePV(PVector point, PVector axis, float amount){
  point.x -= axis.x;
  point.y -= axis.y;
  point.mult(amount);
  point.x += axis.x;
  point.y += axis.y;
  return point;
}

//Button extension for Structuring Element module
class ThreeWay extends Button {

  PVector buttonId;
  int state = 0;
  color hit = #19FF19;
  color miss = #FF1919;
  color dontCare = #7F7F7F;
  color object = #FFC800;
  // use the convenience constructor of super class Controller
  // FourWay will automatically registered and move to the 
  // default controlP5 tab.
  
  ThreeWay(ControlP5 cp5, PVector buttonId_, int state_) {
    super(cp5, "struc"+str((int)buttonId_.y+(int)buttonId_.z*9)+"-"+str((int)buttonId_.x));
    super.setPosition(11+(int)buttonId_.y*16, 40+(int)buttonId_.z*16);
    super.setSize(14, 14);
    super.setLabel("");
    super.setGroup("g"+str((int)buttonId_.x));
     
    buttonId = buttonId_.copy();  
    state = state_;
    
    updateColor();
  }

  // override various input methods for mouse input control
  //void onEnter() {
  //}
  
  //void onScroll(int n) {
  //}
  
  void onPress() {
    state = (state+1)%3;
    updateColor();
    updateStructuringElement();
    modules.get((int)buttonId.x).headsUp();
  }
  
  void updateStructuringElement(){
    switch(state){
    case 0:
      modules.get((int)buttonId.x).structuringElement[(int)buttonId.y][(int)buttonId.z] = 0;
      break;
    case 1:
      modules.get((int)buttonId.x).structuringElement[(int)buttonId.y][(int)buttonId.z] = 255;
      break;
    case 2:
      modules.get((int)buttonId.x).structuringElement[(int)buttonId.y][(int)buttonId.z] = -1;
      break;  
    }
  }
  
  void turnOn(){
    state = 1;
    updateColor();
    updateStructuringElement();
  }
  
  void turnOff(){
    state = 0;
    updateColor();
    updateStructuringElement();
  }
  
  void turnDontCare(){
    state = 2;
    updateColor();
    updateStructuringElement();
  }
  
  void updateColor(){
    switch(state){
    case 0:
      setColorBackground(miss);
      break;
    case 1:
      setColorBackground(hit);
      break;
    case 2:
      setColorBackground(dontCare);
      break;   
    }
  }
  
 
  void onRelease() {
    
  }
  
  //void onMove() {
  //}

  //void onDrag() {
  //}
  
  //void onReleaseOutside() {
  //}

  //void onLeave() {
  //}
}

class HelpBox{
  
  PVector size;
  String info;
  
  HelpBox(String info_){
    info = info_;
    size = new PVector(170, 50+.89*info.length());
  }
  
  void display(PVector pos){
    stroke(0, 50, 100);
    fill(0, 75, 150);
    rect(pos.x, pos.y, size.x, size.y);
    fill(255);
    textSize(12);
    text(info, pos.x+5, pos.y+10, 165, 700);
  }
}

class MessageBox{
  
  PVector size;
  String info;
  
  MessageBox(String info_, PVector size_){
    info = info_;
    size = size_.copy();
  }
  
  void display(){
    stroke(0, 50, 100);
    fill(0, 75, 150);
    rect(mouseX, mouseY, size.x, size.y);
  
    fill(255);
    textAlign(CENTER);
    textSize(14);
    text(info, mouseX+size.x/2, mouseY+size.y/2);
    textSize(12);
    textAlign(LEFT);
    text("(hit q to disappear me)", mouseX+5, mouseY+size.y-5);
  }
  
}

String constantHelp = "CONSTANT\n-output a signal of constant value!\n-top slider sets the value\n-bottom slider is a multiplier for that value\n-top left button collapses the module (keep clutter down)";
String mathHelp = "MATH\n-evaluate a mathematical expression given in Reverse Polish Notation!\n-the uppermost text box is where you write an expression in terms of x and y\n-the lower 4 text boxes indicate the range over which to evaluate the expression, default is from (-10, -10) to (10, 10)\n-central button updates the output of the module\n-RPN crash course\n-'x+y' would be written'xy+'\n-'sin(x)*cos(y)' would be written 'xsyc*'\n-'9x-y^2' would be written '9x*y2^-'\n-list of available symbols\np - 3.141..             \ne - 2.718..            \n* - multiply            \n/ - divide\n+ - plus\n- - minus    \n^ - power\nr - sqrt\n% - modulus    \ns - sine    \nc - cosine    \na - absolute value    \nsingle digit values (text parser can't handle multiple digit values)";
String noiseHelp = "NOISE\n-Kurt Spencer's implementation of 2D OpenSimplex Noise!\n-text box with red zero is the noise seed and is used to sync seeds with other modules that use noise\n-buttons in the top right are for cartesian and polar mode\n-top 2 sliders determine how far the noise sampler steps in each direction from pixel to pixel\n-the bottom slider determines seed offset";
String randomHelp = "RANDOM\n-output random values!\n-outputs a float between 0 and 255 at every pixel\n-button runs the module with a new seed";
String videoHelp = "VIDEO\n-play an image sequence as a video!\n-top text box indicates the path of the folder containing the image sequence, starting at the videoSources directory in the sketch folder\n-top right button updates the folder path and loads the image sequence\n-images must be named sequentially, starting at 1, and must contain no preceding zeros (eg. 1.jpg, 2.jpg, 3.jpg)\n-supports tif, jpg, and png\n-top slider is playback speed\n-middle three buttons are retreat one frame, play/pause, and advance one frame\n-bottom slider scrubs, sort of\n-left output is overall brightness at each pixel, red green and blue are the individual color channels in the image";
String imageHelp = "IMAGE\n-output an image!\n-button opens file select prompt\n-left output sends brightness values, while the other three are individual color channels";
String textHelp = "TEXT\n-output text!\n-text box is text box\n-slider is text size";
String kernelHelp = "KERNEL\n-construct a convolution kernel!\n-choose from a list of common kernels, or if the Kernel input is active, the Module will sample that input signal to build a kernel.\n- convolution works by taking a weighted average of neighboring pixels, so whatever signal you use at the Kernel input should be scaled appropriately. Note that the numbers in the provided kernels typically sum to around 1\n-top left button collapses the module (keep clutter down)";
String structuringElementHelp = "STRUCTURING ELEMENT\n- Construct a structuring element to be used with analysis modules!\n-Use the sliders to determine the dimensions of the structuring element.\n-If the input is not active, manually construct the element by clicking the grid buttons.\n-Green = hit\n-Red = miss\n-Gray = don't care\n-If the input is active, the signal will be sampled to build the element\n-Requires binary or ternary input (-1 = don't care, 0 = miss, 255 = hit)\n-Click the button in the top left to collapse the kernel.";
String largeStructuringElementHelp = "LARGE STRUCTURING ELEMENT\n-For large structuring elements!\n-Use the sliders to determine the dimensions of the structuring element\n-Samples an input signal to construct a structuring element\n-Requires binary or ternary input (-1 = don't care, 0 = miss, 255 = hit)";
String dilateHelp = "DILATE\n-expand binary blobs!\n-The first input should be a binary signal and the second should be from a Structuring Element Module.\n-As with convolution kernels, the structuring element will be placed on top of every pixel in the input signal.\n-The green pixels in the structuring element will be considered.\n- The logic of the dilate module is as follows:\n-For every input signal pixel, if the pixel is black (0), and its neighborhood (given by the green pixels in the Structuring Element input) contains a white (255) pixel, make that pixel white at the output. Otherwise, push the input signal through to the output";
String erodeHelp = "ERODE\n-contract binary blobs!\n-The first input should be a binary signal and the second should be from a Structuring Element Module.\n-As with convolution kernels, the structuring element will be placed on top of every pixel in the input signal.\n-The green pixels in the structuring element will be considered.\n- The logic of the erode module is as follows:\n-For every input signal pixel, if the pixel is white (255), and its neighborhood (given by the green pixels in the Structuring Element input) contains a black (0) pixel, make that pixel black at the output. Otherwise, push the input signal through to the output";
String grayDilateHelp = "GRAYLEVEL DILATE\n-expand graylevel blobs!\n-The first input should be a binary signal and the second should be from a Structuring Element Module.\n- At each pixel in the input signal, output the maximum of the pixel's neighborhood.";
String grayErodeHelp = "GRAYLEVEL ERODE\n-contract graylevel blobs!\n-The first input should be a binary signal and the second should be from a Structuring Element Module.\n- At each pixel in the input signal, output the minimum of the pixel's neighborhood.";
String blobHelp = "CONNECTED COMPONENTS\n-identify and label connected regions in a binary signal!\n-This module reassigns every blob its own unique intensity value (up to 255 blobs, after which, multiple blobs may share an intensity value)";
String hitAndMissHelp = "HIT AND MISS\n-The most general use for the structuring element!\n-The first input should be a binary signal and the second should be from a Structuring Element Module.\n-As with convolution kernels, the structuring element will be placed on top of every pixel in the input signal.\n-All pixels in the structuring element will be considered.\n- For every input signal pixel, if it's neighborhood perfectly aligns with the Structuring Element, output 255. Else, output 0.";
String peakHelp = "PEAK\n-identify peaks in a graylevel signal!\n-output is a binary signal";
String valleyHelp = "VALLEY\n-identify valleys in a graylevel signal!\n-output is a binary signal";
String minHelp = "LOCAL MIN\n-identify local minimums in a graylevel signal!\n-first input is a graylevel signal, second input should be from a Structuring Element Module. It determines the neighborhood to be considered.\n-output is a binary signal";
String maxHelp = "LOCAL Max\n-identify local maximums in a graylevel signal!\n-first input is a graylevel signal, second input should be from a Structuring Element Module. It determines the neighborhood to be considered.\n-output is a binary signal";
String globalMinHelp = "GLOBAL MIN\n-output a constant signal at the global min of the input signal!";
String globalMaxHelp = "GLOBAL MAX\n-output a constant signal at the global max of the input signal!";
String distanceHelp = "DISTANCE TRANSFORM\n-output the distance transform for a binary signal";
String centerHelp = "CENTER OF MASS\n-find the center of mass of a signal!\n-The input signal can be either graylevel or binary.\n-The outputs are constant and correspond to the x and y coordinates of the center of mass, respectively.";
String andHelp = "AND\n-and two signals";
String orHelp = "OR\n- or two signals!";
String xorHelp = "XOR\n- exclusive or two signals!";
String notHelp = "Not\n- Invert a signal!";
String lessThanHelp = "LESS THAN\n-identify the lesser signal!\n-left output is a binary signal, and indicates the pixels where the left input is less than the right\n-right output combines the signals by taking the lesser of the two inputs at each pixel";
String greaterThanHelp = "GREATER THAN\n-identify the greater signal!\n-left output is a binary signal, and indicates the pixels where the left input is greater than the right\n-right output combines the signals by taking the greater of the two inputs at each pixel";
String equalHelp = "EQUAL\n-identify locations where the inputs are equal!\n-rounds input signal to integer values (they typically are floats) so that intersection points of 'continuous' signals get picked up";
String addHelp = "ADD\n- add two signals!";
String subtractHelp = "SUBTRACT\n-subtract one signal from another!";
String multiplyHelp = "MULTIPLY\n-multiply two signals!";
String divideHelp = "DIVIDE\n-divide one signal by another\n-second input values zero or below will be pushed to .00001";
String logHelp = "LOG\n-take the log of a signal\n-second input determines the base of the log at each pixel";
String powerHelp = "POWER\n-raise one signal to the power of another signal!\n- make sure to compress your signals appropriately!";
String moduloHelp = "MODULO\n-input one modulo input 2!\n-tends to compress the input signal a fair amount";
String absHelp = "ABSOLUTE VALUE\n-get the absolute value of a signal!";
String translateHelp = "TRANSLATE\n-translate one signal by another signal!\n-left input is the signal to be translated\n-right two inputs determine how much each pixel translates along the x and y axes\n-you can use constants for the translation inputs for linear shift, but any signal input will do";
String scaleHelp = "SCALE\n-scale the geometry of a signal!\n-first input is the signal to be scaled\n-interior two inputs define the scaling axis at each pixel\n-rightmost input is the scale amount";
String rotateHelp = "ROTATE\n-rotate the geomtry of a signal!\n-first input is the signal to be rotated\n-interior two inputs define the rotation axis at each pixel\n-rightmost input is the rotation amount";
String reflectHelp = "REFLECT\n-reflect the geomtry of a signal!\n-first input is the signal to be reflected\n-interior two inputs define the reflection axis at each pixel\n-rightmost input is the reflection amount";
String convolveHelp = "CONVOLVE\n-use a convolution kernel to filter a signal!\n-leftmost input is the signal to be filtered\n-next input is a mask. The filter will be applied to every pixel which is white in the mask input\n\n-the third input is used to build a convolution kernel. See the wiki page Kernel(Image Processing) for an explanation\n-the kernel is built by sampling the input signal at 9 points. look at the output of the 'sample' option in the kernel generator to understand where a signal is sampled to build a kernel\n-the grid of 9 values in the body of the module is the convolution kernel";
String medianHelp = "MEDIAN FILTER\n-Take the median of a neighborhood!\n-useful for removing speckles without losing sharpness";
String meanHelp = "MEAN FILTER\n-Take the average of a neighborhood!";
String dftHelp = "DISCRETE FOURIER TRANSFORM\n-get the fourier transform of an image!";
String idftHelp = "INVERSE DISCRETE FOURIER TRANSFORM\n-get the inverse fourier transform of an image!";
String varianceHelp = "VARIANCE FILTER\n-Take the statistical variance of a neighborhood!";
String histoHelp = "HISTOGRAM\n-a chart showing the frequency at which each intensity occurs in an image!";
String feedbackHelp = "FEEDBACK\n-feedback loops! very unstable!\n-";
String intervalHelp = "INTERVAL\n-intervallically send a signal!\n-the slider determines how many frames pass before INTERVAL sends its input signal to its output";
String iteratorHelp = "ITERATOR\n-do something many times! kind of unstable!\n-for when you have a section of your patch you'd like to repeat some number of times before continuing\n-the section to be looped will connect with the input and output nodes on the right side of the ITERATOR module\n-text box is for setting the max number of iterations; clicking the button next to the text box will update the max\n-the slider at the bottom sets the number of iterations executed\n-for instance, if you want a more dramatic blur/filter effect, put your filter inside the iterator loop and increase the number of iterations";
String celatoHelp = "CELATO\n-make your own cellular automata!\n-The default ruleset is Conway's Game of Life\n-The module works with a binary input and will output the next configuration as a binary signal\n-that means that you would need to hook it up to a FEEDBACK module to watch several consecutive configurations play out\n-rules are added by clicking the add button\n-the rules are of the following form, and everything in parnetheses is selected by the user by using the buttons, text box, and slider: If a cell is (dead/alive) and has (</>/=) (0, 1, 2, 3, 4, 5, 6, 7, 8) living neighbors, then in the next configuration, that cell will be (dead/alive)\n-clear the current ruleset with the clear button";
String heightmapHelp = "HEIGHT MAP\n-generate a 3D mesh!\n-first input is the z axis offset for each vertex in the model\n-second input is a radial offset for each vertex\n-rightmost input is a texture to be applied to the mesh\n-camera controls are funky/improvable/not worth explaining";
String spheroidHelp = "SPHEROID\n-generate a spheroid!\n-first input is a radial offset for each vertex in the mesh\n-second input is a texture applied to the mesh\n-camera controls are funky/improvable/not worth explaining ";
String spindleHelp = "SPINDLE\n-generate a 3D spindly thing!n-first input is a radial offset for each vertex in the mesh\n-second input is a texture applied to the mesh\n-camera controls are funky/improvable/not worth explaining ";
String modifierHelp = "MODULATOR\n-automate slider changes!\n-choose from several envelope types.\n-output is the gray node at bottom left. Can plug into gray nodes to the right of sliders in other modules.\n-Six buttons at left indicate envelope type. Seed text box allows you to sync noise seeds with another module\n-duration text box is the number of frames to get through one cycle through the envelope\n-phase should be a number less that the duration. It shifts the envelope\n-inv and rev buttons invert and reverse the envelope\n-the slider to the right is amplitude. it gets normalized to whatever it is plugged into.";
String samplerHelp = "SAMPLER\n-sample the first row of a signal to generate an envelope!\n-maybe you want an envelope that BASICMOD can't make\n-if you can generate a signal that approximates the envelope along the x axis, plug it into SAMPLER\n-it will sample the first row of the signal and generate an envelope\n-text box is duration\n-slider is an amplitude multiplier";
String midiHelp = "MIDI\n-drive animation with a midi controller!\n-if you have a USB midi device, plug it in before running.\n-in the Processing IDE, a message should print indicating which input your midi device is connected to\n- in the setup() method in modify.pde, change the line 'myBus = new MidiBus(this, 1, 1);' to 'myBus = new MidiBus(this, (your device input number here), 1);'\n- the module is currently set up for a controller with 8 faders, so the output number is constrained. that means any faders you have whose number is greater than 7 will be sent to the last output node of this module";
String displayHelp = "DISPLAY\n-see the signal!\n-the four inputs are graylevel and RGB\n-any inputs in RGB will override the graylevel input\n-the active button will activate/deactivate the display and all the calculations associated with that display. This is useful when you are doing work on a patch that is chuggaluggin. When deactivated, the frame rate will kick back up, making it easier to change connections, add modules etc. Click again to resume calculations and display\n-the still button takes a screenshot of the current display and saves it as a .tif in the 'screenshots' folder inside the main sketch folder\n- the record button saves the sequence of images that the display generates. It will save them at the location specified by the textbox to the right. A new folder will be created inside the sketch folder, which will be populated with whatever comes into the display module";
