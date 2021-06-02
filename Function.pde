/*

all modules that have inputs and outputs

here's a template

TEMPLATE:

class Template extends Module{
  
  Template(pos_){
    super(pos_);
    name = "template";
    size = new PVector(74, 26);
    c = color(50, 100, 150);
      
    cp5.addSlider("amount"+str(id))
      .setLabel("")
      .setPosition(3, 8)
      .setWidth(64)
      .setHeight(10)
      .setRange(0, 100)
      .setValue(10)
      .plugTo(this, "cp5Handler")
      .setGroup("g"+str(id))      
      ;  

     //these are the nodes that allow the user to interact with the module 
      
     grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));    
     ins = new InputNode[1];
     outs = new OutputNode[1];
     modIns = new ModInput[1];
    
     ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
     outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
     modIns[0] = new ModInput(new PVector(id, 0, -1), new PVector(pos.x+size.x-8, pos.y+45), "amount"+str(id));  
  }
  
  //handles UI interaction and tells modules below that something above them is changing
  void cp5Handler(float val){
    if (cp5.getController("amount"+str(id)).isMousePressed()){
      if (!modIns[0].pauseInput){
        modIns[0].baseVal = val;
        modIns[0].pauseInput = true;
      }
    }
    super.headsUp();
  }
  
  //this is the form of every operate in Module extensions that have ins and outs. 
  //super.operate() checks modules above to see if they need updated before performing 
  //the operation. super.lookDown() makes sure Modules below know that everything above
  //them is up to date
  
  void operate(){
    super.operate();
    int in = ins[0].flowId;
    int out = outs[0].flowId;
    float val = cp5.getController("amount"+str(id)).getValue();
      
    //adds the value of the slider to all the pixels in the input data
    //and writes those values to the output data
    for (int i = 0; i < globalWidth; i++){
      for (int j = 0; j < globalHeight; j++){
        stack.get(out).data[i+j*globalWidth] = stack.get(in).data[i+j*globalWidth]+val;
      }
    }
      
    super.lookDown();
  }
}

*/

//class Wanderer extends Module{
    
//  Wanderer(PVector pos_){
//    super(pos_);
//    name = "wander";
//    size = new PVector(100, 36);
//    c = color(50, 100, 150);
//    helper = new HelpBox(wandererHelp);
    
//    cp5.addSlider("target"+str(id))
//      .setLabel("")
//      .setPosition(4, 8)
//      .setWidth(88)
//      .setHeight(10)
//      .setRange(0, 255)
//      .setValue(255)
//      .plugTo(this, "cp5Handler")
//      .setGroup("g"+str(id))      
//      ;  
//    cp5.addSlider("tail"+str(id))
//      .setLabel("")
//      .setPosition(4, 20)
//      .setWidth(88)
//      .setHeight(10)
//      .setRange(-10, 10)
//      .setValue(-3)
//      .plugTo(this, "cp5Handler")
//      .setGroup("g"+str(id))      
//      ;     

//     //these are the nodes that allow the user to interact with the module 
      
//     grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));    
//     ins = new InputNode[1];
//     outs = new OutputNode[1];
//     modIns = new ModInput[2];
    
//     ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
//     outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
//     modIns[0] = new ModInput(new PVector(id, 0, -1), new PVector(pos.x+size.x-8, pos.y+11), "target"+str(id));  
//     modIns[1] = new ModInput(new PVector(id, 1, -1), new PVector(pos.x+size.x-8, pos.y+23), "tail"+str(id));  
//  }
  
//  //handles UI interaction and tells modules below that something above them is changing
//  void cp5Handler(float val){
//    if (cp5.getController("target"+str(id)).isMousePressed()){
//      if (!modIns[0].pauseInput){
//        modIns[0].baseVal = val;
//        modIns[0].pauseInput = true;
//      }
//    }
//    if (cp5.getController("tail"+str(id)).isMousePressed()){
//      if (!modIns[1].pauseInput){
//        modIns[1].baseVal = val;
//        modIns[1].pauseInput = true;
//      }
//    }
//    super.headsUp();
//  }
  
//  //this is the form of every operate in Module extensions that have ins and outs. 
//  //super.operate() checks modules above to see if they need updated before performing 
//  //the operation. super.lookDown() makes sure Modules below know that everything above
//  //them is up to date
  
//  void operate(){
//    super.operate();
        
//    int in = ins[0].flowId;
//    int out = outs[0].flowId;
//    float target = cp5.getController("target"+str(id)).getValue();
//    float tail = cp5.getController("tail"+str(id)).getValue();
//    ArrayList<PVector> travelers = new ArrayList<PVector>();
  
//    //adds the value of the slider to all the pixels in the input data
//    //and writes those values to the output data
//    for (int i = 0; i < globalWidth; i++){
//      for (int j = 0; j < globalHeight; j++){
//        float inPixel = stack.get(in).data[i+j*globalWidth];
//        if (inPixel == target){
//          travelers.add(new PVector(i, j));
//        }
//        if (inPixel+tail < 255 && inPixel+tail > 0){
//          stack.get(out).data[i+j*globalWidth] = inPixel+tail;
//        } else if (inPixel+tail < 0){
//          stack.get(out).data[i+j*globalWidth] = 0;
//        } else if (inPixel+tail > 255){
//          stack.get(out).data[i+j*globalWidth] = 255;
//        }
//      }
//    }
    
//    for (PVector p : travelers){
//      switch(floor(random(9))){
//      case 0 :
//        if (p.x < globalWidth - 1){
//          p.add(new PVector(1, 0));
//        }
//        break;
//      case 1 :
//        if (p.x < globalWidth - 1 && p.y < globalHeight - 1){
//          p.add(new PVector(1, 1));
//        }
//        break;
//      case 2 :
//        if (p.y < globalHeight - 1){
//          p.add(new PVector(0, 1));
//        }
//        break;
//      case 3 :
//        if (p.x > 0  && p.y < globalHeight - 1){
//          p.add(new PVector(-1, 1));
//        }
//        break;
//      case 4 :
//        if (p.x > 0){
//          p.add(new PVector(-1, 0));
//        }
//        break;
//      case 5 :
//        if (p.x > 0 && p.y > 0){
//          p.add(new PVector(-1, -1));
//        }
//        break;
//      case 6 :
//        if (p.y > 0){
//          p.add(new PVector(0, -1));
//        }
//        break;
//      case 7 :
//        if (p.x < globalWidth - 1 && p.y > 0){
//          p.add(new PVector(1, -1));
//        }
//        break;         
//      }
//    }
    
//    for (PVector p : travelers){
//      if ((int)p.x >= 0 && (int)p.x < globalWidth && (int)p.y >= 0 && (int)p.y < globalHeight){
//        stack.get(out).data[(int)p.x+(int)p.y*globalWidth] = target;
//      }
//    }
      
//    super.lookDown();
//  }
  
//}

class Histograb extends Module{
    
  Histograb(PVector pos_){
    super(pos_);
    name = "histograb";
    size = new PVector(41, 30);
    c = color(50, 150, 100);
    helper = new HelpBox(histoHelp);
     //these are the nodes that allow the user to interact with the module 
      
     grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));    
     ins = new InputNode[1];
     outs = new OutputNode[1];
     modIns = new ModInput[0];
    
     ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
     outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
  }
  
  //this is the form of every operate in Module extensions that have ins and outs. 
  //super.operate() checks modules above to see if they need updated before performing 
  //the operation. super.lookDown() makes sure Modules below know that everything above
  //them is up to date
  
  void operate(){
    super.operate();
        
    int in = ins[0].flowId;
    int out = outs[0].flowId;
    
    //used to count number of pixels at each intensity;
    int[] bin = new int[256];
    int maxFreq = 0;
    for (int i = 0; i < 256; i++){
      bin[i] = 0;
      
    }
    
    int totalPixels = globalWidth*globalHeight;
    
    for (int i = 0; i < totalPixels; i++){
      int val = (int)stack.get(in).data[i];
      bin[val] = bin[val] + 1;   
      if (bin[val] > maxFreq){
        maxFreq = bin[val];
      }
    }
    
    //println((float)bin[100]/totalPixels);
    
    for (int i = 0; i < globalWidth; i++){
      for (int j = 0; j < globalHeight; j++){
        int bindex = floor(256*(float)i/(float)globalWidth);
        float freq = map((float)bin[bindex], 0, maxFreq, 0, 255);
        //float val = 255 * (float)bin[bindex] / (float)totalPixels;
        stack.get(out).data[i+j*globalWidth] = freq;
        //println(val);
      }
    }
      
    super.lookDown();
  }
}

class Scale extends Module{
  
  Scale(PVector pos_){
    super(pos_);
    name = "scale";
    size = new PVector(106, 30);
    c = color(150, 50, 50);  
    helper = new HelpBox(scaleHelp);

    //these are the nodes that allow the user to interact with the module 
    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));     
    ins = new InputNode[4];
    outs = new OutputNode[1];
    modIns = new ModInput[0];
    
    ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
    ins[1] = new InputNode(new PVector(id, 1), new PVector(pos.x+size.x-40, pos.y));
    ins[2] = new InputNode(new PVector(id, 2), new PVector(pos.x+size.x-24, pos.y));
    ins[3] = new InputNode(new PVector(id, 3), new PVector(pos.x+size.x-8, pos.y));
    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
  }
  
  //this is the form of every operate in Module extensions that have ins and outs. 
  //super.operate() checks modules above to see if they need updated before performing 
  //the operation. super.lookDown() makes sure Modules below know that everything above
  //them is up to date
  
  void operate(){
    super.operate();
    
    int in = ins[0].flowId;
    int in1 = ins[1].flowId;
    int in2 = ins[2].flowId;
    int in3 = ins[3].flowId;
    int out = outs[0].flowId;
    
    for (int i = 0; i < globalWidth; i++){
      for (int j = 0; j < globalHeight; j++){
        int loc = i+j*globalWidth;
        PVector p = new PVector(i, j);
        PVector a = new PVector(stack.get(in1).data[loc], stack.get(in2).data[loc]);
        float amount = stack.get(in3).data[loc];
        PVector newLoc = scalePV(p, a, amount);
        if (0 <= newLoc.x && newLoc.x < globalWidth && 0 <= newLoc.y && newLoc.y < globalHeight){
          stack.get(out).data[loc] = stack.get(in).data[(int)newLoc.x+(int)newLoc.y*globalWidth];
        } else {
          stack.get(out).data[loc] = 0;
        }
      }
    }  
 
    super.lookDown();
  }
}

//class for custom cellular automata conditions of the form:
// ~ ~ ~ 
//If current cell is (dead/alive) and it has (</>/=) (x) neighbors that are (dead/alive),
//then the current cell should be (dead/alive) in the next cycle
// ~ ~ ~
//Celato module instantiates this object
class Condition{
  
  boolean state;
  String comparison;
  int val;
  boolean action;
  
  Condition(boolean state_, String comparison_, int val_, boolean action_){
    state = state_;
    comparison = comparison_;
    val = val_;
    action = action_;
  }
  
  //returns true if the condition applies to the current cell
  boolean conditionApplies(boolean cell, int livingNeighbors){
    if (cell == state){
      switch(comparison){
      case "<" :
        if (livingNeighbors < val){
          return true;
        }
        break;
      case ">" :
        if (livingNeighbors > val){
          return true;
        }
        break;
      case "=" :
        if (livingNeighbors == val){
          return true;
        }
        break;  
      }
    }
    return false;
  }
  
}

class Celato extends Module{
  
  Condition[] conditions = new Condition[0];
  boolean conditionIf;
  boolean conditionThen;
  
