
class NoiseGenerator extends Module{
  
  boolean cartesian = true;
  float seed;
  
  NoiseGenerator(PVector pos_){
    super(pos_);
    size = new PVector(110, 72);
    c = color(125, 100, 175);
    seeds.add(random(1000));
    seed = seeds.get(seeds.size()-1);
    name = "noise";
    helper = new HelpBox(noiseHelp);

    cp5.addTextfield("noiseGenSeed"+str(id))
      .setLabel("") 
      .setText(str(seeds.size()-1))
      .setPosition(28, 15)
      .setSize(20, 10)
      .setColor(color(255,0,0))
      .show()
      .setGroup("g"+str(id))
      ;  
      
    cp5.addRadioButton("noiseMode"+str(id))
      .setPosition(65, 3)
      .setSize(10, 10)
      .addItem("cart"+str(id),1)
      .addItem("pol"+str(id),2)
      .setGroup("g"+str(id))
      ;  
      
    cp5.addSlider("xStep"+str(id))
      .setLabel("x")
      .setPosition(4, 27)
      .setWidth(80)
      .setHeight(10)
      .setRange(0, .1)
      .setValue(.01)
      .plugTo(this, "cp5Handler")
      .setGroup("g"+str(id))
      ;
      
    cp5.addSlider("yStep"+str(id))
      .setLabel("y")
      .setPosition(4, 39)
      .setWidth(80)
      .setHeight(10)
      .setRange(0, .1)
      .setValue(.01)
      .plugTo(this, "cp5Handler")
      .setGroup("g"+str(id))
      ;
      
    cp5.addSlider("seedInc"+str(id))
      .setLabel("sd")
      .setPosition(4, 51)
      .setWidth(80)
      .setHeight(10)
      .setRange(0, 15)
      .setValue(0)
      .plugTo(this, "cp5Handler")
      .setGroup("g"+str(id))
      ;   

    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));
    
    outs = new OutputNode[1];
    modIns = new ModInput[3];
    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
    modIns[0] = new ModInput(new PVector(id, 0, -1), new PVector(pos.x+size.x-8, pos.y+29), "xStep"+str(id));
    modIns[1] = new ModInput(new PVector(id, 1, -1), new PVector(pos.x+size.x-8, pos.y+41), "yStep"+str(id));
    modIns[2] = new ModInput(new PVector(id, 2, -1), new PVector(pos.x+size.x-8, pos.y+53), "seedInc"+str(id));
      
  }
  
  //clunky but ok. We need a way to distinguish manual slider changes from
  //those performed by Modifiers. Controller has a method isMousePressed(),
  // but 
  
  void cp5Handler(float val){
    if (cp5.getController("xStep"+str(id)).isMousePressed()){
      if (!modIns[0].pauseInput){
        modIns[0].baseVal = val;
        modIns[0].pauseInput = true;
      }
    }
    if (cp5.getController("yStep"+str(id)).isMousePressed()){
      if (!modIns[1].pauseInput){
        modIns[1].baseVal = val;
        modIns[1].pauseInput = true;
      }
    }
    if (cp5.getController("seedInc"+str(id)).isMousePressed()){
      if (!modIns[2].pauseInput){
        modIns[2].baseVal = val;
        modIns[2].pauseInput = true;
      }
    }
    headsUp();
  }
  
  void operate(){
    int out = outs[0].flowId;
    float xStep = cp5.getController("xStep"+str(id)).getValue();
    float yStep = cp5.getController("yStep"+str(id)).getValue();
    float seed = seeds.get(int(cp5.get(Textfield.class, "noiseGenSeed"+str(id)).getText()))+cp5.getController("seedInc"+str(id)).getValue();
    float a = 0;
    
    for (int i = 0; i < globalWidth; i++){
      for (int j = 0; j < globalHeight; j++){
        if (cp5.getGroup("noiseMode"+str(id)).getArrayValue(1) == 1){
          a = PVector.angleBetween(new PVector(1, 0), new PVector(i-globalWidth/2, j-globalHeight/2));
          if (j > globalHeight/2){
            a = 2*PI-a;
          }
          stack.get(out).data[i+j*globalWidth] = map((float)noise.eval(seed+xStep*100*cos(a), seed+yStep*100*sin(a)), -1, 1, 0, 255);
        } else {
          stack.get(out).data[i+j*globalWidth] = map((float)noise.eval(seed+xStep*i, seed+yStep*j), -1, 1, 0, 255);
        }
      }
    }
    super.lookDown();
  }
  
}

class TextGen extends Module{
  
  PGraphics buffer;

