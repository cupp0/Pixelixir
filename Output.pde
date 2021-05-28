class Displayer extends Module{
  
  String savePath = "stills";
  boolean connectedToGenerator = false;  
  PImage img;
  boolean recording = false;
  boolean activeDisplay = true;
  int savedFrames = 0;
  
  Displayer(PVector pos_){
    super(pos_);
    size = new PVector(globalWidth+10, 33+globalHeight);
    c = color(200, 100, 200);
    name = "display";
    helper = new HelpBox(displayHelp);
    isDisplay = true;
    
    cp5.addButton("record"+str(id))
      .setLabel("record")
      .setPosition(size.x-80, 5)
      .setSize(15, 15)
      .setColorBackground(color(100, 0, 0))
      .plugTo(this, "flipRecord")
      .setGroup("g"+str(id))
      ;
      
    cp5.addButton("singleFrame"+str(id))
      .setLabel("still")
      .setPosition(size.x-105, 5)
      .setSize(15, 15)
      .setColorBackground(color(100, 0, 0))
      .plugTo(this, "grabStill")
      .setGroup("g"+str(id))
      ;
      
    cp5.addButton("active"+str(id))
      .setLabel("active")
      .setPosition(size.x/2-24, 5)
      .setSize(15, 15)
      .setColorBackground(color(100, 0, 0))
      .plugTo(this, "flipActive")
      .setGroup("g"+str(id))
      ;    
      
    cp5.addTextfield("savePath"+str(id))
      .setLabel("")     
      .setPosition(size.x-55, 5)
      .setSize(50, 15)
      .setColor(color(255,0,0))
      .show()
      .setText(savePath)
      .setGroup("g"+str(id))
      ; 
    
    ins = new InputNode[4];
    
    ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
    ins[1] = new InputNode(new PVector(id, 1), new PVector(pos.x+20, pos.y));
    ins[2] = new InputNode(new PVector(id, 2), new PVector(pos.x+35, pos.y));
    ins[3] = new InputNode(new PVector(id, 3), new PVector(pos.x+50, pos.y));
    
    ins[1].col  = color(255, 0, 0);
    ins[2].col  = color(0, 255, 0);
    ins[3].col  = color(0, 0, 255);
    
    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));
    initDisplay();
  }
  
  void initDisplay(){ 
    img = createImage(globalWidth, globalHeight, RGB);
    img.loadPixels();
    for (int i = 0; i < img.pixels.length; i++) {
      img.pixels[i] = color(0); 
    }
    img.updatePixels();
  }
  
  void flipRecord(){
    if (recording){
      recording = false;
      cp5.getController("record"+str(id)).setColorBackground(color(100, 0, 0));
      savedFrames = 0;
    } else {
      savePath = cp5.get(Textfield.class, "savePath"+str(id)).getText();
      recording = true;
      cp5.getController("record"+str(id)).setColorBackground(color(200, 0, 0));
    }
  }
  
  void flipActive(){
    if (activeDisplay){
      activeDisplay = false;
      size = new PVector(250, 25);
    } else {
      activeDisplay = true;
      size = new PVector(globalWidth+10, 33+globalHeight);
      grabber.pos = new PVector(pos.x+size.x/2, pos.y);
    }
    repositionUI();
  }
  
  void grabStill(){
    savePath = cp5.get(Textfield.class, "savePath"+str(id)).getText();
    img.save(savePath+"still"+str(frameCount)+".tif");
  }
  
  void repositionUI(){
    grabber.pos = new PVector(pos.x+size.x/2, pos.y);
    cp5.getController("record"+str(id)).setPosition(size.x-80, 5);
    cp5.getController("singleFrame"+str(id)).setPosition(size.x-105, 5);
    cp5.getController("savePath"+str(id)).setPosition(size.x-55, 5);
    cp5.getController("active"+str(id)).setPosition(size.x/2-24, 5);
  }
  
  void changeDataDimensions(){ 
    img.resize(globalWidth, globalHeight); 
    size = new PVector(globalWidth+10, 33+globalHeight);
    repositionUI();
    super.changeDataDimensions();   
  }
  
  void operate(){
    super.operate();
    
    int in0 = ins[0].flowId;
    int in1 = ins[1].flowId;
    int in2 = ins[2].flowId;
    int in3 = ins[3].flowId;
    
    img.loadPixels();    
    //if any rgb channels are live, override input 1
    if (in1 >= 1 || in2 >= 1 || in3 >= 1){
      for (int i = 0; i < globalWidth; i++){
        for (int j = 0; j < globalHeight; j++){
          int loc = i+j*globalWidth;
          img.pixels[loc] = color(stack.get(in1).data[loc], stack.get(in2).data[loc], stack.get(in3).data[loc]);
        }
      }      
    } else { // grayscale
      for (int i = 0; i < globalWidth; i++){
        for (int j = 0; j < globalHeight; j++){
          int loc = i+j*globalWidth;
          img.pixels[loc] = color(stack.get(in0).data[loc]%256); //should we try to get rid of %256?
        }
      }
    }
    img.updatePixels();
  }
  
  void display(){
    super.display();
    if (activeDisplay){
      if ((ins[0].flowId >= 1 || ins[1].flowId >= 1 || ins[2].flowId >= 1 || ins[3].flowId >= 1) && (ins[0].lookUp || ins[1].lookUp || ins[2].lookUp || ins[3].lookUp)){
        operate();
        for (InputNode n : ins){
          n.lookUp = false;
        }
      }
      image(img, pos.x+5, pos.y+28);
      if (recording){
        img.save("videoSources/"+savePath+"/"+str(savedFrames)+".tif");
        savedFrames++;
      }
    }
  }
}