  Celato(PVector pos_){
    super(pos_);
    name = "celato";
    size = new PVector(120, 55);
    c = color(150, 100, 50);
    helper = new HelpBox(celatoHelp); 
       
    cp5.addButton("addCondition"+str(id))
      .setLabel("add")
      .setPosition(12, 12)
      .setSize(10, 10)
      .setGroup("g"+str(id))
      .plugTo(this, "addCondition")
      ;
      
    cp5.addButton("clearConditions"+str(id))
      .setLabel("clear")
      .setPosition(95, 12)
      .setSize(10, 10)
      .setGroup("g"+str(id))
      .plugTo(this, "clearConditions")
      ;  
      
    cp5.addToggle("ifAlive"+str(id))
      .setLabel("if")
      .setPosition(12, 30)
      .setSize(10, 10)
      .setGroup("g"+str(id))
      .plugTo(this, "conditionIf")
      ; 
      
    cp5.addTextfield("comparison"+str(id))
      .setLabel("comp")     
      .setPosition(27, 30)
      .setSize(10, 10)
      .setColor(color(255,0,0))
      .show()
      .setText("=")
      .setGroup("g"+str(id))
      ;
      
     cp5.addSlider("value"+str(id))
      .setLabel("val")     
      .setPosition(52, 10)
      .setSize(10, 30)
      .setRange(0, 8)
      .setValue(2)
      .setGroup("g"+str(id))
      .plugTo(this, "roundCP5")
      ; 
      
     cp5.addToggle("thenAlive"+str(id))
      .setLabel("then")
      .setPosition(95, 30)
      .setSize(10, 10)
      .setGroup("g"+str(id))
      .plugTo(this, "conditionThen")
      ;  
     //these are the nodes that allow the user to interact with the module 
      
     grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));    
     ins = new InputNode[1];
     outs = new OutputNode[1];
     modIns = new ModInput[0];
     
     ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
     outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
     
     setDefaultConditions();
     
  }
  
  void roundCP5(){
    cp5.getController("value"+str(id)).setValue(round(cp5.getController("value"+str(id)).getValue()));
  }
  
  //conditions for Conway's Game of Life
  void setDefaultConditions(){
    //die by underpopulation
    conditions = (Condition[])append(conditions, new Condition(true, "<", 2, false));
    //die by overpopulation
    conditions = (Condition[])append(conditions, new Condition(true, ">", 3, false));
    //birth
    conditions = (Condition[])append(conditions, new Condition(false, "=", 3, true));
  }
  
  void addCondition(){
    String comparison = cp5.get(Textfield.class, "comparison"+str(id)).getText();
    int val = (int)cp5.getController("value"+str(id)).getValue();
    conditions = (Condition[])append(conditions, new Condition(conditionIf, comparison, val, conditionThen));
  }
  
  void clearConditions(){
    conditions = new Condition[0];
  }
  
  void operate(){
    super.operate();
    
    int in = ins[0].flowId;
    int out = outs[0].flowId; 
    
    for (int i = 0; i < globalWidth; i++){
      for (int j = 0; j < globalHeight; j++){
        
        int loc = i+j*globalWidth;
        boolean currentPixel;
        if (stack.get(in).data[loc] == 255){
          currentPixel = true;
          stack.get(out).data[loc] = 255;
        } else {
          currentPixel = false;
          stack.get(out).data[loc] = 0;
        }        
        
        //Check if any of the conditions apply to the current pixel. If yes, assign pixel 
        //the value corresponding to that condition's action
        for (Condition c : conditions){  
          if (c.conditionApplies(currentPixel, getNeighborCount(in, i, j))){
            if(c.action){
              stack.get(out).data[loc] = 255;
            } else {
              stack.get(out).data[loc] = 0;             
            }
          }
        }
        
      }
    }  
 
    super.lookDown();
  }
  
  //
  int getNeighborCount(int flowId, int x, int y){
    int sum = 0;
    for (int i = -1; i < 2; i++){
      for (int j = -1; j < 2; j++){
        if (!(i == 0 && j == 0)){
          if(stack.get(flowId).data[constrain(x+i, 0, globalWidth-1)+constrain(y+j, 0, globalHeight-1)*globalWidth] >= 255){
            sum++;
          }
        }
      }
    }
    return sum;
  }
}

class Dilate extends Module{
    
  Dilate(PVector pos_){
    super(pos_);
    name = "dilate";
    size = new PVector(41, 30);
    c = color(50, 150, 100);
    helper = new HelpBox(dilateHelp);  
    //these are the nodes that allow the user to interact with the module 
    
    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));    
    ins = new InputNode[2];
    outs = new OutputNode[1];
   
    ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
    ins[1] = new InputNode(new PVector(id, 1), new PVector(pos.x+size.x-8, pos.y));
    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
  }
  
  void headsUp(){    
    if (ins[1].lookUp){
      updateStructuringElement();
    }
    super.headsUp();
  }
  
  //this is the form of every operate in Module extensions that have ins and outs. 
  //super.operate() checks modules above to see if they need updated before performing 
  //the operation. super.lookDown() makes sure Modules below know that everything above
  //them is up to date
  
  void operate(){
    super.operate();
    int in = ins[0].flowId;
    int in2 = ins[1].flowId;
    int out = outs[0].flowId;
    int xOff = (structuringElement.length-1)/2;
    int yOff = (structuringElement[0].length-1)/2;
    
    for (int i = 0; i < globalWidth; i++){
      for (int j = 0; j < globalHeight; j++){        
        int loc = i+j*globalWidth;
        
        //if the pixel is black
        if (stack.get(in).data[loc] == 0){
          boolean flipIt = false;
          
          //and if that pixel has any white neighbors
          for (int x = -xOff; x <= xOff; x++){
            for (int y = -yOff; y <= yOff; y++){            
              if (structuringElement[x+xOff][y+yOff] == 255){     
                int elementLoc = constrain(i+x, 0, globalWidth-1) + constrain(j+y, 0, globalHeight-1) * globalWidth;
                if (stack.get(in).data[elementLoc] == 255){
                  flipIt = true;
                }
              }
            }
          }
          
          //make it white
          if (flipIt){
            stack.get(out).data[loc] = 255;
          } else {
            stack.get(out).data[loc] = stack.get(in).data[loc];
          }
        } else {
          stack.get(out).data[loc] = stack.get(in).data[loc];
        }
      }
    }  
    super.lookDown();
  }
  
  void updateStructuringElement(){
    int xDim = modules.get((int)ins[1].sender.x).structuringElement.length;
    int yDim = modules.get((int)ins[1].sender.x).structuringElement[0].length;
    structuringElement = new int[xDim][yDim];
    arrayCopy(modules.get((int)ins[1].sender.x).structuringElement, structuringElement); 
  }
}

class HitAndMiss extends Module{ 
    
  HitAndMiss(PVector pos_){
    super(pos_);
    name = "hit and miss";
    size = new PVector(41, 30);
    c = color(50, 150, 100);
    helper = new HelpBox(hitAndMissHelp);  
      
    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));    
    ins = new InputNode[2];
    outs = new OutputNode[1];
   
    ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
    ins[1] = new InputNode(new PVector(id, 1), new PVector(pos.x+size.x-8, pos.y));
    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
  }
 
  void headsUp(){    
    if (ins[1].lookUp){
      updateStructuringElement();
    }
    super.headsUp();
  }
  
  void operate(){
    super.operate();
    
    int in1 = ins[0].flowId;
    int in2 = ins[1].flowId;
    int out = outs[0].flowId;
    int xOff = (structuringElement.length-1)/2;
    int yOff = (structuringElement[0].length-1)/2;
  
    for (int i = 0; i < globalWidth; i++){
      for (int j = 0; j < globalHeight; j++){        
        int loc = i+j*globalWidth;
        boolean success = true;
        
        //check if the current pixel perfectly overlaps the struc el
        for (int x = -xOff; x <= xOff; x++){
          for (int y = -yOff; y <= yOff; y++){            
            if (success && structuringElement[x+xOff][y+yOff] >= 0){     
              int elementLoc = constrain(i+x, 0, globalWidth-1) + constrain(j+y, 0, globalHeight-1) * globalWidth;
              if ((int)stack.get(in1).data[elementLoc] != structuringElement[x+xOff][y+yOff]){
                success = false;
                break;
              }
            }
          }
        }
        
        if (success){
          stack.get(out).data[loc] = 255;
        } else {
          stack.get(out).data[loc] = 0;
        }
        
      }
    }
    super.lookDown();
  } 
  
  void updateStructuringElement(){
    int xDim = modules.get((int)ins[1].sender.x).structuringElement.length;
    int yDim = modules.get((int)ins[1].sender.x).structuringElement[0].length;
    structuringElement = new int[xDim][yDim];
    arrayCopy(modules.get((int)ins[1].sender.x).structuringElement, structuringElement); 
  }
}

class Erode extends Module{
  
  Erode(PVector pos_){
    super(pos_);
    name = "erode";
    size = new PVector(41, 30);
    c = color(50, 150, 100);
    helper = new HelpBox(erodeHelp);  
    //these are the nodes that allow the user to interact with the module 
    
    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));    
    ins = new InputNode[2];
    outs = new OutputNode[1];
   
    ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
    ins[1] = new InputNode(new PVector(id, 1), new PVector(pos.x+size.x-8, pos.y));
    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
  }
  
  void headsUp(){    
    if (ins[1].lookUp){
      updateStructuringElement();
    }
    super.headsUp();
  }
  
  //this is the form of every operate in Module extensions that have ins and outs. 
  //super.operate() checks modules above to see if they need updated before performing 
  //the operation. super.lookDown() makes sure Modules below know that everything above
  //them is up to date
  
  void operate(){
    super.operate();
    int in = ins[0].flowId;
    int in2 = ins[1].flowId;
    int out = outs[0].flowId;
    int xOff = (structuringElement.length-1)/2;
    int yOff = (structuringElement[0].length-1)/2;
    
    for (int i = 0; i < globalWidth; i++){
      for (int j = 0; j < globalHeight; j++){        
        int loc = i+j*globalWidth;
        
        //if the pixel is white
        if (stack.get(in).data[loc] == 255){
          boolean flipIt = false;
          
          //and if that pixel has any black neighbors
          for (int x = -xOff; x <= xOff; x++){
            for (int y = -yOff; y <= yOff; y++){            
              if (structuringElement[x+xOff][y+yOff] == 255){     
                int elementLoc = constrain(i+x, 0, globalWidth-1) + constrain(j+y, 0, globalHeight-1) * globalWidth;
                if (stack.get(in).data[elementLoc] == 0){
                  flipIt = true;
                }
              }
            }
          }
          
          //make it black
          if (flipIt){
            stack.get(out).data[loc] = 0;
          } else {
            stack.get(out).data[loc] = stack.get(in).data[loc];
          }
        } else {
          stack.get(out).data[loc] = stack.get(in).data[loc];
        }
      }
    }  
    super.lookDown();
  }
  
  void updateStructuringElement(){
    int xDim = modules.get((int)ins[1].sender.x).structuringElement.length;
    int yDim = modules.get((int)ins[1].sender.x).structuringElement[0].length;
    structuringElement = new int[xDim][yDim];
    arrayCopy(modules.get((int)ins[1].sender.x).structuringElement, structuringElement); 
  }
}

class Valley extends Module{
  
  Valley(PVector pos_){
    super(pos_);
    name = "valley";
    size = new PVector(41, 30);
    c = color(50, 150, 100);
    helper = new HelpBox(valleyHelp);  
    //these are the nodes that allow the user to interact with the module 
      
    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));    
    ins = new InputNode[1];
    outs = new OutputNode[1];
   
    ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
  }
  
  
  //this is the form of every operate in Module extensions that have ins and outs. 
  //super.operate() checks modules above to see if they need updated before performing 
  //the operation. super.lookDown() makes sure Modules below know that everything above
  //them is up to date
  
  void operate(){
    super.operate();
    int in = ins[0].flowId;
    int out = outs[0].flowId;
  
    for (int i = 0; i < globalWidth; i++){
      for (int j = 0; j < globalHeight; j++){        
        int loc = i+j*globalWidth;
        stack.get(out).data[loc] = 0;
          //and if that pixel has any white neighbors
          for (int x = -2; x < 3; x+=2){
            for (int y = -2; y < 3; y+=2){
              int kernLoc = constrain(i+x, 0, globalWidth-1) + constrain(j+y, 0, globalHeight-1) * globalWidth;
              if (stack.get(in).data[kernLoc] > stack.get(in).data[loc]){
                int opp = constrain(i-x, 0, globalWidth-1) + constrain(j-y, 0, globalHeight-1) * globalWidth;
                if (stack.get(in).data[opp] > stack.get(in).data[loc]){
                  stack.get(out).data[loc] = 255;
                  break;
                } else {
                  stack.get(out).data[loc] = 0;
                }
              } 
            }
          }
      }
    }  
    super.lookDown();
  }
}

class Peak extends Module{
  
  Peak(PVector pos_){
    super(pos_);
    name = "peak";
    size = new PVector(41, 30);
    c = color(50, 150, 100);
    helper = new HelpBox(peakHelp);  
    //these are the nodes that allow the user to interact with the module 
      
    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));    
    ins = new InputNode[1];
    outs = new OutputNode[1];
   
    ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
  }
  
  
  //this is the form of every operate in Module extensions that have ins and outs. 
  //super.operate() checks modules above to see if they need updated before performing 
  //the operation. super.lookDown() makes sure Modules below know that everything above
  //them is up to date
  
  void operate(){
    super.operate();
    int in = ins[0].flowId;
    int out = outs[0].flowId;
  
    for (int i = 0; i < globalWidth; i++){
      for (int j = 0; j < globalHeight; j++){        
        int loc = i+j*globalWidth;
        stack.get(out).data[loc] = 0;
          for (int x = -1; x < 2; x++){
            for (int y = -1; y < 2; y++){
              int kernLoc = constrain(i+x, 0, globalWidth-1) + constrain(j+y, 0, globalHeight-1) * globalWidth;
              if (stack.get(in).data[kernLoc] < stack.get(in).data[loc]){
                int opp = constrain(i-x, 0, globalWidth-1) + constrain(j-y, 0, globalHeight-1) * globalWidth;
                if (stack.get(in).data[opp] < stack.get(in).data[loc]){
                  stack.get(out).data[loc] = 255;
                  break;
                } else {
                  stack.get(out).data[loc] = 0;
                }
              } 
            }
          }
      }
    }  
    super.lookDown();
  }
}

class GrayDilate extends Module{
  