  TextGen(PVector pos_){
    super(pos_);
    size = new PVector(110, 50);
    c = color(125, 100, 175);
    name = "text ";
    helper = new HelpBox(textHelp);
    
    cp5.addSlider("size"+str(id))
      .setLabel("")
      .setPosition(6, 30)
      .setWidth(86)
      .setHeight(10)
      .setRange(8, 200)
      .setValue(20)
      .plugTo(this, "cp5Handler")
      .setGroup("g"+str(id))
      ;
      
    cp5.addTextfield("textInput"+str(id))
      .setLabel("")
      .setPosition(6, 12)
      .setSize(90, 12)
      .setColor(color(255,0,0))
      .show()
      .setText("hello")
      .plugTo(this, "headsUp")
      .setGroup("g"+str(id))      
      ;      

    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));
    
    outs = new OutputNode[1];
    modIns = new ModInput[1];
    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
    modIns[0] = new ModInput(new PVector(id, 0, -1), new PVector(pos.x+size.x-8, pos.y+31), "size"+str(id));
  
    buffer = createGraphics(globalWidth, globalHeight, P3D);
 
    buffer.beginDraw();
    buffer.background(0);
    buffer.textSize(20);
    buffer.text("hell0", 10, 30);
    buffer.endDraw();
  }
  
  //clunky but ok. We need a way to distinguish manual slider changes from
  //those performed by Modifiers. Controller has a method isMousePressed(),
  // but 
  
  void cp5Handler(float val){
    if (cp5.getController("size"+str(id)).isMousePressed()){
      if (!modIns[0].pauseInput){
        modIns[0].baseVal = val;
        modIns[0].pauseInput = true;
      }
    }
    headsUp();
  }
  
  void operate(){
    int out = outs[0].flowId;
    float size = cp5.getController("size"+str(id)).getValue();
    String text = cp5.get(Textfield.class, "textInput"+str(id)).getText();
    //unsure if buffer.clear() is necessary somewhere here
    buffer.beginDraw();
    buffer.clear();
    buffer.background(0);    
    buffer.textSize(size);
    buffer.text(text, 10, size+10);  
    buffer.endDraw();
    buffer.loadPixels();
    for (int i = 0; i < globalWidth; i++){
      for (int j = 0; j < globalHeight; j++){
        int loc = i+j*globalWidth;
        stack.get(out).data[loc] = buffer.pixels[loc] & 0xFF;
      }
    }
    buffer.updatePixels();
    super.lookDown();
  }
  
  void changeDataDimensions(){
    super.changeDataDimensions();
    buffer = createGraphics(globalWidth, globalHeight, P3D);
    headsUp();
  }
  
}

class Random extends Module{
    
  Random(PVector pos_){
    super(pos_);
    size = new PVector(41, 30);
    c = color(125, 100, 175);
    name = "random";  
    helper = new HelpBox(randomHelp);
    
    cp5.addButton("new"+str(id))
      .setLabel("")
      .setPosition(12, 12)
      .setSize(12, 12)
      .plugTo(this, "headsUp")
      .setGroup("g"+str(id))
      ;

    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));
    
    outs = new OutputNode[1];
    modIns = new ModInput[0];
    
    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
  }
  
  void operate(){
    super.operate();
    int out = outs[0].flowId;
    for (int i = 0; i < globalWidth; i++){
      for (int j = 0; j < globalHeight; j++){        
        stack.get(out).data[i+j*globalWidth] = random(255);
      }
    }
    super.lookDown();
  }

}

class Constant extends Module{
  
  boolean collapse = false;
  float constantValue = 0;
  
  Constant(PVector pos_){
    super(pos_);
    size = new PVector(287, 44);
    c = color(125, 100, 175);
    name = "constant";
    helper = new HelpBox(constantHelp);
      
    cp5.addSlider("val"+str(id))
      .setLabel("")
      .setPosition(20, 12)
      .setWidth(255)
      .setHeight(10)
      .setRange(0, 255)
      .setValue(0)
      .plugTo(this, "cp5Handler")
      .setGroup("g"+str(id))
      ;
    
    cp5.addSlider("fine"+str(id))
      .setLabel("")
      .setPosition(20, 24)
      .setWidth(256)
      .setHeight(10)
      .setRange(-1, 1)
      .setValue(1)
      .plugTo(this, "cp5Handler")
      .setGroup("g"+str(id))
      ; 
      
    cp5.addButton("collapse"+str(id))
      .setLabel("")
      .setPosition(6, 12)
      .setSize(10, 10)
      .plugTo(this, "collapseConstant")
      .setGroup("g"+str(id))
      ;

    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));
    
    outs = new OutputNode[1];
    modIns = new ModInput[2];
    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
    modIns[0] = new ModInput(new PVector(id, 0, -1), new PVector(pos.x+size.x-8, pos.y+13), "val"+str(id));
    modIns[1] = new ModInput(new PVector(id, 1, -1), new PVector(pos.x+size.x-8, pos.y+24), "fine"+str(id));
      
  }
  
  void collapseConstant(){
    if (collapse){
      collapse = false;
      cp5.getController("val"+str(id)).show();
      cp5.getController("fine"+str(id)).show();
      size.set(288, 44);
    } else {
      collapse = true;
      constantValue = cp5.getController("val"+str(id)).getValue()*cp5.getController("fine"+str(id)).getValue();    
      cp5.getController("val"+str(id)).hide();
      cp5.getController("fine"+str(id)).hide();
      size.set(56, 36);
    }
    grabber.pos = new PVector(pos.x+size.x/2, pos.y);
    outs[0].pos = new PVector(pos.x, pos.y+size.y-8);
    modIns[0].pos = new PVector(pos.x+size.x-8, pos.y+12);
    modIns[1].pos = new PVector(pos.x+size.x-8, pos.y+24);
  }
  
  void cp5Handler(float val){
    if (cp5.getController("val"+str(id)).isMousePressed()){
      if (!modIns[0].pauseInput){
        modIns[0].baseVal = val;
        modIns[0].pauseInput = true;
      }
    }
    if (cp5.getController("fine"+str(id)).isMousePressed()){
      if (!modIns[1].pauseInput){
        modIns[1].baseVal = val;
        modIns[1].pauseInput = true;
      }
    }
    headsUp();
  }
  
  void operate(){
    int out = outs[0].flowId;
    constantValue = cp5.getController("val"+str(id)).getValue()*cp5.getController("fine"+str(id)).getValue();    
    for (int i = 0; i < globalWidth; i++){
      for (int j = 0; j < globalHeight; j++){
        stack.get(out).data[i+j*globalWidth] = constantValue;
      }
    }
    super.lookDown();
  }
  
  void display(){
    super.display();
    if (collapse){
      fill(255);
      text(str((int)constantValue), pos.x+18, pos.y+24);
    }
  }
  
}