  GrayDilate(PVector pos_){
    super(pos_);
    name = "gray dilate";
    size = new PVector(41, 30);
    c = color(50, 150, 100);
    helper = new HelpBox(grayDilateHelp);  
    //these are the nodes that allow the user to interact with the module 
      
    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));    
    ins = new InputNode[2];
    outs = new OutputNode[1];
   
    ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
    ins[1] = new InputNode(new PVector(id, 1), new PVector(pos.x+size.x-8, pos.y));
    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
  }
    
  void headsUp(){    
    if (ins[1].lookUp){
      updateStructuringElement();
    }
    super.headsUp();
  }
  
  void operate(){
    super.operate();
 
    int in1 = ins[0].flowId;
    int in2 = ins[1].flowId;
    int out = outs[0].flowId;
    int xOff = (structuringElement.length-1)/2;
    int yOff = (structuringElement[0].length-1)/2;
  
    for (int i = 0; i < globalWidth; i++){
      for (int j = 0; j < globalHeight; j++){        
        int loc = i+j*globalWidth;    
        float max = 0;
        
        //find the max among structuring element pixels
        for (int x = -xOff; x <= xOff; x++){
          for (int y = -yOff; y <= yOff; y++){            
            if (structuringElement[x+xOff][y+yOff] == 255){     
              int elementLoc = constrain(i+x, 0, globalWidth-1) + constrain(j+y, 0, globalHeight-1) * globalWidth;
              if (stack.get(in1).data[elementLoc] > max){
                max = stack.get(in1).data[elementLoc];
              }
            }
          }
        }
          
        stack.get(out).data[loc] = max;
      }
    }  
    super.lookDown();
  }
  
  void updateStructuringElement(){
    int xDim = modules.get((int)ins[1].sender.x).structuringElement.length;
    int yDim = modules.get((int)ins[1].sender.x).structuringElement[0].length;
    structuringElement = new int[xDim][yDim];
    arrayCopy(modules.get((int)ins[1].sender.x).structuringElement, structuringElement); 
  }
}

class GrayErode extends Module{
  
  GrayErode(PVector pos_){
    super(pos_);
    name = "gray erode";
    size = new PVector(41, 30);
    c = color(50, 150, 100);
    helper = new HelpBox(grayErodeHelp);  
    //these are the nodes that allow the user to interact with the module 
      
    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));    
    ins = new InputNode[2];
    outs = new OutputNode[1];
   
    ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
    ins[1] = new InputNode(new PVector(id, 1), new PVector(pos.x+size.x-8, pos.y));
    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
  }
  
  void headsUp(){    
    if (ins[1].lookUp){
      updateStructuringElement();
    }
    super.headsUp();
  }
  
  void operate(){
    super.operate();
    
    int in1 = ins[0].flowId;
    int in2 = ins[1].flowId;
    int out = outs[0].flowId;
    int xOff = (structuringElement.length-1)/2;
    int yOff = (structuringElement[0].length-1)/2;
  
    for (int i = 0; i < globalWidth; i++){
      for (int j = 0; j < globalHeight; j++){        
        int loc = i+j*globalWidth;
        float min = 255;
        
        //find the min among structuring element pixels
        for (int x = -xOff; x <= xOff; x++){
          for (int y = -yOff; y <= yOff; y++){            
            if (structuringElement[x+xOff][y+yOff] == 255){     
              int elementLoc = constrain(i+x, 0, globalWidth-1) + constrain(j+y, 0, globalHeight-1) * globalWidth;
              if (stack.get(in1).data[elementLoc] < min){
                min = stack.get(in1).data[elementLoc];
              }
            }
          }
        }
        
        stack.get(out).data[loc] = min;
      }
    }  
    super.lookDown();
  }
  
  void updateStructuringElement(){
    int xDim = modules.get((int)ins[1].sender.x).structuringElement.length;
    int yDim = modules.get((int)ins[1].sender.x).structuringElement[0].length;
    structuringElement = new int[xDim][yDim];
    arrayCopy(modules.get((int)ins[1].sender.x).structuringElement, structuringElement); 
  }
}

class Blob extends Module{
  
  float[] labels = new float[globalWidth*globalHeight];
  
  Blob(PVector pos_){
    super(pos_);
    name = "blob";
    size = new PVector(41, 30);
    c = color(50, 150, 100);
    helper = new HelpBox(blobHelp);  
    //these are the nodes that allow the user to interact with the module 
      
    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));    
    ins = new InputNode[1];
    outs = new OutputNode[1];
   
    ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
  }
  
  void floodFill(int x, int y, int count){
    
    ArrayList<PVector> queue = new ArrayList<PVector>();
    PVector current;
    queue.add(new PVector(x, y));
    
    
    //until all queued pixels have been labelled
    while (queue.size() > 0){
      
      //grab the pixel from the top of the queue, label it, then remove it from the queue
      current = queue.get(queue.size()-1).copy();
      labels[(int)current.x+(int)current.y*globalWidth] = count;
      queue.remove(queue.size()-1);
      
      //then add all cardinal neighbors that are on (255) at the input signal and haven't 
      //yet been labelled to the queueue
      
      //is this looping better / worse than just a single command for each direction?
      for (int i = -1; i < 2; i++){
        for (int j = -1; j < 2; j++){ 
          if ((i == 0 && j != 0) || (j == 0 && i != 0)){
            if ((int)current.x+i < globalWidth && (int)current.x+i >= 0 && (int)current.y+j < globalHeight && (int)current.y+j >= 0){
              int nLoc = (int)current.x+i+((int)current.y+j)*globalWidth;
              if (stack.get(ins[0].flowId).data[nLoc] == 255 && labels[nLoc] == 0){
                //println(str(current.x+i)+", "+str(current.y+j));
                queue.add(new PVector(current.x+i, current.y+j));
              }
            }
          } 
        }
      }
    }
  }
  
  void changeDataDimensions(){
    super.changeDataDimensions();
    labels = new float[globalWidth*globalHeight];  
  }
  
  void operate(){
    super.operate();
    
    int in = ins[0].flowId;
    int out = outs[0].flowId;
    int componentCount = 1;
    
    for (int i = 0; i < labels.length; i++){
      labels[i] = 0;
    }
    
    for (int i = 0; i < globalWidth; i++){
      for (int j = 0; j < globalHeight; j++){
        int loc = i+j*globalWidth;
        if (stack.get(in).data[loc] == 255 && labels[loc] == 0){
          floodFill(i, j, 1+(componentCount%254));
          componentCount++;
        }
      }
    }
    
    for (int i = 0; i < globalWidth; i++){
      for (int j = 0; j < globalHeight; j++){
        int loc = i+j*globalWidth;
        stack.get(out).data[loc] = labels[loc];
      }
    }
    
   
    super.lookDown();
  }
  
}

class DFT extends Module{
    
  DFT(PVector pos_){
    super(pos_);
    name = "DFT";
    size = new PVector(41, 30);
    c = color(50, 150, 100);
    helper = new HelpBox(dftHelp);  
    //these are the nodes that allow the user to interact with the module 
      
    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));    
    ins = new InputNode[1];
    outs = new OutputNode[2];
   
    ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
    outs[1] = new OutputNode(new PVector(id, 1), new PVector(pos.x+size.x-8, pos.y+size.y-8));
  }
  
  
  //add padding
  void operate(){
    super.operate();
    
    int in = ins[0].flowId;
    int out1 = outs[0].flowId;
    int out2 = outs[1].flowId;
    
    Complex[] complexInput = new Complex[globalWidth*globalHeight];
    Complex[] complexOutput = new Complex[globalWidth*globalHeight];
    for (int i = 0; i < globalWidth; i++){
      for (int j = 0; j < globalHeight; j++){
        int loc = i+j*globalWidth;
        complexInput[loc] = new Complex((double)stack.get(in).data[loc], 0);
      }
    }
    
    complexOutput = FFT.fft(complexInput);
    for (int i = 0; i < globalWidth; i++){
      for (int j = 0; j < globalHeight; j++){
        int loc = i+j * globalWidth;
        stack.get(out1).data[loc] = (float)complexOutput[loc].re;
        stack.get(out2).data[loc] = (float)complexOutput[loc].im;
      }
    }    
    super.lookDown();
  }
}

class DFTModule extends Module{
    
  DFTModule(PVector pos_){
    super(pos_);
    name = "DFT";
    size = new PVector(41, 30);
    c = color(50, 150, 100);
    helper = new HelpBox(dftHelp);  
    //these are the nodes that allow the user to interact with the module 
      
    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));    
    ins = new InputNode[1];
    outs = new OutputNode[2];
   
    ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
    outs[1] = new OutputNode(new PVector(id, 1), new PVector(pos.x+size.x-8, pos.y+size.y-8));
  }
  
  
  //add padding
  void operate(){
    super.operate();
    
    int in = ins[0].flowId;
    int out1 = outs[0].flowId;
    int out2 = outs[1].flowId;
    
    Complex[] complexInput = new Complex[globalWidth*globalHeight];
    Complex[] complexOutput = new Complex[globalWidth*globalHeight];

    //convert float inputs to complex values    
    for (int i = 0; i < globalWidth; i++){
      for (int j = 0; j < globalHeight; j++){
        int loc = i+j*globalWidth;
        complexInput[loc] = new Complex((double)stack.get(in).data[loc], 0);
      }
    }

    //do fft on complex values
    complexOutput = FFT.fft(complexInput);
    
    //send real and imaginary components to Module output
    for (int i = 0; i < globalWidth; i++){
      for (int j = 0; j < globalHeight; j++){
        int loc = i+j * globalWidth;
        stack.get(out1).data[loc] = (float)complexOutput[loc].re;
        stack.get(out2).data[loc] = (float)complexOutput[loc].im;
      }
    }    
    super.lookDown();
  }
}

class IDFTModule extends Module{
    
  IDFTModule(PVector pos_){
    super(pos_);
    name = "IDFT";
    size = new PVector(41, 30);
    c = color(50, 150, 100);
    helper = new HelpBox(idftHelp);  
    //these are the nodes that allow the user to interact with the module 
      
    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));    
    ins = new InputNode[2];
    outs = new OutputNode[1];
   
    ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
    ins[1] = new InputNode(new PVector(id, 1), new PVector(pos.x+size.x-8, pos.y));
    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
  }
  
  
  //add padding
  void operate(){
    super.operate();
    
    int in1 = ins[0].flowId;
    int in2 = ins[1].flowId;
    int out = outs[0].flowId;
    
    Complex[] complexInput = new Complex[globalWidth*globalHeight];
    Complex[] complexOutput = new Complex[globalWidth*globalHeight];

    //convert float inputs to complex values
    for (int i = 0; i < globalWidth; i++){
      for (int j = 0; j < globalHeight; j++){
        int loc = i+j*globalWidth;
        complexInput[loc] = new Complex((double)stack.get(in1).data[loc], (double)stack.get(in2).data[loc]);
      }
    }
    
    //do ifft on input
    complexOutput = FFT.ifft(complexInput);
    
    //send the real component out of the Module
    for (int i = 0; i < globalWidth; i++){
      for (int j = 0; j < globalHeight; j++){
        int loc = i+j * globalWidth;
        stack.get(out).data[loc] = (float)complexOutput[loc].re;
      }
    }    
    super.lookDown();
  }
}

class LocalMin extends Module{
  
  LocalMin(PVector pos_){
    super(pos_);
    name = "local min";
    size = new PVector(41, 30);
    c = color(50, 150, 100);
    helper = new HelpBox(minHelp);  
    //these are the nodes that allow the user to interact with the module 
      
    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));    
    ins = new InputNode[2];
    outs = new OutputNode[1];
   
    ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
    ins[1] = new InputNode(new PVector(id, 1), new PVector(pos.x+size.x-8, pos.y));
    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
  }
  
  void headsUp(){    
    if (ins[1].lookUp){
      updateStructuringElement();
    }
    super.headsUp();
  }
  
  //this is the form of every operate in Module extensions that have ins and outs. 
  //super.operate() checks modules above to see if they need updated before performing 
  //the operation. super.lookDown() makes sure Modules below know that everything above
  //them is up to date
  
  void operate(){
    super.operate();
    
    int in1 = ins[0].flowId;
    int in2 = ins[1].flowId;
    int out = outs[0].flowId;
    int xOff = (structuringElement.length-1)/2;
    int yOff = (structuringElement[0].length-1)/2;
  
    //handle edges separately
    for (int i = 0; i < globalWidth; i++){
      stack.get(out).data[i] = 0;
      stack.get(out).data[i+(globalHeight-1)*globalWidth] = 0;
    }
    
    for (int j = 1; j < globalHeight-1; j++){
      stack.get(out).data[j*globalWidth] = 0;
      stack.get(out).data[globalWidth-1+j*globalWidth] = 0;
    }
    
    //interior
    for (int i = 1; i < globalWidth-1; i++){
      for (int j = 1; j < globalHeight-1; j++){        
        int loc = i+j*globalWidth;
        boolean locMin = true;
        
        //find the min among structuring element pixels
        for (int x = -xOff; x <= xOff; x++){
          for (int y = -yOff; y <= yOff; y++){            
            if (structuringElement[x+xOff][y+yOff] == 255){     
              int elementLoc = constrain(i+x, 0, globalWidth-1) + constrain(j+y, 0, globalHeight-1) * globalWidth;
              if (stack.get(in1).data[elementLoc] < stack.get(in1).data[loc]){
                locMin =  false;
                break;
              }
            }
          }
        }
        if (locMin){
          stack.get(out).data[loc] = 255;
        } else {
          stack.get(out).data[loc] = 0;
        }
      }
    }
    super.lookDown();
  }
  
  void updateStructuringElement(){
    int xDim = modules.get((int)ins[1].sender.x).structuringElement.length;
    int yDim = modules.get((int)ins[1].sender.x).structuringElement[0].length;
    structuringElement = new int[xDim][yDim];
    arrayCopy(modules.get((int)ins[1].sender.x).structuringElement, structuringElement); 
  }
}

class LocalMax extends Module{
  
  LocalMax(PVector pos_){
    super(pos_);
    name = "local max";
    size = new PVector(41, 30);
    c = color(50, 150, 100);
    helper = new HelpBox(maxHelp);  
    //these are the nodes that allow the user to interact with the module 
      
    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));    
    ins = new InputNode[2];
    outs = new OutputNode[1];
   
    ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
    ins[1] = new InputNode(new PVector(id, 1), new PVector(pos.x+size.x-8, pos.y));
    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
  }
  
  void headsUp(){    
    if (ins[1].lookUp){
      updateStructuringElement();
    }
    super.headsUp();
  }
  
  //this is the form of every operate in Module extensions that have ins and outs. 
  //super.operate() checks modules above to see if they need updated before performing 
  //the operation. super.lookDown() makes sure Modules below know that everything above
  //them is up to date
  
  void operate(){
    super.operate();
    
    int in1 = ins[0].flowId;
    int in2 = ins[1].flowId;
    int out = outs[0].flowId;
    int xOff = (structuringElement.length-1)/2;
    int yOff = (structuringElement[0].length-1)/2;
  
    //handle edges separately
    for (int i = 0; i < globalWidth; i++){
      stack.get(out).data[i] = 0;
      stack.get(out).data[i+(globalHeight-1)*globalWidth] = 0;
    }
    
    for (int j = 1; j < globalHeight-1; j++){
      stack.get(out).data[j*globalWidth] = 0;
      stack.get(out).data[globalWidth-1+j*globalWidth] = 0;
    }
    
    //interior
    for (int i = 1; i < globalWidth-1; i++){
      for (int j = 1; j < globalHeight-1; j++){        
        int loc = i+j*globalWidth;
        boolean locMax = true;
        
        //find the max among structuring element pixels
        for (int x = -xOff; x <= xOff; x++){
          for (int y = -yOff; y <= yOff; y++){            
            if (structuringElement[x+xOff][y+yOff] == 255){     
              int elementLoc = constrain(i+x, 0, globalWidth-1) + constrain(j+y, 0, globalHeight-1) * globalWidth;
              if (stack.get(in1).data[elementLoc] > stack.get(in1).data[loc]){
                locMax =  false;
                break;
              }
            }
          }
        }
        if (locMax){
          stack.get(out).data[loc] = 255;
        } else {
          stack.get(out).data[loc] = 0;
        }
      }
    }
    super.lookDown();
  }
  
  void updateStructuringElement(){
    int xDim = modules.get((int)ins[1].sender.x).structuringElement.length;
    int yDim = modules.get((int)ins[1].sender.x).structuringElement[0].length;
    structuringElement = new int[xDim][yDim];
    arrayCopy(modules.get((int)ins[1].sender.x).structuringElement, structuringElement); 
  }
}

class GlobalMin extends Module{
  
  GlobalMin(PVector pos_){
    super(pos_);
    name = "global min";
    size = new PVector(41, 30);
    c = color(50, 150, 100);
    helper = new HelpBox(globalMinHelp);  
    //these are the nodes that allow the user to interact with the module 
      
    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));    
    ins = new InputNode[1];
    outs = new OutputNode[1];
   
    ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
  }
  
  void operate(){
    super.operate();
    int in = ins[0].flowId;
    int out = outs[0].flowId;
    float min = stack.get(in).data[0];
    
    for (int i = 1; i < globalWidth*globalHeight-1; i++){
      if (stack.get(in).data[i] < min){
        min = stack.get(in).data[i];
      }
    }
    
    for (int i = 0; i < globalWidth*globalHeight-1; i++){
      stack.get(out).data[i] = min;
    }
    super.lookDown();
  }
  
  void display(){
    super.display();
    text(str(int(stack.get(outs[0].flowId).data[0])), pos.x+10, pos.y+22);
  }
}

class GlobalMax extends Module{
  
  GlobalMax(PVector pos_){
    super(pos_);
    name = "global max";
    size = new PVector(41, 30);
    c = color(50, 150, 100);
    helper = new HelpBox(globalMaxHelp);  
    //these are the nodes that allow the user to interact with the module 
      
    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));    
    ins = new InputNode[1];
    outs = new OutputNode[1];
   
    ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
  }
  
  
  //this is the form of every operate in Module extensions that have ins and outs. 
  //super.operate() checks modules above to see if they need updated before performing 
  //the operation. super.lookDown() makes sure Modules below know that everything above
  //them is up to date
  
  void operate(){
    super.operate();
    int in = ins[0].flowId;
    int out = outs[0].flowId;
    float max = stack.get(in).data[0];
    
    for (int i = 1; i < globalWidth*globalHeight-1; i++){
      if (stack.get(in).data[i] > max){
        max = stack.get(in).data[i];
      }
    }
    
    for (int i = 0; i < globalWidth*globalHeight-1; i++){
      stack.get(out).data[i] = max;
    }
    super.lookDown();
  }
  
  void display(){
    super.display();
    text(str(int(stack.get(outs[0].flowId).data[0])), pos.x+10, pos.y+22);
  }
}

class CenterOfMass extends Module{
  
  CenterOfMass(PVector pos_){
    super(pos_);
    name = "center";
    size = new PVector(72, 30);
    c = color(50, 150, 100);
    helper = new HelpBox(centerHelp);  
    //these are the nodes that allow the user to interact with the module 
      
    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));    
    ins = new InputNode[1];
    outs = new OutputNode[2];
   
    ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
    outs[1] = new OutputNode(new PVector(id, 1), new PVector(pos.x+size.x-8, pos.y+size.y-8));
  }
  
  
  //this is the form of every operate in Module extensions that have ins and outs. 
  //super.operate() checks modules above to see if they need updated before performing 
  //the operation. super.lookDown() makes sure Modules below know that everything above
  //them is up to date
  
  void operate(){
    super.operate();
    int in = ins[0].flowId;
    int out1 = outs[0].flowId;
    int out2 = outs[1].flowId;
    
    PVector sum = new PVector(0,0);
    //int counter = 0;
    float mass = 0;
    
    for (int i = 0; i < globalWidth; i++){
      for (int j = 0; j < globalHeight; j++){
        float val = stack.get(in).data[i+j*globalWidth];
        sum.add(i*val, j*val);
        mass += val;;
      }
    }
    
    //for (int i = 0; i < globalWidth; i++){
    //  for (int j = 0; j < globalHeight; j++){  
    //    if (stack.get(in).data[i+j*globalWidth] == 255){
    //      sum.add(i, j);
    //      counter++;
    //    }
    //  }
    //}  
    
    //sum.div(counter);
    sum.div(mass);
    for (int i = 0; i < globalWidth*globalHeight; i++){
      stack.get(out1).data[i] = sum.x;
      stack.get(out2).data[i] = sum.y;     
    }
    
    super.lookDown();
  }
  
  void display(){
    super.display();
    text(str(int(stack.get(outs[0].flowId).data[0]))+", "+str(int(stack.get(outs[1].flowId).data[0])), pos.x+8, pos.y+22);
  }
}

class Translate extends Module{
  
  Translate(PVector pos_){
    super(pos_);
    name = "translate";
    size = new PVector(72, 30);
    c = color(150, 50, 50);  
    helper = new HelpBox(translateHelp);
    //these are the nodes that allow the user to interact with the module 
      
    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));    
    ins = new InputNode[3];
    outs = new OutputNode[1];
   
    ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
    ins[1] = new InputNode(new PVector(id, 1), new PVector(pos.x+size.x-24, pos.y));
    ins[2] = new InputNode(new PVector(id, 2), new PVector(pos.x+size.x-8, pos.y));
    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
  }
  
  
  //this is the form of every operate in Module extensions that have ins and outs. 
  //super.operate() checks modules above to see if they need updated before performing 
  //the operation. super.lookDown() makes sure Modules below know that everything above
  //them is up to date
  
  void operate(){
    super.operate();
    int in = ins[0].flowId;
    int in2 = ins[1].flowId;
    int in3 = ins[2].flowId;
    int out = outs[0].flowId;
    
    //maybe use float for offset and interpolate? or is that too slow?
    for (int i = 0; i < globalWidth; i++){
      for (int j = 0; j < globalHeight; j++){
        int loc = i+j*globalWidth;
        float horizontal = (float)i+stack.get(in2).data[loc];
        float vertical = (float)j+stack.get(in3).data[loc];
        if (horizontal >= 0 && horizontal < globalWidth && vertical >= 0 && vertical < globalHeight){
          stack.get(out).data[loc] = stack.get(in).data[(int)(horizontal+vertical*(float)globalWidth)];
        } else {
          stack.get(out).data[loc] = 0;
        }
      }
    }  
    super.lookDown();
  }
}

//expects binary input
class DistanceTransform extends Module{
  
  DistanceTransform(PVector pos_){
    super(pos_);
    name = "distance";
    size = new PVector(41, 30);
    c = color(50, 150, 100);
    helper = new HelpBox(distanceHelp);
     //these are the nodes that allow the user to interact with the module 
      
    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));    
    ins = new InputNode[1];
    outs = new OutputNode[1];
   
    ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
  }
  
  
  //this is the form of every operate in Module extensions that have ins and outs. 
  //super.operate() checks modules above to see if they need updated before performing 
  //the operation. super.lookDown() makes sure Modules below know that everything above
  //them is up to date
  
  void operate(){
    super.operate();
    int in = ins[0].flowId;
    int out = outs[0].flowId;
    
    for (int i = 0; i < globalWidth; i++){
      
      //in every colum store every point that has value 255
      ArrayList<Integer> peaks = new ArrayList<Integer>();
      for (int j = 0; j < globalHeight; j++){
        if (stack.get(in).data[i+j*globalWidth] == 255){
          peaks.add(j);
        }
      }
      
      //if no values of 255 in a column, store a zero
      if (peaks.size() == 0){
        for (int j = 0; j < globalHeight; j++){
          stack.get(out).data[i+j*globalWidth] = 0;
        }
      } else {
        for (int x = 0; x < peaks.size(); x++){
          
          int current = peaks.get(x);
          int upperBound;
          
          if (x == 0){
            upperBound = peaks.get(x);
          } else {
            upperBound = floor((current-peaks.get(x-1))/2);
          }
          for (int y = 0; y <= upperBound; y++){
            stack.get(out).data[i+(current-y)*globalWidth] = 255-y;
            //assignments++;
          }
          
          int lowerBound;
          if (x == peaks.size()-1){
            lowerBound = globalHeight-peaks.get(x)-1;
          } else {
            lowerBound = floor((peaks.get(x+1)-current)/2);
          }
          for (int y = 0; y <= lowerBound; y++){
            stack.get(out).data[i+(current+y)*globalWidth] = 255-y;
            //assignments++;
          }
        } 
      }
    }
    
    for (int j = 0; j < globalHeight; j++){
      float tracker = stack.get(out).data[j*globalWidth];
      for (int i = 1; i < globalWidth; i++){
        int loc = i+j*globalWidth;
        if (stack.get(out).data[loc] < tracker - 1){
          tracker--;
          stack.get(out).data[loc] = tracker;
        } else {
          tracker = stack.get(out).data[loc];
        }        
      }
      //tracker = stack.get(out).data[j*globalWidth];
      for (int i = globalWidth-1; i >= 0; i--){
        int loc = i+j*globalWidth;
        if (stack.get(out).data[loc] < tracker - 1){
          tracker--;
          stack.get(out).data[loc] = tracker;
        } else {
          tracker = stack.get(out).data[loc];
        }        
      }  
    }
    super.lookDown();
  }
}

//works on small displays! Not big or medium ones
//class EuclideanDistanceTransform extends Module{
  
//  EuclideanDistanceTransform(PVector pos_){
//    super(pos_);
//    name = "euclidean";
//    size = new PVector(41, 30);
//    c = color(50, 150, 100);
//    helper = new HelpBox(distanceHelp);
//     //these are the nodes that allow the user to interact with the module 
      
//    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));    
//    ins = new InputNode[1];
//    outs = new OutputNode[1];
   
//    ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
//    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
//  }
  
//  void operate(){
//    super.operate();
    
//    int in = ins[0].flowId;
//    int out = outs[0].flowId;
    
//    PVector[] roots = new PVector[globalWidth*globalHeight];
//    float[] distance = new float[globalWidth*globalHeight];
//    for (int i = 0; i < roots.length; i++){
//      distance[i] = 1048576;
//    }
    
//    ArrayList<PVector> queue = new ArrayList<PVector>();
//    for (int i = 0; i < globalWidth; i++){
//      for (int j = 0; j < globalHeight; j++){
//        if (stack.get(in).data[i+j*globalWidth] == 255){
//          PVector pv = new PVector(i, j);
//          int loc = i+j*globalWidth;
//          distance[loc] = 0;
//          roots[loc] = pv.copy();
//          queue.add(pv);
//        }
//      }
//    }
    