class Kernel extends Module{
  
  boolean collapse = false;
  
  Kernel(PVector pos_){
    super(pos_);
    size = new PVector(173, 104);
    c = color(125, 100, 175);
    name = "kernel";
    helper = new HelpBox(kernelHelp);
    
    cp5.addRadioButton("kernelType"+str(id))
      .setPosition(6, 27)
      .setSize(10, 10)
      .addItem("id"+str(id),0)
      .addItem("edge"+str(id),1)
      .addItem("sharpen"+str(id),2)
      .addItem("emboss"+str(id),3)
      .addItem("box"+str(id),4)
      .addItem("gauss"+str(id),5)
      .setGroup("g"+str(id)) 
      ;
      
    cp5.addButton("collapse"+str(id))
      .setLabel("")
      .setPosition(6, 12)
      .setSize(10, 10)
      .plugTo(this, "collapseKernel")
      .setGroup("g"+str(id))  
      ;  
   
    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));
    
    ins = new InputNode[1];
    outs = new OutputNode[1];
    modIns = new ModInput[0];
    ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));

  }
  
  void collapseKernel(){
    if (collapse){
      collapse = false;
      size.set(173, 104);
    } else {
      collapse = true;
      size.set(66, 104);
    }
    grabber.pos = new PVector(pos.x+size.x/2, pos.y);
    outs[0].pos = new PVector(pos.x, pos.y+size.y-8);
    modIns[0].pos = new PVector(pos.x+size.x-8, pos.y+12);
    modIns[1].pos = new PVector(pos.x+size.x-8, pos.y+24);
  }
 
  void presetKernel(){
    int type = (int)cp5.getGroup("kernelType"+str(id)).getValue();
    for (int i = 0; i < 3; i++){
      for (int j = 0; j < 3; j++){
        int loc = i+j*globalWidth;
        switch(type){
        //identity
        case 0 :
          if (i == 1 && j == 1){
            kernel[i][j] = 1;
          } else {
            kernel[i][j] = 0;
          }
          break;
        // edge  
        case 1 :
          if (i == 1 && j == 1){
            kernel[i][j] = 8;
          } else {
            kernel[i][j] = -1;
          }
          break; 
        // sharpen
        case 2 :
          if ((i+j)%2 == 0){
            if (i == 1 && j == 1){
              kernel[i][j] = 5;
            } else {
              kernel[i][j] = 0;
            }
          } else {
            kernel[i][j] = -1;
          }
          break; 
        // emboss
        case 3 :
          if (i == 0){
            kernel[i][j] = j-2;
          }
          if (i == 1){
            if (j == 1){
              kernel[i][j] = 1;
            } else {
            kernel[i][j] = j-1;
            }
          }
          if (i == 2){
            kernel[i][j] = j;
          }
          break; 
        // box
        case 4 :
          kernel[i][j] = .111;
          break;
        // gauss
        case 5 :
          if ((i+j)%2 == 0){
            if (i == 1 && j == 1){
              kernel[i][j] = .25;
            } else {
              kernel[i][j] = .0625;
            }
          } else {
            kernel[i][j] = .125;
          }
          break;         
        }
      }
    }
    
    headsUp();   
  }
  
  void operate(){
    super.operate();
    
    int in = ins[0].flowId;
    int out = outs[0].flowId;
    
    //all this stuff should be in fields and updated during changeDataDimensions.
    //sampling the kernel input this way makes sure we can rotate the kernel input without getting "wrapped" values
    int spacing = (int)min(globalWidth, globalHeight)/4;
    PVector offset = new PVector(globalWidth/2%(float)spacing, globalHeight/2%(float)spacing);
    
    //if the input is active, build kernel by sampling the input signal
    if (in > 0){
      for (int i = -1; i <= 1; i++){
        for (int j = -1; j <=1; j++){
          int xSample = (int)globalWidth/2 + i * spacing;
          int ySample = (int)globalHeight/2 + j * spacing;
          float val = stack.get(in).data[xSample+ySample*globalWidth];
          //println(xSample, ySample, val);
          kernel[i+1][j+1] = val; 
        }
      }
    } 
    
    //draw the kernel to the top left of the signal just bcuz
    for (int i = 0; i < 3; i++){
      for (int j = 0; j < 3; j++){
        stack.get(out).data[i+j*globalWidth] = kernel[i][j];
      }
    }
    
    //show sample points in the output signal
    for (int i = -1; i <= 1; i++){
      for (int j = -1; j <=1; j++){
        int xSample = (int)globalWidth/2 + i * spacing;
        int ySample = (int)globalHeight/2 + j * spacing;
        stack.get(out).data[xSample+ySample*globalWidth] = 255; 
      }
    }
    
    super.lookDown();
  }
  
  void display(){
    super.display();
    if (!collapse){
      for (int i = 0; i < 3; i++){
        for (int j = 0; j < 3; j++){
          text(str((float)round(100*kernel[i][j])/100), pos.x+65+i*35, pos.y+30+j*30);
        }
      }
    }
  }
  
}

class StructuringElement extends Module{ 
  
  ThreeWay[] buttonArray = new ThreeWay[81];
  boolean collapse = false;
  