//    PVector current;
    
//    //until all queued pixels have been labelled
//    while (queue.size() > 0){
      
//      //grab the pixel from the top of the queue, then remove it from the queue
//      current = queue.get(queue.size()-1).copy();
//      queue.remove(queue.size()-1);
      
//      for (int i = -1; i <=1; i++){
//        for (int j = -1; j <=1; j++){ 
//          int neighborX = constrain((int)current.x+i, 0, globalWidth-1);
//          int neighborY = constrain((int)current.y+j, 0, globalHeight-1);
//          int neighborLoc = neighborX+neighborY*globalWidth;
//          if (!(i == 0 && j == 0) && distance[neighborLoc]>0){
//            PVector neighbor = new PVector(neighborX, neighborY);
//            PVector currentRoot = roots[(int)current.x+(int)current.y*globalWidth].copy();
//            float d = currentRoot.dist(neighbor);
//            if (d < distance[neighborLoc]){
//              distance[neighborLoc] = d;
//              roots[neighborLoc] = currentRoot.copy();
//              queue.add(neighbor);
//            }
//          } 
//        }
//      }
//    }
    
//    for (int i = 0; i < globalWidth; i++){
//      for (int j = 0; j < globalHeight; j++){
//        int loc = i+j*globalWidth;
//        stack.get(out).data[loc] = distance[loc];
//      }
//    }
//  }
//}

class Interval extends Module{
    
  Interval(PVector pos_){
    super(pos_);
    name = "interval";
    size = new PVector(110, 48);
    c = color(200);
    helper = new HelpBox(intervalHelp);   
  
    cp5.addTextfield("maxInterval"+str(id))
      .setLabel("max")     
      .setPosition(8, 12)
      .setSize(20, 10)
      .setColor(color(255,0,0))
      .show()
      .setText("10")
      .setGroup("g"+str(id))
      ;
      
    cp5.addButton("updateMax"+str(id))  
      .setLabel("")
      .setPosition(35, 12)
      .setSize(10, 10)
      .plugTo(this, "updateMaxInterval")
      .setGroup("g"+str(id))
      ;
      
    cp5.addSlider("interval"+str(id))
      .setLabel("")
      .setPosition(8, 26)
      .setWidth(88)
      .setHeight(10)
      .setRange(1, 10)
      .setValue(2)
      .plugTo(this, "cp5Handler")
      .setGroup("g"+str(id))      
      ;
      
     grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));    
     ins = new InputNode[1];
     outs = new OutputNode[1];
     modIns = new ModInput[1];
    
     ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
     outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
     modIns[0] = new ModInput(new PVector(id, 0, -1), new PVector(pos.x+size.x-8, pos.y+27), "interval"+str(id));  
  }

  void updateMaxInterval(){
    int newMax = int(cp5.get(Textfield.class, "maxInterval"+str(id)).getText());
    Slider s = (Slider)cp5.getController("interval"+str(id));
    s.setRange(1, newMax);
  }
  
  //handles UI interaction and tells modules below that something above them is changing
  void cp5Handler(float val){
    if (cp5.getController("interval"+str(id)).isMousePressed()){
      if (!modIns[0].pauseInput){
        modIns[0].baseVal = val;
        modIns[0].pauseInput = true;
      }
    }
    super.headsUp();
  }
  
  void headsUp(){
    if (super.allSystemsGo() && frameCount%(int)cp5.getController("interval"+str(id)).getValue() == 0){
      super.headsUp();
    }
  }
  
  void display(){
    super.display();
    headsUp();
  }
  
  void operate(){
    super.operate();
  
    int in = ins[0].flowId;
    int out = outs[0].flowId;
 
    //just passes the data from its input to its output, but will only get cued by headsUp()
    //every so often
    for (int i = 0; i < globalWidth; i++){
      for (int j = 0; j < globalHeight; j++){
        stack.get(out).data[i+j*globalWidth] = stack.get(in).data[i+j*globalWidth];
      }
    }  
    
    super.lookDown();
  }
}

class Convolve extends Module{
  
  Convolve(PVector pos_){
    super(pos_);
    name = "convolve";
    size = new PVector(41, 30);
    c = color(250, 200, 200);
    helper = new HelpBox(convolveHelp);         
    
    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));    
    ins = new InputNode[2];
    outs = new OutputNode[1];
    modIns = new ModInput[0];
    
    ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
    ins[1] = new InputNode(new PVector(id, 1), new PVector(pos.x+size.x-8, pos.y));
    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));     
    
    initializeKernel();

  }
  
  void headsUp(){    
    if (ins[1].lookUp){
      updateKernel();
    }
    super.headsUp();
  }
  
  void initializeKernel(){
    for (int i = 0; i < 3; i++){
      for (int j = 0; j < 3; j++){
        if (i == 1 && j == 1){
          kernel[i][j] = 1;
        } else {
          kernel[i][j] = 0;
        }
      }
    }
  }
  
  void updateKernel(){
    arrayCopy(modules.get((int)ins[1].sender.x).kernel, kernel); 
  }
  
  void operate(){
    super.operate();
    int in1 = ins[0].flowId;
    //int in2 = ins[1].flowId;
    int out = outs[0].flowId;
    
    for (int i = 0; i < globalWidth; i++){
      for (int j = 0; j < globalHeight; j++){
        float sum = 0;
        for (int x = -1; x <= 1; x++){
          for (int y = -1; y <= 1; y++){
            int a = constrain(i+x, 0, globalWidth-1);
            int b = constrain(j+y, 0, globalHeight-1);
            sum+=stack.get(in1).data[a+b*globalWidth]*kernel[x+1][y+1];
          }          
        }
        stack.get(out).data[i+j*globalWidth] = sum;
      }
    }  
 
    super.lookDown();
  }
}

class MedianFilter extends Module{
  
  MedianFilter(PVector pos_){
    super(pos_);
    name = "median";
    size = new PVector(41, 30);
    c = color(50, 150, 100);
    helper = new HelpBox(medianHelp);  
    
    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));    
    ins = new InputNode[2];
    outs = new OutputNode[1];
    modIns = new ModInput[0];
    
    ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
    ins[1] = new InputNode(new PVector(id, 1), new PVector(pos.x+size.x-8, pos.y));
    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
 
  }
  
  void headsUp(){    
    if (ins[1].lookUp){
      updateStructuringElement();
    }
    super.headsUp();
  }
  
  void operate(){
    super.operate();
    int in = ins[0].flowId;
    int in2 = ins[1].flowId;
    int out = outs[0].flowId;
    int xOff = (structuringElement.length-1)/2;
    int yOff = (structuringElement[0].length-1)/2;
    
    for (int i = 1; i < globalWidth-1; i++){
      for (int j = 1; j < globalHeight-1; j++){
        
        int loc = i+j*globalWidth;
        int[] neighborhood = new int[0]; 
        
        for (int x = -xOff; x <= xOff; x++){
           for (int y = -yOff; y <= yOff; y++){  
             if (structuringElement[x+xOff][y+yOff] == 255){     
               int elementLoc = constrain(i+x, 0, globalWidth-1) + constrain(j+y, 0, globalHeight-1) * globalWidth;
               neighborhood = append(neighborhood, (int)stack.get(in).data[elementLoc]);
             }
           }
         }
         
         if (neighborhood.length > 1){
           stack.get(out).data[loc] = GFG.kthSmallest(neighborhood, 0, neighborhood.length-1, (int)(neighborhood.length/2));
         } else {
           stack.get(out).data[loc] = 0;
         }
       }
     }  
 
     super.lookDown();    
  }
  
  //quick median algorithm that recursively partitions the set
  //gets stuck in the main while loop. Can't figure it. Seems to
  //work fine in quickMedian.pde, but when ported, it gets stuck.
  float partition(float[] dataSet, int leftScan, int rightScan, int center){
    float pivot = dataSet[center];
    
    while (leftScan < rightScan){
      while(dataSet[leftScan] < pivot){
        leftScan++;
      }
      
      while(dataSet[rightScan] > pivot){
        rightScan--;
      }
      
      float holder = dataSet[leftScan];
      dataSet[leftScan] = dataSet[rightScan];
      dataSet[rightScan] = holder;
    }
    
    if (leftScan < center){
      return partition(dataSet, leftScan, dataSet.length-1, center);     
    } else if (leftScan > center){
      return partition(dataSet, 0, rightScan, center);
    } else {
      return dataSet[leftScan];
    }
  }
  void updateStructuringElement(){
    int xDim = modules.get((int)ins[1].sender.x).structuringElement.length;
    int yDim = modules.get((int)ins[1].sender.x).structuringElement[0].length;
    structuringElement = new int[xDim][yDim];
    arrayCopy(modules.get((int)ins[1].sender.x).structuringElement, structuringElement); 
  }
}

class Mean extends Module{
  
  Mean(PVector pos_){
    super(pos_);
    name = "mean";
    size = new PVector(41, 30);
    c = color(50, 150, 100);
    helper = new HelpBox(meanHelp);
      
    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));    
    ins = new InputNode[2];
    outs = new OutputNode[1];
    
    ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
    ins[1] = new InputNode(new PVector(id, 1), new PVector(pos.x+size.x-8, pos.y));
    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
   
  }
  
  void headsUp(){    
    if (ins[1].lookUp){
      updateStructuringElement();
    }
    super.headsUp();
  }
  
  void operate(){
    super.operate();
    int in = ins[0].flowId;
    int in2 = ins[1].flowId;
    int out = outs[0].flowId;
    int xOff = (structuringElement.length-1)/2;
    int yOff = (structuringElement[0].length-1)/2;
    int counter = 0;
    
    //get number of pixels in struc el so we don't have to keep counting them up.
    for (int x = 0; x < structuringElement.length; x++){
      for (int y = 0; y < structuringElement[0].length; y++){            
        if (structuringElement[x][y] == 255){     
          counter++;
        }
      }
    }
        
    for (int i = 0; i < globalWidth; i++){
      for (int j = 0; j < globalHeight; j++){ 
        float sum = 0;
        
        for (int x = -xOff; x <= xOff; x++){
          for (int y = -yOff; y <= yOff; y++){            
            if (structuringElement[x+xOff][y+yOff] == 255){     
              int elementLoc = constrain(i+x, 0, globalWidth-1) + constrain(j+y, 0, globalHeight-1) * globalWidth;
              sum += stack.get(in).data[elementLoc];
            }
          }
        }
        
        //do we need to cast counter as (float)?
        stack.get(out).data[i+j*globalWidth] = sum/counter;
        
      }
    }
    super.lookDown();
  }
  
  void updateStructuringElement(){
    int xDim = modules.get((int)ins[1].sender.x).structuringElement.length;
    int yDim = modules.get((int)ins[1].sender.x).structuringElement[0].length;
    structuringElement = new int[xDim][yDim];
    arrayCopy(modules.get((int)ins[1].sender.x).structuringElement, structuringElement); 
  }
  
}

class Variance extends Module{
  
  Variance(PVector pos_){
    super(pos_);
    name = "variance";
    size = new PVector(41, 30);
    c = color(50, 150, 100);
    helper = new HelpBox(varianceHelp);
      
    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));    
    ins = new InputNode[2];
    outs = new OutputNode[1];
    
    ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
    ins[1] = new InputNode(new PVector(id, 1), new PVector(pos.x+size.x-8, pos.y));
    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
   
  }
  
  void headsUp(){    
    if (ins[1].lookUp){
      updateStructuringElement();
    }
    super.headsUp();
  }
  
  void operate(){
    super.operate();
    int in = ins[0].flowId;
    int in2 = ins[1].flowId;
    int out = outs[0].flowId;
    int xOff = (structuringElement.length-1)/2;
    int yOff = (structuringElement[0].length-1)/2;
    int counter = 0;
    
    //get number of pixels in struc el so we don't have to keep counting them up.
    for (int x = 0; x < structuringElement.length; x++){
      for (int y = 0; y < structuringElement[0].length; y++){            
        if (structuringElement[x][y] == 255){     
          counter++;
        }
      }
    }
        
    for (int i = 0; i < globalWidth; i++){
      for (int j = 0; j < globalHeight; j++){ 
        float sum = 0;
        
        for (int x = -xOff; x <= xOff; x++){
          for (int y = -yOff; y <= yOff; y++){            
            if (structuringElement[x+xOff][y+yOff] == 255){     
              int elementLoc = constrain(i+x, 0, globalWidth-1) + constrain(j+y, 0, globalHeight-1) * globalWidth;
              sum += stack.get(in).data[elementLoc];
            }
          }
        }
        
        float mean = sum/counter;
        
        float diff = 0;
        
        for (int x = -xOff; x <= xOff; x++){
          for (int y = -yOff; y <= yOff; y++){            
            if (structuringElement[x+xOff][y+yOff] == 255){     
              int elementLoc = constrain(i+x, 0, globalWidth-1) + constrain(j+y, 0, globalHeight-1) * globalWidth;
              diff += abs(stack.get(in).data[elementLoc]-mean);
            }
          }
        }
        
        stack.get(out).data[i+j*globalWidth] = diff/counter;
      }
    }
    super.lookDown();
  }
  
  void updateStructuringElement(){
    int xDim = modules.get((int)ins[1].sender.x).structuringElement.length;
    int yDim = modules.get((int)ins[1].sender.x).structuringElement[0].length;
    structuringElement = new int[xDim][yDim];
    arrayCopy(modules.get((int)ins[1].sender.x).structuringElement, structuringElement); 
  } 
}