  StructuringElement(PVector pos_){
    super(pos_);
    name = "structure";
    size = new PVector(102, 97);
    c = color(125, 100, 175);
    helper = new HelpBox(structuringElementHelp);  
    //these are the nodes that allow the user to interact with the module 
    
    cp5.addSlider("elementX"+str(id))
      .setLabel("")
      .setPosition(24, 12)
      .setSize(64, 10)
      .setRange(0, 4)
      .setValue(1)
      .plugTo(this, "cp5Handler")
      .setGroup("g"+str(id))      
      ;
      
    cp5.addSlider("elementY"+str(id))
      .setLabel("")
      .setPosition(24, 24)
      .setSize(64, 10)
      .setRange(0, 4)
      .setValue(1)
      .plugTo(this, "cp5Handler")
      .setGroup("g"+str(id))      
      ;
      
    cp5.addButton("collapse"+str(id))
      .setLabel("")
      .setPosition(8, 12)
      .setSize(10, 10)
      .plugTo(this, "collapseElement")
      .setGroup("g"+str(id))  
      ;
      
      
    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));    
    ins = new InputNode[1];
    outs = new OutputNode[1];
    modIns = new ModInput[2];
   
    ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
    modIns[0] = new ModInput(new PVector(id, 0, -1), new PVector(pos.x+size.x-8, pos.y+12), "elementX"+str(id));  
    modIns[1] = new ModInput(new PVector(id, 1, -1), new PVector(pos.x+size.x-8, pos.y+24), "elementY"+str(id));  

    initializeStructuringElement();
  }
  
  void cp5Handler(float val){
    if (cp5.getController("elementX"+str(id)).isMousePressed()){
      if (!modIns[0].pauseInput){
        modIns[0].baseVal = val;
        modIns[0].pauseInput = true;
      }
    }
    if (cp5.getController("elementY"+str(id)).isMousePressed()){
      if (!modIns[1].pauseInput){
        modIns[1].baseVal = val;
        modIns[1].pauseInput = true;
      }
    }
    if (structuringElement.length != 2*(int)cp5.getController("elementX"+str(id)).getValue()+1 || structuringElement[0].length != 2*(int)cp5.getController("elementY"+str(id)).getValue()+1){
      resizeStructuringElement();
      headsUp();
    }    
  }
  
  void collapseElement(){
    if (collapse){
      //lazy
      resizeStructuringElement();
      collapse = false;
    } else {
      size.set(102, 40);
      for (int i = 0; i < 9; i++){
        for (int j = 0; j < 9; j++){
          cp5.getController("struc"+str(i+j*9)+"-"+str(id)).hide();
        }
      }
      collapse = true;
    }
    grabber.pos = new PVector(pos.x+size.x/2, pos.y);
    outs[0].pos = new PVector(pos.x, pos.y+size.y-8);
    modIns[0].pos = new PVector(pos.x+size.x-8, pos.y+12);
    modIns[1].pos = new PVector(pos.x+size.x-8, pos.y+24);
  }
  
  void resizeStructuringElement(){  
    structuringElement = new int[2*(int)cp5.getController("elementX"+str(id)).getValue()+1][2*(int)cp5.getController("elementY"+str(id)).getValue()+1];
    
    size = new PVector(max(20+16*structuringElement.length, 102), 48+16*structuringElement[0].length);
    grabber.pos = new PVector(pos.x+size.x/2, pos.y);
    outs[0].pos = new PVector(pos.x, pos.y+size.y-8);
    modIns[0].pos = new PVector(pos.x+size.x-8, pos.y+12);
    modIns[1].pos = new PVector(pos.x+size.x-8, pos.y+24);
    
    //cp5.getController("struc0-0").hide();
    for (int i = 0; i < 9; i++){
      for (int j = 0; j < 9; j++){
        if (i >= structuringElement.length || j >= structuringElement[0].length){
          cp5.getController("struc"+str(i+j*9)+"-"+str(id)).hide();
        } else {
          cp5.getController("struc"+str(i+j*9)+"-"+str(id)).show();        
          switch(buttonArray[i+j*9].state){
          case 0 :
            structuringElement[i][j] = 0;
            break;
          case 1 :
            structuringElement[i][j] = 255;
            break;
          case 2 :
            structuringElement[i][j] = -1;
            break;  
            
          }
        }
      }
    }
  }
  
  void initializeStructuringElement(){    
    structuringElement = new int[3][3]; 
    for (int i = 0; i < 9; i++){
      for (int j = 0; j < 9; j++){
        
        buttonArray[i+j*9] = new ThreeWay(cp5, new PVector(id, i, j), 0);
       // buttonArray[i+j*9].setPosition(11+i*16, 40+j*16);
          //.setSize(15, 15)
          //.setLabel("")
          //.setGroup("g"+str(id))
          //.plugTo(this, "headsUp")
          //;
            
        if (i >= 3 || j >= 3){
          cp5.getController("struc"+str(i+j*9)+"-"+str(id)).hide();
        } else {
          structuringElement[i][j] = 0;
        } 
        
      }
    }
  }
  
  void operate(){
    super.operate();
    int in = ins[0].flowId;  
    int out = outs[0].flowId;
    
    //check if input has a connection, build element based on binary input signal
    if (in > 0) {
      for (int i = 0; i < structuringElement.length; i++){
        for (int j = 0; j < structuringElement[0].length; j++){ 
          int xLoc = (int)map(i, 0, structuringElement.length-1, 1, globalWidth-1);
          int yLoc = (int)map(j, 0, structuringElement[0].length-1, 1, globalHeight-1);
          switch((int)stack.get(in).data[xLoc+yLoc*globalWidth]){
          case 0 :
            //cp5.getController("struc"+str(i+j*9)+"-"+str(id)).turnOff();
            buttonArray[i+j*9].turnOff();
            break;
          case 255 :
            //cp5.getController("struc"+str(i+j*9)+"-"+str(id)).turnOn();
            buttonArray[i+j*9].turnOn();
            break;
          case -1 :
            //cp5.getController("struc"+str(i+j*9)+"-"+str(id)).turnDontCare();
            buttonArray[i+j*9].turnDontCare();
            break;  
          }
        }
      }  
    }
    
    for (int i = 0; i < structuringElement.length; i++){
      for (int j = 0; j < structuringElement[0].length; j++){        
        stack.get(out).data[i+j*globalWidth] = structuringElement[i][j];
      }
    }  
    
    super.lookDown();
  } 
}

class LargeStructuringElement extends Module{ 
    
  PImage structureImage;
  
  LargeStructuringElement(PVector pos_){
    super(pos_);
    name = "large structure";
    size = new PVector(102, 51);
    c = color(125, 100, 175);
    helper = new HelpBox(largeStructuringElementHelp);  
    //these are the nodes that allow the user to interact with the module 
    
    cp5.addSlider("elementX"+str(id))
      .setLabel("")
      .setPosition(10, 12)
      .setSize(76, 10)
      .setRange(1, 32)
      .setValue(1)
      .plugTo(this, "cp5Handler")
      .setGroup("g"+str(id))      
      ;
      
    cp5.addSlider("elementY"+str(id))
      .setLabel("")
      .setPosition(10, 24)
      .setSize(76, 10)
      .setRange(1, 32)
      .setValue(1)
      .plugTo(this, "cp5Handler")
      .setGroup("g"+str(id))      
      ;   
      
    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));    
    ins = new InputNode[1];
    outs = new OutputNode[1];
    modIns = new ModInput[2];
   
    ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
    modIns[0] = new ModInput(new PVector(id, 0, -1), new PVector(pos.x+size.x-8, pos.y+12), "elementX"+str(id));  
    modIns[1] = new ModInput(new PVector(id, 1, -1), new PVector(pos.x+size.x-8, pos.y+24), "elementY"+str(id));  

    initializeStructuringElement();
    initializeImage();
  }
  
  void cp5Handler(float val){
    if (cp5.getController("elementX"+str(id)).isMousePressed()){
      if (!modIns[0].pauseInput){
        modIns[0].baseVal = val;
        modIns[0].pauseInput = true;
      }
    }
    if (cp5.getController("elementY"+str(id)).isMousePressed()){
      if (!modIns[1].pauseInput){
        modIns[1].baseVal = val;
        modIns[1].pauseInput = true;
      }
    }
    if (structuringElement.length != 2*(int)cp5.getController("elementX"+str(id)).getValue()+1 || structuringElement[0].length != 2*(int)cp5.getController("elementY"+str(id)).getValue()+1){
      resizeStructuringElement();
      resizeImage();
      headsUp();
    }    
  }
  
  void initializeStructuringElement(){   
    structuringElement = new int[3][3]; 
    for (int i = 0; i < 3; i++){
      for (int j = 0; j < 3; j++){
        structuringElement[i][j] = 0;
      }
    }    
  }
  
  void initializeImage(){
    structureImage = createImage(structuringElement.length, structuringElement[0].length, RGB);
    structureImage.loadPixels();    
    for (int i = 0; i < structureImage.pixels.length; i++){
      structureImage.pixels[i] = color(255, 0, 0);
    }
    structureImage.updatePixels();
  }
  
  void resizeStructuringElement(){  
    structuringElement = new int[2*(int)cp5.getController("elementX"+str(id)).getValue()+1][2*(int)cp5.getController("elementY"+str(id)).getValue()+1];    
    size = new PVector(102, 48+structuringElement[0].length);
    grabber.pos = new PVector(pos.x+size.x/2, pos.y);
    outs[0].pos = new PVector(pos.x, pos.y+size.y-8);
    modIns[0].pos = new PVector(pos.x+size.x-8, pos.y+12);
    modIns[1].pos = new PVector(pos.x+size.x-8, pos.y+24);
  }
  
  void resizeImage(){
    structureImage = createImage(structuringElement.length, structuringElement[0].length, RGB);
  }
  
  void operate(){
    super.operate();
    int in = ins[0].flowId;  
    int out = outs[0].flowId;
      
    //populate the element based on binary signal. Update image too.
    structureImage.loadPixels();
    for (int i = 0; i < structuringElement.length; i++){
      for (int j = 0; j < structuringElement[0].length; j++){ 
        int xLoc = (int)map(i, 0, structuringElement.length-1, 1, globalWidth-1);
        int yLoc = (int)map(j, 0, structuringElement[0].length-1, 1, globalHeight-1);
        structuringElement[i][j] = (int)stack.get(in).data[xLoc+yLoc*globalWidth];        
        stack.get(out).data[i+j*globalWidth] = structuringElement[i][j];
        switch(structuringElement[i][j]){
        case 0 :
          structureImage.pixels[i+j*structureImage.width] = color(255, 0, 0);
          break;
        case 255 :
          structureImage.pixels[i+j*structureImage.width] = color(0, 255, 0);
          break;
        case -1 :
          structureImage.pixels[i+j*structureImage.width] = color(127);
          break; 
        }
      }
    }   
    structureImage.updatePixels();
    
    super.lookDown();
  } 
  
  void display(){
    super.display();
    image(structureImage, pos.x+16, pos.y+40);
  }
}