class And extends Module{
  
  And(PVector pos_){
    super(pos_);
    size = new PVector(41, 30);
    c = color(250, 200, 200);
    name = "and"; 
    helper = new HelpBox(andHelp);
    
    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));
    
    ins = new InputNode[2];
    outs = new OutputNode[1];
    modIns = new ModInput[0];
    
    ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
    ins[1] = new InputNode(new PVector(id, 1), new PVector(pos.x+size.x-8, pos.y));
    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
  }
  
  //this is the form of every operate in Module extensions that have ins and outs. 
  //super.operate() checks modules above to see if they need updated before performing 
  //the operation. super.lookDown() makes sure Modules below know that their Flows are 
  //up to date.
  void operate(){
    super.operate();
    int in1 = ins[0].flowId;
    int in2 = ins[1].flowId;  
    int out = outs[0].flowId;
    
    for (int i = 0; i < globalWidth; i++){
      for (int j = 0; j < globalHeight; j++){
        int loc = i+j*globalWidth;
        if (stack.get(in1).data[loc] == 255 && stack.get(in2).data[loc] == 255){
          stack.get(out).data[loc] = 255;
        } else {
          stack.get(out).data[loc] = 0;
        }
      }
    }
    super.lookDown();
  } 
}

class Or extends Module{
  
  Or(PVector pos_){
    super(pos_);
    size = new PVector(41, 30);
    c = color(250, 200, 200);
    name = "or"; 
    helper = new HelpBox(orHelp);
    
    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));
    
    ins = new InputNode[2];
    outs = new OutputNode[1];
    modIns = new ModInput[0];
    
    ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
    ins[1] = new InputNode(new PVector(id, 1), new PVector(pos.x+size.x-8, pos.y));
    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
  }
  
  //this is the form of every operate in Module extensions that have ins and outs. 
  //super.operate() checks modules above to see if they need updated before performing 
  //the operation. super.lookDown() makes sure Modules below know that their Flows are 
  //up to date.
  void operate(){
    super.operate();
    int in1 = ins[0].flowId;
    int in2 = ins[1].flowId;  
    int out = outs[0].flowId;
    
    for (int i = 0; i < globalWidth; i++){
      for (int j = 0; j < globalHeight; j++){
        int loc = i+j*globalWidth;
        if (stack.get(in1).data[loc] == 255 || stack.get(in2).data[loc] == 255){
          stack.get(out).data[loc] = 255;
        } else {
          stack.get(out).data[loc] = 0;
        }
      }
    }
    super.lookDown();
  } 
}

class XOr extends Module{
  
  XOr(PVector pos_){
    super(pos_);
    size = new PVector(41, 30);
    c = color(250, 200, 200);
    name = "xor"; 
    helper = new HelpBox(xorHelp);
    
    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));
    
    ins = new InputNode[2];
    outs = new OutputNode[1];
    modIns = new ModInput[0];
    
    ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
    ins[1] = new InputNode(new PVector(id, 1), new PVector(pos.x+size.x-8, pos.y));
    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
  }
  
  //this is the form of every operate in Module extensions that have ins and outs. 
  //super.operate() checks modules above to see if they need updated before performing 
  //the operation. super.lookDown() makes sure Modules below know that their Flows are 
  //up to date.
  void operate(){
    super.operate();
    int in1 = ins[0].flowId;
    int in2 = ins[1].flowId;  
    int out = outs[0].flowId;
    
    for (int i = 0; i < globalWidth; i++){
      for (int j = 0; j < globalHeight; j++){
        int loc = i+j*globalWidth;
        if (stack.get(in1).data[loc] == 255 ^ stack.get(in2).data[loc] == 255){
          stack.get(out).data[loc] = 255;
        } else {
          stack.get(out).data[loc] = 0;
        }
      }
    }
    super.lookDown();
  } 
}

class Not extends Module{
  
  Not(PVector pos_){
    super(pos_);
    size = new PVector(41, 30);
    c = color(250, 200, 200);
    name = "not"; 
    helper = new HelpBox(notHelp);
    
    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));
    
    ins = new InputNode[1];
    outs = new OutputNode[1];
    modIns = new ModInput[0];
    
    ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
  }
  
  //this is the form of every operate in Module extensions that have ins and outs. 
  //super.operate() checks modules above to see if they need updated before performing 
  //the operation. super.lookDown() makes sure Modules below know that their Flows are 
  //up to date.
  void operate(){
    super.operate();
    int in = ins[0].flowId;
    int out = outs[0].flowId;
    
    for (int i = 0; i < globalWidth; i++){
      for (int j = 0; j < globalHeight; j++){  
        int loc = i+j*globalWidth;
        stack.get(out).data[loc] = 255 - stack.get(in).data[loc];
      }
    }
    super.lookDown();
  } 
}

class LessThan extends Module{
  
  LessThan(PVector pos_){
    super(pos_);
    name = "<";
    size = new PVector(41, 30);
    c = color(250, 200, 200);
    helper = new HelpBox(lessThanHelp);
    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));
    
    ins = new InputNode[2];
    outs = new OutputNode[2];
    modIns = new ModInput[0];
    
    ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
    ins[1] = new InputNode(new PVector(id, 1), new PVector(pos.x+size.x-8, pos.y));
    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
    outs[1] = new OutputNode(new PVector(id, 1), new PVector(pos.x+size.x-8, pos.y+size.y-8));
  }
  
  boolean allSystemsGo(){
    if (outs[0].flowId == 0 && outs[1].flowId == 0){
      return false;
    }
    return true;
  }
  
  
  void operate(){
    super.operate();
    
    int in1 = ins[0].flowId;
    int in2 = ins[1].flowId;
    int out1 = outs[0].flowId;
    int out2 = outs[1].flowId;
    
    boolean binary = false;
    boolean value = false;
    
    if (outs[0].receivers.size() > 0){
      binary = true;
    } 
    
    if (outs[1].receivers.size() > 0){
      value = true;
    }
    
    for (int i = 0; i < globalWidth; i++){
      for (int j = 0; j < globalHeight; j++){
        int loc = i+j*globalWidth;
        if (stack.get(in1).data[loc] < stack.get(in2).data[loc]){
          if (binary){
            stack.get(out1).data[loc] = 255;
          }
          if (value){
            stack.get(out2).data[loc] = stack.get(in1).data[loc];
          }
        } else {
          if (binary){
            stack.get(out1).data[loc] = 0;
          }
          if (value){
            stack.get(out2).data[loc] = stack.get(in2).data[loc];
          }
        }   
      }
    }
    
    super.lookDown();
  }
}

class GreaterThan extends Module{
  
  GreaterThan(PVector pos_){
    super(pos_);
    name = ">";
    size = new PVector(41, 30);
    c = color(250, 200, 200);
    helper = new HelpBox(greaterThanHelp);
    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));
   
    ins = new InputNode[2];
    outs = new OutputNode[2];
    modIns = new ModInput[0];
    
    ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
    ins[1] = new InputNode(new PVector(id, 1), new PVector(pos.x+size.x-8, pos.y));
    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
    outs[1] = new OutputNode(new PVector(id, 1), new PVector(pos.x+size.x-8, pos.y+size.y-8));
  }
  
  boolean allSystemsGo(){
    if (outs[0].flowId == 0 && outs[1].flowId == 0){
      return false;
    }
    return true;
  }
  
  void operate(){
    super.operate();
    
    int in1 = ins[0].flowId;
    int in2 = ins[1].flowId;
    int out1 = outs[0].flowId;
    int out2 = outs[1].flowId;
    
    boolean binary = false;
    boolean value = false;
    
    if (outs[0].receivers.size() > 0){
      binary = true;
    } 
    
    if (outs[1].receivers.size() > 0){
      value = true;
    }
    
    for (int i = 0; i < globalWidth; i++){
      for (int j = 0; j < globalHeight; j++){
        int loc = i+j*globalWidth;
        
        if (stack.get(in1).data[loc] > stack.get(in2).data[loc]){
          if (binary){
            stack.get(out1).data[loc] = 255;
          }
          if (value){
            stack.get(out2).data[loc] = stack.get(in1).data[loc];
          }
        } else {
          if (binary){
            stack.get(out1).data[loc] = 0;
          }
          if (value){
            stack.get(out2).data[loc] = stack.get(in2).data[loc];
          }
        }
        
      }
    }
    super.lookDown();
  }
}

class Equal extends Module{
  
  Equal(PVector pos_){
    super(pos_);
    name = "=";
    size = new PVector(41, 30);
    c = color(250, 200, 200);
    helper = new HelpBox(equalHelp);
    
    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));
    
    ins = new InputNode[2];
    outs = new OutputNode[1];
    modIns = new ModInput[0];
    
    ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
    ins[1] = new InputNode(new PVector(id, 1), new PVector(pos.x+size.x-8, pos.y));
    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
  }

  //this is the form of every operate in Module extensions that have ins and outs. 
  //super.operate() checks modules above to see if they need updated before performing 
  //the operation. super.lookDown() makes sure Modules below know that their Flows are 
  //up to date.
  
  void operate(){
    super.operate();
    
    int in1 = ins[0].flowId;
    int in2 = ins[1].flowId;
    int out = outs[0].flowId;
    
    for (int i = 0; i < globalWidth; i++){
      for (int j = 0; j < globalHeight; j++){
        int loc = i+j*globalWidth;
        if ((int)stack.get(in1).data[loc] == (int)stack.get(in2).data[loc]){
          stack.get(out).data[loc] = 255;
        } else {
          stack.get(out).data[loc] = 0;
        }
      }
    }
    super.lookDown();
  }
}

class Add extends Module{
  
  Add(PVector pos_){
    super(pos_);
    size = new PVector(41, 30);
    c = color(250, 200, 200);
    name = "+"; 
    helper = new HelpBox(addHelp);
    
    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));
    
    ins = new InputNode[2];
    outs = new OutputNode[1];
    modIns = new ModInput[0];
    
    ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
    ins[1] = new InputNode(new PVector(id, 1), new PVector(pos.x+size.x-8, pos.y));
    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
  }
  
  //this is the form of every operate in Module extensions that have ins and outs. 
  //super.operate() checks modules above to see if they need updated before performing 
  //the operation. super.lookDown() makes sure Modules below know that their Flows are 
  //up to date.
  void operate(){
    super.operate();
    int in1 = ins[0].flowId;
    int in2 = ins[1].flowId;  
    int out = outs[0].flowId;
    
    for (int i = 0; i < globalWidth; i++){
      for (int j = 0; j < globalHeight; j++){
        int loc = i+j*globalWidth;
        stack.get(out).data[loc] = stack.get(in1).data[loc]+stack.get(in2).data[loc]; 
      }
    }
    super.lookDown();
  } 
}

class Subtract extends Module{
  
  Subtract(PVector pos_){
    super(pos_);
    size = new PVector(41, 30);
    c = color(250, 200, 200);
    name = "-"; 
    helper = new HelpBox(subtractHelp);  
    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));
    
    ins = new InputNode[2];
    outs = new OutputNode[1];
    modIns = new ModInput[0];
    
    ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
    ins[1] = new InputNode(new PVector(id, 1), new PVector(pos.x+size.x-8, pos.y));
    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
  }
  
  //this is the form of every operate in Module extensions that have ins and outs. 
  //super.operate() checks modules above to see if they need updated before performing 
  //the operation. super.lookDown() makes sure Modules below know that their Flows are 
  //up to date.
  void operate(){
    super.operate();
    int in1 = ins[0].flowId;
    int in2 = ins[1].flowId;  
    int out = outs[0].flowId;
    
    for (int i = 0; i < globalWidth; i++){
      for (int j = 0; j < globalHeight; j++){
        int loc = i+j*globalWidth;
        stack.get(out).data[loc] = stack.get(in1).data[loc]-stack.get(in2).data[loc]; 
      }
    }
    super.lookDown();
  } 
}

class Multiply extends Module{
  
  Multiply(PVector pos_){
    super(pos_);
    size = new PVector(41, 30);
    c = color(250, 200, 200);
    name = "x"; 
    helper = new HelpBox(multiplyHelp);  
     
    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));
    
    ins = new InputNode[2];
    outs = new OutputNode[1];
    modIns = new ModInput[0];
    
    ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
    ins[1] = new InputNode(new PVector(id, 1), new PVector(pos.x+size.x-8, pos.y));
    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
  }
  
  //this is the form of every operate in Module extensions that have ins and outs. 
  //super.operate() checks modules above to see if they need updated before performing 
  //the operation. super.lookDown() makes sure Modules below know that their Flows are 
  //up to date.
  void operate(){
    super.operate();
    int in1 = ins[0].flowId;
    int in2 = ins[1].flowId;  
    int out = outs[0].flowId;
    
    for (int i = 0; i < globalWidth; i++){
      for (int j = 0; j < globalHeight; j++){
        int loc = i+j*globalWidth;
        stack.get(out).data[loc] = stack.get(in1).data[loc]*stack.get(in2).data[loc]; 
      }
    }
    super.lookDown();
  } 
}