class Math extends Module{
    
  Math(PVector pos_){
    super(pos_);
    size = new PVector(101, 50);
    c = color(125, 100, 175);    
    seeds.add(random(1000));
    name = "math";
    helper = new HelpBox(mathHelp);

    cp5.addTextfield("mathInput"+str(id))
      .setLabel("")
      .setPosition(6, 12)
      .setSize(90, 12)
      .setColor(color(255,0,0))
      .show()
      .setText("x")
      .setGroup("g"+str(id))      
      ;
      
    cp5.addTextfield("rangeMinX"+str(id))
      .setLabel("")
      .setPosition(6, 27)
      .setSize(15, 12)
      .setColor(color(255,0,0))
      .show()
      .setText("-150")
      .setGroup("g"+str(id))      
      ;
      
    cp5.addTextfield("rangeMinY"+str(id))
      .setLabel("")     
      .setPosition(23, 27)
      .setSize(15, 12)
      .setColor(color(255,0,0))
      .show()
      .setText("-150")
      .setGroup("g"+str(id))
      ;
      
    cp5.addTextfield("rangeMaxX"+str(id))
      .setLabel("")
      .setPosition(64, 27)
      .setSize(15, 12)
      .setColor(color(255,0,0))
      .show()
      .setText("150")
      .setGroup("g"+str(id))      
      ;
      
    cp5.addTextfield("rangeMaxY"+str(id))
      .setLabel("")     
      .setPosition(81, 27)
      .setSize(15, 12)
      .setColor(color(255,0,0))
      .show()
      .setText("150")
      .setGroup("g"+str(id))
      ;   
      
    cp5.addButton("evaluate"+str(id))
      .setLabel("")
      .setPosition(46, 27)
      .setSize(10, 10)
      .plugTo(this, "headsUp")
      .setGroup("g"+str(id))
      ;   
      
    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));
    
    outs = new OutputNode[1];
    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));
  
  }
  
  void operate(){
    //super.operate();
    int out = outs[0].flowId;
    String text = cp5.get(Textfield.class, "mathInput"+str(id)).getText();
    int minX = int(cp5.get(Textfield.class, "rangeMinX"+str(id)).getText());
    int minY = int(cp5.get(Textfield.class, "rangeMinY"+str(id)).getText());
    int maxX = int(cp5.get(Textfield.class, "rangeMaxX"+str(id)).getText());
    int maxY = int(cp5.get(Textfield.class, "rangeMaxY"+str(id)).getText());
    Expression exp = new Expression(text);
    exp.evaluateOverField(minX, minY, maxX, maxY);
    for (int i = 0; i < globalWidth; i++){
      for (int j = 0; j < globalHeight; j++){
        stack.get(out).data[i+j*globalWidth] = exp.data[i+j*globalWidth];
      }
    }
    super.lookDown();
  }
  
} 

public class Image extends Module{
  
  PImage imageOut;
  
  Image(PVector pos_){
    super(pos_);
    size = new PVector(60, 30);
    c = color(125, 100, 175);    
    name = "image";
    helper = new HelpBox(imageHelp);

    cp5.addButton("getImage"+str(id))
      .setLabel("")
      .setPosition(6, 6)
      .setSize(10, 10)
      .plugTo(this, "getImage")
      .setGroup("g"+str(id))
      ; 

    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));    
    outs = new OutputNode[4];
    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));     
    outs[1] = new OutputNode(new PVector(id, 1), new PVector(pos.x+size.x-38, pos.y+size.y-8));   
    outs[1].col  = color(255, 0, 0);
    outs[1].colorChannels.set(255, 0, 0);
    outs[2] = new OutputNode(new PVector(id, 2), new PVector(pos.x+size.x-23, pos.y+size.y-8));     
    outs[2].col  = color(0, 255, 0);
    outs[2].colorChannels.set(0, 255, 0);
    outs[3] = new OutputNode(new PVector(id, 3), new PVector(pos.x+size.x-8, pos.y+size.y-8));     
    outs[3].col  = color(0, 0, 255);
    outs[3].colorChannels.set(0, 0, 255);
  }
  
  void getImage(){
    selectInput("Select a file to process:", "fileSelected", null, this); 
  }
  
  void fileSelected(File selection) {
    if (selection == null) {
      println("Window was closed or the user hit cancel.");
    } else {
      imageOut = loadImage(selection.getAbsolutePath()); 
      //imageOut.resize(globalWidth, globalHeight);
      headsUp();  
    }
  }
  
  void operate(){
    if (imageOut != null){
      imageOut.loadPixels();
      for (int i = 0; i < globalWidth; i++){
        for (int j = 0; j < globalHeight; j++){
          int dataLoc = i+j*globalWidth;
          
          if (i >= imageOut.width || j >= imageOut.height){           
            for (int k = 0; k < 4; k++){
              stack.get(outs[k].flowId).data[dataLoc] = 0;
            }
          } else {
            int imgLoc = i+j*imageOut.width;
            stack.get(outs[0].flowId).data[dataLoc] = brightness(imageOut.pixels[imgLoc]);
            stack.get(outs[1].flowId).data[dataLoc] = (imageOut.pixels[imgLoc] >> 16) & 0xFF;;
            stack.get(outs[2].flowId).data[dataLoc] = (imageOut.pixels[imgLoc] >> 8) & 0xFF;
            stack.get(outs[3].flowId).data[dataLoc] = imageOut.pixels[imgLoc] & 0xFF;
          }
        }
      }
      imageOut.updatePixels();
      super.lookDown();
    }
  }
} 

public class Vid extends Module{
  
  String dataDirectory;
  String fileType;
  PImage currentFrame;
  int currentFrameIndex = 1;
  int scrubOffset;
  int totalFrames;
  int lastOperatingFrame = -1;
  float frameChanger = 0;
  boolean isPlaying = false;
  boolean updating = true;
  
  Vid(PVector pos_){
    super(pos_);
    size = new PVector(80, 76);
    c = color(125, 100, 175); 
    name = "video";
    helper = new HelpBox(videoHelp);
    isMovie = true;
      
    cp5.addTextfield("dataDirectory"+str(id))
      .setLabel("")     
      .setPosition(6, 12)
      .setSize(50, 12)
      .setColor(color(255,0,0))
      .show()
      .setGroup("g"+str(id))
      ; 
      
    cp5.addButton("update"+str(id))
      .setLabel("")
      .setPosition(64, 12)
      .setSize(10, 10)
      .plugTo(this, "updateDataDirectory")
      .setGroup("g"+str(id))
      ;   
      
    cp5.addSlider("playbackRate"+str(id))
      .setLabel("")
      .setPosition(6, 28)
      .setWidth(62)
      .setHeight(10)
      .setRange(-1, 1)
      .setValue(1)
      .plugTo(this, "cp5Handler")
      .setGroup("g"+str(id))
      ;   
      
    cp5.addButton("playPause"+str(id))
      .setLabel("")
      .setPosition(32, 40)
      .setSize(10, 10)
      .plugTo(this, "playPause")
      .setGroup("g"+str(id))
      ; 
      
    cp5.addButton("advance"+str(id))
      .setLabel("")
      .setPosition(47, 40)
      .setSize(10, 10)
      .plugTo(this, "advance")
      .setGroup("g"+str(id))
      ; 
      
    cp5.addButton("retreat"+str(id))
      .setLabel("")
      .setPosition(17, 40)
      .setSize(10, 10)
      .plugTo(this, "retreat")
      .setGroup("g"+str(id))
      ;
      
    cp5.addSlider("scrub"+str(id))
      .setLabel("")
      .setPosition(6, 52)
      .setWidth(62)
      .setHeight(10)
      .setRange(0, 1)
      .setValue(0)
      .plugTo(this, "scrub")
      .setGroup("g"+str(id))
      ;    
      
    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));    
    outs = new OutputNode[4];
    modIns = new ModInput[2];
    
    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));     
    outs[1] = new OutputNode(new PVector(id, 1), new PVector(pos.x+size.x-38, pos.y+size.y-8));   
    outs[1].col  = color(255, 0, 0);
    outs[1].colorChannels.set(255, 0, 0);
    outs[2] = new OutputNode(new PVector(id, 2), new PVector(pos.x+size.x-23, pos.y+size.y-8));     
    outs[2].col  = color(0, 255, 0);
    outs[2].colorChannels.set(0, 255, 0);
    outs[3] = new OutputNode(new PVector(id, 3), new PVector(pos.x+size.x-8, pos.y+size.y-8));     
    outs[3].col  = color(0, 0, 255);
    outs[3].colorChannels.set(0, 0, 255);
    modIns[0] = new ModInput(new PVector(id, 0, -1), new PVector(pos.x+size.x-8, pos.y+28), "playbackRate"+str(id));
    modIns[1] = new ModInput(new PVector(id, 1, -1), new PVector(pos.x+size.x-8, pos.y+52), "scrub"+str(id));
  }
  
  void scrub(){
    updating = true;
    if (cp5.getController("scrub"+str(id)).isMousePressed()){    
      if (!modIns[1].pauseInput){
        modIns[1].baseVal = cp5.getController("scrub"+str(id)).getValue();
        modIns[1].pauseInput = true;
      }
    }
    currentFrameIndex = (int)map(cp5.getController("scrub"+str(id)).getValue(), 0, 1, 1, totalFrames-1);
  }
    
    
  void cp5Handler(float val){
    if (cp5.getController("playbackRate"+str(id)).isMousePressed()){
      if (!modIns[0].pauseInput){
        modIns[0].baseVal = val;
        modIns[0].pauseInput = true;
      }
    }
    if (cp5.getController("scrub"+str(id)).isMousePressed()){
      updating = true;
      if (!modIns[1].pauseInput){
        modIns[1].baseVal = val;
        modIns[1].pauseInput = true;
      }
    }
    headsUp();
  }
  
  void updateDataDirectory(){
    dataDirectory = sketchPath()+"/videoSources/"+cp5.get(Textfield.class, "dataDirectory"+str(id)).getText()+"/";
    File dir = new File(dataDirectory);
    File[] files = dir.listFiles();
    totalFrames = files.length-1;
    
    String fileName = files[0].toString();
    int index = fileName.lastIndexOf('.');
    if(index > 0) {
      fileType = fileName.substring(index);
    }
  }
  
  void playPause(){
    isPlaying = flick(isPlaying);
  }
  
  void advance(){
      currentFrameIndex++;
      updating = true;
  }
  
  void retreat(){
      currentFrameIndex--;
      if (currentFrameIndex<0){
        currentFrameIndex = totalFrames-2;
      }
      updating = true;
  }
  
  void headsUp(){
    if(totalFrames > 0 && isPlaying){
      super.headsUp();
    }
  }
  
  void operate(){
    
    //bad way of making sure we don't operate twice in one frame
    if (lastOperatingFrame != frameCount){
      if (isPlaying){
        //frameChanger += cp5.getController("playbackRate"+str(id)).getValue();
        //if (abs(frameChanger) >= 1.0){
        //  if (frameChanger>0){
        //    advance();
        //    frameChanger--;
        //  } else{
        //    retreat();
        //    frameChanger++;
        //  }
        //}
        advance();
      }
      
      if (updating){
        currentFrameIndex = currentFrameIndex%(totalFrames-1) ;
        currentFrame = loadImage(dataDirectory+str(1+currentFrameIndex)+fileType); 
        currentFrame.resize(globalWidth, globalHeight);
        currentFrame.loadPixels();
        
        //updates grayscale output if there is a connection
        if (outs[0].receivers.size() > 0){
          int grayOutput = outs[0].flowId;
          for (int i = 0; i < globalWidth; i++){
            for (int j = 0; j < globalHeight; j++){
              stack.get(grayOutput).data[i+j*globalWidth] = brightness(currentFrame.pixels[i+j*globalWidth]);      
            }
          }
        }
        
        //updates color channels if they have connections
        for (int x = 1; x < 4; x++){
          if (outs[x].receivers.size() > 0){
            int colorOutput = outs[x].flowId;
            int shiftAmount = 16-(8*(x-1));
            for (int i = 0; i < globalWidth; i++){
              for (int j = 0; j < globalHeight; j++){
                stack.get(colorOutput).data[i+j*globalWidth] = (currentFrame.pixels[i+j*globalWidth] >> shiftAmount) & 0xFF;
              }
            }
          }
        }
        currentFrame.updatePixels();
        updating = false;
      }         
    }
    lastOperatingFrame = frameCount;
    super.lookDown();    
  }
  
  boolean allSystemsGo(){
    if (outs[0].flowId > 0 || outs[1].flowId > 0 || outs[2].flowId > 0 || outs[3].flowId > 0){
      return true;
    } else {
      return false;
    }
  }
  
  void display(){
    super.display();
    fill(0);
    text(str(currentFrameIndex)+"/"+str(totalFrames), pos.x, pos.y+size.y+12);
  }

}  