class Divide extends Module{
  
  Divide(PVector pos_){
    super(pos_);
    size = new PVector(41, 30);
    c = color(250, 200, 200);
    name = "/"; 
    helper = new HelpBox(divideHelp);  
     
    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));
    
    ins = new InputNode[2];
    outs = new OutputNode[1];
    modIns = new ModInput[0];
    
    ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
    ins[1] = new InputNode(new PVector(id, 1), new PVector(pos.x+size.x-8, pos.y));
    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
  }
  
  //this is the form of every operate in Module extensions that have ins and outs. 
  //super.operate() checks modules above to see if they need updated before performing 
  //the operation. super.lookDown() makes sure Modules below know that their Flows are 
  //up to date.
  void operate(){
    super.operate();
    int in1 = ins[0].flowId;
    int in2 = ins[1].flowId;  
    int out = outs[0].flowId;
    
    for (int i = 0; i < globalWidth; i++){
      for (int j = 0; j < globalHeight; j++){
        int loc = i+j*globalWidth;
        //arbitrary floor to make sure we don't divide by zero
        stack.get(out).data[loc] = stack.get(in1).data[loc]/max(stack.get(in2).data[loc], .00001); 
      }
    }
    super.lookDown();
  } 
}

class Log extends Module{
  
  Log(PVector pos_){
    super(pos_);
    size = new PVector(41, 30);
    c = color(250, 200, 200);
    name = "log"; 
    helper = new HelpBox(logHelp);  
    
    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));
    
    ins = new InputNode[2];
    outs = new OutputNode[1];
    modIns = new ModInput[0];
    
    ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
    ins[1] = new InputNode(new PVector(id, 1), new PVector(pos.x+size.x-8, pos.y));
    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
  }
  
  //this is the form of every operate in Module extensions that have ins and outs. 
  //super.operate() checks modules above to see if they need updated before performing 
  //the operation. super.lookDown() makes sure Modules below know that their Flows are 
  //up to date.
  void operate(){
    super.operate();
    int in1 = ins[0].flowId;
    int in2 = ins[1].flowId;  
    int out = outs[0].flowId;
    
    for (int i = 0; i < globalWidth; i++){
      for (int j = 0; j < globalHeight; j++){
        int loc = i+j*globalWidth;
        stack.get(out).data[loc] = log(max(1, stack.get(in1).data[loc]))/log(max(1, stack.get(in2).data[loc]));
      }
    }
    super.lookDown();
  } 
}

class Exp extends Module{
  
  Exp(PVector pos_){
    super(pos_);
    size = new PVector(41, 30);
    c = color(250, 200, 200);
    name = "^"; 
    helper = new HelpBox(powerHelp);  
    
    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));
    
    ins = new InputNode[2];
    outs = new OutputNode[1];
    modIns = new ModInput[0];
    
    ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
    ins[1] = new InputNode(new PVector(id, 1), new PVector(pos.x+size.x-8, pos.y));
    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
  }
  
  //this is the form of every operate in Module extensions that have ins and outs. 
  //super.operate() checks modules above to see if they need updated before performing 
  //the operation. super.lookDown() makes sure Modules below know that their Flows are 
  //up to date.
  void operate(){
    super.operate();
    int in1 = ins[0].flowId;
    int in2 = ins[1].flowId;  
    int out = outs[0].flowId;
    
    for (int i = 0; i < globalWidth; i++){
      for (int j = 0; j < globalHeight; j++){
        int loc = i+j*globalWidth;
        //arbitrary floor to make sure we don't divide by zero
        stack.get(out).data[loc] = pow(stack.get(in1).data[loc], stack.get(in2).data[loc]);
      }
    }
    super.lookDown();
  } 
}

class Modulo extends Module{
  
  Modulo(PVector pos_){
    super(pos_);
    size = new PVector(41, 30);
    c = color(250, 200, 200);
    name = "%"; 
    helper = new HelpBox(moduloHelp);  
    
    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));
    
    ins = new InputNode[2];
    outs = new OutputNode[1];
    modIns = new ModInput[0];
    
    ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
    ins[1] = new InputNode(new PVector(id, 1), new PVector(pos.x+size.x-8, pos.y));
    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
  }
  
  //this is the form of every operate in Module extensions that have ins and outs. 
  //super.operate() checks modules above to see if they need updated before performing 
  //the operation. super.lookDown() makes sure Modules below know that their Flows are 
  //up to date.
  void operate(){
    super.operate();
    int in1 = ins[0].flowId;
    int in2 = ins[1].flowId;  
    int out = outs[0].flowId;
    
    for (int i = 0; i < globalWidth; i++){
      for (int j = 0; j < globalHeight; j++){
        int loc = i+j*globalWidth;
        //arbitrary floor to make sure we don't divide by zero
        stack.get(out).data[loc] = stack.get(in1).data[loc]%stack.get(in2).data[loc];
      }
    }
    super.lookDown();
  } 
}

class AbsoluteValue extends Module{
  
  AbsoluteValue(PVector pos_){
    super(pos_);
    size = new PVector(41, 30);
    c = color(250, 200, 200);
    name = "| |"; 
    helper = new HelpBox(absHelp);  
    
    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));
    
    ins = new InputNode[1];
    outs = new OutputNode[1];
    modIns = new ModInput[0];
    
    ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
  }
  
  //this is the form of every operate in Module extensions that have ins and outs. 
  //super.operate() checks modules above to see if they need updated before performing 
  //the operation. super.lookDown() makes sure Modules below know that their Flows are 
  //up to date.
  void operate(){
    super.operate();
    int in1 = ins[0].flowId;
    int out = outs[0].flowId;
    
    for (int i = 0; i < globalWidth; i++){
      for (int j = 0; j < globalHeight; j++){
        int loc = i+j*globalWidth;
        stack.get(out).data[loc] = abs(stack.get(in1).data[loc]);;
      }
    }
    super.lookDown();
  } 
}

class Feedback extends Module{
  
  Feedback(PVector pos_){
    super(pos_);
    size = new PVector(100, 36);
    c = color(200);
    name = "feedback";  
    helper = new HelpBox(feedbackHelp);
    isFeedback = true;
  
    cp5.addSlider("rate"+str(id))
      .setLabel("")
      .setPosition(4, 14)
      .setWidth(88)
      .setHeight(10)
      .setRange(1, 60)
      .setValue(1)
      .plugTo(this, "cp5Handler")
      .setGroup("g"+str(id))      
      ;

    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));
    
    ins = new InputNode[2];
    outs = new OutputNode[2];
    
    ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
    ins[1] = new InputNode(new PVector(id, 1), new PVector(pos.x+size.x-8, pos.y));
    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
    outs[1] = new OutputNode(new PVector(id, 1), new PVector(pos.x+size.x-8, pos.y+size.y-8));

  }
  
  void operate(){
    for (PVector p : outs[1].receivers){
      modules.get((int)p.x).headsUp();
    }
    
    if (newData){
      //outs[1].flowId = ins[0].flowId;
      arrayCopy(stack.get(ins[0].flowId).data, stack.get(outs[1].flowId).data);
    } else {      
      //outs[1].flowId = ins[1].flowId;
      arrayCopy(stack.get(outs[0].flowId).data, stack.get(outs[1].flowId).data);
    }
    newData = false;
    
    modules.get((int)ins[1].sender.x).operate();
        
    arrayCopy(stack.get(ins[1].flowId).data, stack.get(outs[0].flowId).data);
    
    super.lookDown();
  }
  
  void headsUp(){
    for (PVector p : outs[0].receivers){
      modules.get((int)p.x).ins[(int)p.y].lookUp = true;
    }      
    for (PVector p : outs[0].receivers){
      if (!modules.get((int)p.x).isDisplay && !(modules.get((int)p.x).isFeedback && (int)p.y == 1)){
        modules.get((int)p.x).headsUp();
      }
    }      
  }
  
  void feedbackPrimer(){
    if (frameCount%(int)cp5.getController("rate"+str(id)).getValue() == 0){    
      headsUp();
    }
  }
  
}

class Iterator extends Module{
  
  //necessary so that decimal changes to the slider don't cause the module to coninuously run.
  //basically only rerun the iterator if the slider value changes integer value
  int iterations = 1;
  
  //FeedbackIn fbInput;
  //FeedbackOut fbOutput;
  
  Iterator(PVector pos_){
    super(pos_);
    size = new PVector(110, 48);
    c = color(200);
    name = "iterator";  
    helper = new HelpBox(iteratorHelp);
    isIterator = true;
  
    cp5.addTextfield("maxIterations"+str(id))
      .setLabel("max")     
      .setPosition(8, 12)
      .setSize(20, 10)
      .setColor(color(255,0,0))
      .show()
      .setText("10")
      .setGroup("g"+str(id))
      ;
      
    cp5.addButton("updateMax"+str(id))  
      .setLabel("")
      .setPosition(35, 12)
      .setSize(10, 10)
      .plugTo(this, "updateMaxIterations")
      .setGroup("g"+str(id))
      ;
      
    cp5.addSlider("iterations"+str(id))
      .setLabel("")
      .setPosition(8, 26)
      .setWidth(88)
      .setHeight(10)
      .setRange(0, 10)
      .setValue(1)
      .plugTo(this, "cp5Handler")
      .setGroup("g"+str(id))      
      ;

    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));
    
    ins = new InputNode[2];
    outs = new OutputNode[2];
    modIns = new ModInput[1];
    
    ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
    ins[1] = new InputNode(new PVector(id, 1), new PVector(pos.x+size.x-8, pos.y));
    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
    outs[1] = new OutputNode(new PVector(id, 1), new PVector(pos.x+size.x-8, pos.y+size.y-8));
    modIns[0] = new ModInput(new PVector(id, 0, -1), new PVector(pos.x+size.x-8, pos.y+27), "iterations"+str(id));
  }
  
  void updateMaxIterations(){
    int newMax = int(cp5.get(Textfield.class, "maxIterations"+str(id)).getText());
    Slider s = (Slider)cp5.getController("iterations"+str(id));
    s.setRange(0, newMax);
  }
  
  void cp5Handler(float val){
    if (cp5.getController("iterations"+str(id)).isMousePressed()){
      if (!modIns[0].pauseInput){
        modIns[0].baseVal = val;
        modIns[0].pauseInput = true;
      }
    }
    //only call headsUp() if the slider changes val by an integer
    if (iterations != (int)cp5.getController("iterations"+str(id)).getValue()){
      iterations = (int)cp5.getController("iterations"+str(id)).getValue();
      headsUp();
    }
  }
  
  //surely we can do this without arrayCopy
  //how can we do our routing using flowId? What's going on?
  
  void operate(){
    super.operate();
    
    int in1 = ins[0].flowId;
    int in2 = ins[1].flowId;
    int out1 = outs[0].flowId;
    int out2 = outs[1].flowId;
    
    arrayCopy(stack.get(in1).data, stack.get(out2).data);
    
    for (int i = 0; i < iterations; i++){
      for (PVector p : outs[1].receivers){
        modules.get((int)p.x).headsUp();
      }
      modules.get((int)ins[1].sender.x).operate();
      arrayCopy(stack.get(in2).data, stack.get(out2).data);
    }    
    arrayCopy(stack.get(out2).data, stack.get(out1).data);  
    
    super.lookDown();
  }
  
  void headsUp(){
    for (PVector p : outs[0].receivers){
      modules.get((int)p.x).ins[(int)p.y].lookUp = true;
    }      
    for (PVector p : outs[0].receivers){
      if (!modules.get((int)p.x).isDisplay && !(modules.get((int)p.x).isFeedback && (int)p.y == 1) && !(modules.get((int)p.x).isIterator && (int)p.y == 1)){
        modules.get((int)p.x).headsUp();
      }
    }      
  } 
}

class SignalIn extends Module{
  
  SignalIn(PVector pos_){
    super(pos_);
    size = new PVector(41, 30);
    c = color(200);
    name = "in";
    isMacroIn = true;
    helper = new HelpBox(signalInHelp);
      
    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));
    
    outs = new OutputNode[1];    
    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
  }
  
  //this module doesn't have to do anything, just carries the signal to the macro
  void operate(){
    super.operate();
    super.lookDown();
  } 
}

class SignalOut extends Module{
  
  SignalOut(PVector pos_){
    super(pos_);
    size = new PVector(41, 30);
    c = color(200);
    name = "out";  
    isMacroOut = true;
    helper = new HelpBox(signalOutHelp);
      
    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));
    
    ins = new InputNode[1];    
    ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
  }
  
  //this module doesn't have to do anything, just carries the signal back to the main patch
  void operate(){
    super.operate();
    super.lookDown();
  } 
}

class Rotate extends Module{
    