public class D435 extends Module{
  
  D435(PVector pos_){
    super(pos_);
    size = new PVector(72, 30);
    c = color(125, 100, 175); 
    name = "d435";
    helper = new HelpBox(depthCamHelp);
    isMovie = true;    
      
    depthCam.enableDepthStream(globalWidth, globalHeight); 
    depthCam.enableColorStream(globalWidth, globalHeight);
    depthCam.enableIRStream(globalWidth, globalHeight);

    //depthCam.enableAlign();
    depthCam.start();  
    
    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));    
    outs = new OutputNode[5];
    
    outs[0] = new OutputNode(new PVector(id, 0), new PVector(pos.x, pos.y+size.y-8));  
    outs[1] = new OutputNode(new PVector(id, 1), new PVector(pos.x+16, pos.y+size.y-8));     
    outs[1].col  = color(127, 0, 0);
    outs[1].colorChannels.set(127, 0, 0);
    outs[2] = new OutputNode(new PVector(id, 2), new PVector(pos.x+32, pos.y+size.y-8));     
    outs[2].col  = color(255, 0, 0);
    outs[2].colorChannels.set(255, 0, 0);
    outs[3] = new OutputNode(new PVector(id, 3), new PVector(pos.x+48, pos.y+size.y-8));     
    outs[3].col  = color(0, 255, 0);
    outs[3].colorChannels.set(0, 255, 0);
    outs[4] = new OutputNode(new PVector(id, 4), new PVector(pos.x+64, pos.y+size.y-8));     
    outs[4].col  = color(0, 0, 255);
    outs[4].colorChannels.set(0, 0, 255);

  }
  
  void operate(){ 
    
    int depthOut = outs[0].flowId;
    int ir = outs[1].flowId;
    int r = outs[2].flowId;
    int g = outs[3].flowId;
    int b = outs[4].flowId;

    depthCam.readFrames();
    
    if (outs[0].receivers.size() > 0){  
      short[][] depthData = depthCam.getDepthData();      
      for (int y = 0; y < 480; y++){
        for (int x = 0; x < 640; x++){
          stack.get(depthOut).data[x+y*globalWidth] = constrain((float)depthData[y][x], 0, 5000);
        }
      }
    }
    
    if (outs[1].receivers.size() > 0){
          depthCam.readFrames();

      for (int y = 0; y < 480; y++){
        for (int x = 0; x < 640; x++){
          int loc = x+y*globalWidth;
          stack.get(ir).data[loc] = depthCam.getIRImage().pixels[loc] & 0xFF;        
        }
      }
    }
    
    if (outs[2].receivers.size() > 0 || outs[3].receivers.size() > 0 || outs[4].receivers.size() > 0){
      for (int i = 0; i < globalWidth; i++){
        for (int j = 0; j < globalHeight; j++){
          int loc = i+j*globalWidth;
          stack.get(r).data[loc] = (depthCam.getColorImage().pixels[loc] >> 16) & 0xFF;
          stack.get(g).data[loc] = (depthCam.getColorImage().pixels[loc] >> 8) & 0xFF;
          stack.get(b).data[loc] = depthCam.getColorImage().pixels[loc] & 0xFF;
        }
      }
    }
         
    super.lookDown();
  }
}