  Rotate(PVector pos_){
    super(pos_);
    size = new PVector(106, 30);
    c = color(150, 50, 50);  
    name = "rotate";  
    helper = new HelpBox(rotateHelp);
    
    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));
    
    ins = new InputNode[4];
    outs = new OutputNode[1];
    modIns = new ModInput[0];
    
    ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
    ins[1] = new InputNode(new PVector(id, 1), new PVector(pos.x+size.x-40, pos.y));
    ins[2] = new InputNode(new PVector(id, 2), new PVector(pos.x+size.x-24, pos.y));
    ins[3] = new InputNode(new PVector(id, 3), new PVector(pos.x+size.x-8, pos.y));
    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
  }
  
  void operate(){
    super.operate();
    
    int in = ins[0].flowId;
    int in1 = ins[1].flowId;
    int in2 = ins[2].flowId;
    int in3 = ins[3].flowId;
    int out = outs[0].flowId;
       
    PVector p;
    PVector a;
    float amount;
    
    for (int i = 0; i < globalWidth; i++){
      for (int j = 0; j < globalHeight; j++){
        int loc = i+j*globalWidth;
        p = new PVector(i, j);
        a = new PVector(stack.get(in1).data[loc], stack.get(in2).data[loc]);
        amount = stack.get(in3).data[loc];
        PVector newLoc = rotatePV(p, a, amount);
        if (0 <= newLoc.x && newLoc.x < globalWidth && 0 <= newLoc.y && newLoc.y < globalHeight){
          stack.get(out).data[loc] = stack.get(in).data[(int)newLoc.x+(int)newLoc.y*globalWidth];
        } else {
          stack.get(out).data[loc] = 0;
        }
      }
    }
    
    super.lookDown();
  }
  
}

class Reflect extends Module{
    
  Reflect(PVector pos_){
    super(pos_);
    size = new PVector(106, 30);
    c = color(150, 50, 50);  
    name = "reflect";  
    helper = new HelpBox(reflectHelp);
    
    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));
    
    ins = new InputNode[4];
    outs = new OutputNode[1];
    modIns = new ModInput[0];
    
    ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
    ins[1] = new InputNode(new PVector(id, 1), new PVector(pos.x+size.x-40, pos.y));
    ins[2] = new InputNode(new PVector(id, 2), new PVector(pos.x+size.x-24, pos.y));
    ins[3] = new InputNode(new PVector(id, 3), new PVector(pos.x+size.x-8, pos.y));
    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
  }
  
  void operate(){
    super.operate();
    
    int in = ins[0].flowId;
    int in1 = ins[1].flowId;
    int in2 = ins[2].flowId;
    int in3 = ins[3].flowId;
    int out = outs[0].flowId;
       
    PVector p;
    PVector a;
    PVector d;
    
    float amount;
    
    for (int i = 0; i < globalWidth; i++){
      for (int j = 0; j < globalHeight; j++){
        int loc = i+j*globalWidth;
        p = new PVector(i, j);
        a = new PVector(stack.get(in1).data[loc], stack.get(in2).data[loc]);
        d = new PVector(i+2*(a.x-i), j+2*(a.y-j));
        amount = map(stack.get(in3).data[loc], 0, 255, 0, 1);
        PVector newLoc = new PVector(lerp(p.x, d.x, amount), lerp(p.y, d.y, amount));
        if (0 <= newLoc.x && newLoc.x < globalWidth && 0 <= newLoc.y && newLoc.y < globalHeight){
          stack.get(out).data[loc] = stack.get(in).data[(int)newLoc.x+(int)newLoc.y*globalWidth];
        } else {
          stack.get(out).data[loc] = 0;
        }
      }
    }
    
    super.lookDown();
  }
  
}

public class ThreeD extends Module{
    
  //not sure why we can't createGraphics here, but it for sure breaks
  PGraphics buffer;
  PImage tex = createImage(globalWidth, globalHeight, RGB);
  boolean updatingModel = false;
  boolean updatingTexture = false;
  
  ThreeD(PVector pos_){
    super(pos_);    
    size = new PVector(120, 85);
    c = color(150, 100, 50);
    name = "3D";  
    helper = new HelpBox(threeDHelp);
    
    cp5.addSlider("distance"+str(id))
      .setLabel("")
      .setPosition(8, 22)
      .setWidth(100)
      .setHeight(10)
      .setRange(0, 1500)
      .setValue(350)
      .plugTo(this, "cp5Handler")
      .setGroup("g"+str(id))      
      ;  
      
    cp5.addSlider("height"+str(id))
      .setLabel("")
      .setPosition(8, 34)
      .setWidth(100)
      .setHeight(10)
      .setRange(0, 2500)
      .setValue(700)
      .plugTo(this, "cp5Handler")
      .setGroup("g"+str(id))      
      ;
      
    cp5.addSlider("rotation"+str(id))
      .setLabel("")
      .setPosition(8, 46)
      .setWidth(100)
      .setHeight(10)
      .setRange(-PI, PI)
      .setValue(0)
      .plugTo(this, "cp5Handler")
      .setGroup("g"+str(id))      
      ; 
        
    cp5.addSlider("resolution"+str(id))
      .setLabel("")
      .setPosition(8, 63)
      .setWidth(80)
      .setHeight(10)
      .setRange(1, 50)
      .setValue(1)
      .plugTo(this, "changeRes")
      .setGroup("g"+str(id))      
      ; 
      
    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));
    
    ins = new InputNode[6];
    outs = new OutputNode[3];
    modIns = new ModInput[3];
    
    ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
    ins[1] = new InputNode(new PVector(id, 1), new PVector(pos.x+16, pos.y));
    ins[2] = new InputNode(new PVector(id, 2), new PVector(pos.x+32, pos.y));
    ins[3] = new InputNode(new PVector(id, 3), new PVector(pos.x+size.x-40, pos.y));
    ins[4] = new InputNode(new PVector(id, 4), new PVector(pos.x+size.x-24, pos.y));
    ins[5] = new InputNode(new PVector(id, 5), new PVector(pos.x+size.x-8, pos.y));   
    
    ins[3].col = color(255, 0, 0);
    ins[4].col = color(0, 255, 0);
    ins[5].col = color(0, 0, 255);

    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x+size.x-40, pos.y+size.y-8));
    outs[1] = new OutputNode(new PVector(id, 1), new PVector(pos.x+size.x-24, pos.y+size.y-8));
    outs[2] = new OutputNode(new PVector(id, 1), new PVector(pos.x+size.x-8, pos.y+size.y-8));
    
    outs[0].col = color(255, 0, 0);
    outs[1].col = color(0, 255, 0);
    outs[2].col = color(0, 0, 255);
    
    modIns[0] = new ModInput(new PVector(id, 0, -1), new PVector(pos.x+size.x-8, pos.y+23), "distance"+str(id));
    modIns[1] = new ModInput(new PVector(id, 1, -1), new PVector(pos.x+size.x-8, pos.y+35), "height"+str(id));
    modIns[2] = new ModInput(new PVector(id, 2, -1), new PVector(pos.x+size.x-8, pos.y+47), "rotation"+str(id));
    
    //have to createGraphics here for reasons
    buffer = createGraphics(globalWidth, globalHeight, P3D);
    model = createShape();
    updateTexture();
    
    buffer.beginDraw();
    buffer.background(0);
    buffer.endDraw();
  }
 
  void changeRes(){
    updatingModel = true;
    headsUp();
  }
  
  void cp5Handler(float val){
    //don't recreate the model when 3D UI is changed. It's ok to put this here because
    //all CP5 happens after draw(), so if the model needs to update, it will happen
    //before we reach this method
    updatingModel = false;
    if (cp5.getController("distance"+str(id)).isMousePressed()){
      if (!modIns[0].pauseInput){
        modIns[0].baseVal = val;
        modIns[0].pauseInput = true;
      }
    }
    if (cp5.getController("height"+str(id)).isMousePressed()){
      if (!modIns[1].pauseInput){
        modIns[1].baseVal = val;
        modIns[1].pauseInput = true;
      }
    }
    if (cp5.getController("rotation"+str(id)).isMousePressed()){
      if (!modIns[2].pauseInput){
        modIns[2].baseVal = val;
        modIns[2].pauseInput = true;
      }
    }
    headsUp();
  }


  void headsUp(){    
    if (ins[3].lookUp || ins[4].lookUp || ins[5].lookUp){
      updatingTexture = true;
    }
    if (ins[0].lookUp || ins[1].lookUp || ins[2].lookUp){
      updatingModel = true;
    }
    super.headsUp();
  }
  
  // operate if input 1 and output 1 have a connection. Other inputs are optional 
  boolean allSystemsGo(){
    if (ins[0].flowId == 0){
      return false;
    } else {
      return true;
    }
  }
  
  void updateTexture(){
    int redIn = ins[3].flowId;
    int greenIn = ins[4].flowId;
    int blueIn = ins[5].flowId;
    
    tex.loadPixels();
    
    if (redIn >= 1 || greenIn >= 1 || blueIn >= 1){
      for (int i = 0; i < globalWidth; i++){
        for (int j = 0; j < globalHeight; j++){
          int loc = i+j*globalWidth;
          tex.pixels[loc] = color(stack.get(redIn).data[loc], stack.get(greenIn).data[loc], stack.get(blueIn).data[loc]);
        }
      }      
    }
    
    tex.updatePixels();
  }
  
  void updateModel(){
    int xIn = ins[0].flowId;
    int yIn = ins[1].flowId;
    int zIn = ins[2].flowId;
    int res = (int)cp5.getController("resolution"+str(id)).getValue();
               
    model = createShape(); 
    model.beginShape(TRIANGLE_STRIP);
    model.noStroke();
    model.texture(tex); 
   
    for (int i = 0; i < globalWidth-1; i++){       
      for (int j = 0; j < globalHeight-1; j++){
        if (i%res == 0 && j%res == 0){
          if (i%2 == 0){
            int loc = i+j*globalWidth;
            int rightOne = i+1+j*globalWidth;
            model.vertex(stack.get(xIn).data[loc], stack.get(yIn).data[loc], stack.get(zIn).data[loc], map(i, 0, globalWidth, 0, tex.width), map(j, 0, globalHeight, 0, tex.height));
            model.vertex(stack.get(xIn).data[rightOne], stack.get(yIn).data[rightOne], stack.get(zIn).data[rightOne], map(i+1, 0, globalWidth, 0, tex.width), map(j, 0, globalHeight, 0, tex.height)); 
          } else {
            //huh?
            int weird = i+(globalHeight-1-j)*globalWidth;
            int weirdAndOver = i+1+(globalHeight-1-j)*globalWidth;
            model.vertex(stack.get(xIn).data[weird], stack.get(yIn).data[weird], stack.get(zIn).data[weird], map(i, 0, globalWidth, 0, tex.width), map(globalHeight-1-j, 0, globalHeight, 0, tex.height));
            model.vertex(stack.get(xIn).data[weirdAndOver], stack.get(yIn).data[weirdAndOver], stack.get(zIn).data[weirdAndOver], map(i+1, 0, globalWidth, 0, tex.width), map(globalHeight-1-j, 0, globalHeight, 0, tex.height));
          } 
        }
      }
    } 

    model.endShape(CLOSE);     
  }
  
  void operate(){
    super.operate();   
    
    if (updatingTexture){
      updateTexture();
      updatingTexture = false;
    }
    if (updatingModel){
      updateModel();
      updatingModel = false; 
    }
    
    writeToBuffer();
    
    int redIn = ins[2].flowId;
    int greenIn = ins[3].flowId;
    int blueIn = ins[4].flowId;
    
    int redOut = outs[0].flowId;
    int greenOut = outs[1].flowId;
    int blueOut = outs[2].flowId;
    
    buffer.loadPixels();
    
    for (int i = 0; i < globalWidth; i++){
      for (int j = 0; j < globalHeight; j++){
        int loc = i+j*globalWidth;
        stack.get(redOut).data[loc] = (buffer.pixels[loc] >> 16) & 0xFF;
        stack.get(greenOut).data[loc] = (buffer.pixels[loc] >> 8) & 0xFF;
        stack.get(blueOut).data[loc] = buffer.pixels[loc] & 0xFF;
      }
    }  
       
    super.lookDown();
  }
  
  //this method positions the camera, then draws the model in a PGraphics object. The operate()
  //method then reads the values of the PGraphics object into the output data array
  
  void writeToBuffer(){   
    
    //didn't bother implementing real rotations. The camera basically picks a vector on a cylinder
    //of given radius surrounding (0, 0, 0), then normalizes that vector to the given radius.
    
    //cylinder radius / viewing distance
    float dist = cp5.getController("distance"+str(id)).getValue();
    
    //rotation along outside of cylinder
    float rotation = cp5.getController("rotation"+str(id)).getValue();
    float xrot = dist*sin(rotation);
    float yrot = dist*cos(rotation);
    
    //height above the origin
    float camHeight = cp5.getController("height"+str(id)).getValue();
    
    //normalize position on cylinder to position on sphere of the given radius
    PVector camPos = new PVector(xrot, yrot, camHeight).normalize().mult(dist);
    
    //unsure if buffer.clear() is necessary somewhere here
    buffer.beginDraw();
    buffer.clear();
    buffer.camera(camPos.x, camPos.y, camPos.z, 0, 0, 0, 0, 0, -1);
    //buffer.lights();
    buffer.background(0);
    buffer.shape(model, 0, 0);   
    buffer.endDraw();
  }  
  
  void changeDataDimensions(){
    super.changeDataDimensions();
    buffer = createGraphics(globalWidth, globalHeight, P3D);
    buffer.beginDraw();
    buffer.background(0);
    buffer.endDraw();
    tex = createImage(globalWidth, globalHeight, RGB);
    updatingTexture = true;
    updatingModel = true;
  }  
}
