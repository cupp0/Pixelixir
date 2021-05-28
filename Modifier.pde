//Maybe bad to piggyback off Module here, but also maybe fine? Main point of interest
//is that we don't headsUp() whenever we change cp5. This is because all
//operate() does is change cp5 in other modules. So we just call operate() directly
//and modules that handle data down the line will handle headsUp().

//Modifiers would be better of doing one calculation at a time and continuously
//drawing over the envelope PImage
class Modifier extends Module{
  
  int duration;
  float amplitude;
  int phase;
  boolean inv;
  boolean rev;
  PVector trackerPosition = new PVector(0, 25);
  PImage env;
    
  Modifier(PVector pos_){
    super(pos_);
    size = new PVector(115, 110);
    c = color(250, 150, 50);
    name = "modulator";
    helper = new HelpBox(modifierHelp);
    isModifier = true;
    seeds.add(random(1000)); 
      
    float[] arr = {1, 0, 0, 0};
    cp5.addRadioButton("modType"+str(id))
      .setPosition(6, 6)
      .addItem("sin"+str(id), 0)
      .addItem("square"+str(id), 1)
      .addItem("saw"+str(id), 2)
      .addItem("tri"+str(id), 3)
      .addItem("noise"+str(id), 4)
      .addItem("random"+str(id), 5)
      .setGroup("g"+str(id))
      .setArrayValue(arr);
      ;
      
    cp5.addTextfield("modNoiseSeed"+str(id))
      .setLabel("seed") 
      .setText(str(seeds.size()-1))
      .setPosition(6, 75)
      .setSize(15, 10)
      .setColor(color(255,0,0))
      .show()
      .setGroup("g"+str(id))
      ;    
    
      
    cp5.addTextfield("duration"+str(id))
      .setLabel("duration") 
      .setText(str(100))
      .setPosition(60, 15)
      .setSize(25, 10)
      .setColor(color(255,0,0))
      .show()
      .setGroup("g"+str(id))
      ;
      
    cp5.addTextfield("phase"+str(id))
      .setLabel("phase") 
      .setText(str(0))
      .setPosition(60, 39)
      .setSize(25, 10)
      .setColor(color(255,0,0))
      .show()
      .setGroup("g"+str(id))
      ;
      
    cp5.addSlider("amp"+str(id))
      .setPosition(100, 8)
      .setWidth(10)
      .setHeight(95)
      .setRange(.001, 1)
      .setValue(.1)
      .setLabelVisible(false)
      .plugTo(this, "operate")
      .setGroup("g"+str(id))
      ;
      
    cp5.addToggle("invert"+str(id))
      .setLabel("inv")
      .setPosition(60, 63)
      .setSize(10, 10)
      .plugTo(this, "invertEnv")
      .setGroup("g"+str(id))
      ; 
      
    cp5.addToggle("reverse"+str(id))
      .setLabel("rev")
      .setPosition(60, 87)
      .setSize(10, 10)
      .plugTo(this, "reverseEnv")
      .setGroup("g"+str(id))
      ;   
        
    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));
    modOuts = new ModOutput[1];    
    modOuts[0] = new ModOutput(new PVector(id, 0, -1), new PVector(pos.x, pos.y+size.y-8));
      
    env = createImage((int)size.x, 50, RGB);  
    operate();  
  }
  
  void display(){
    super.display();
    trackOutput();
    image(env, pos.x, pos.y+size.y);
  }
  
  //change env PImage to reflect where we are in the modifier envelope
  void trackOutput(){
    float prev = (float)((frameCount-1)%duration)/duration;
    float percent = (float)(frameCount%duration)/duration;
    env.loadPixels();
    for (int i = -1; i <= 1; i++){
      if (i == 0){
        env.pixels[(int)trackerPosition.x+(int)trackerPosition.y*env.width] = color(127);
      } else {
        env.pixels[(int)trackerPosition.x+((int)trackerPosition.y+i)*env.width] = color(0);
      }
    }
    for (int x = 0; x < env.width; x++) {
      if (abs((float)percent-(float)((float)x/env.width)) < .01){        
        trackerPosition.set(x, (int)(25+map(modOuts[0].modData[(int)map(x, 0, env.width, 0, duration)], -1.2, 1.2, 25, -25)));
        for (int i = -1; i <= 1; i++){
          env.pixels[(int)trackerPosition.x+((int)trackerPosition.y+i)*env.width] = color(255, 0, 0); 
        }
        break;
      } 
    }
    env.updatePixels();
  }
  
  void sendModValue(){
    for (PVector p : modOuts[0].receivers){
      modules.get((int)p.x).modIns[(int)p.y].receiveModValue(modOuts[0].modData[frameCount%duration]);
      modules.get((int)p.x).headsUp();  
    }   
  }
  
  //generates envelope
  void operate(){
    duration = int(cp5.get(Textfield.class, "duration"+str(id)).getText());
    phase = int(cp5.get(Textfield.class, "phase"+str(id)).getText());
    amplitude = cp5.getController("amp"+str(id)).getValue()/2;

    int type = (int)cp5.getGroup("modType"+str(id)).getValue();
    float[] prePhase = new float[duration];
    modOuts[0].modData = new float[duration];
    switch(type){
    case 0 : //sin
      for (int i = 0; i < duration; i++){
        prePhase[i] = amplitude*sin((float)i*2*PI/duration);
      }
      break;
    case 1 : //square
      for (int i = 0; i < duration; i++){
        if (i<duration/2){
          prePhase[i] = amplitude;
        } else {
          prePhase[i] = -amplitude;
        }
      }
      break;
    case 2 : //saw
      for (int i = 0; i < duration; i++){
        prePhase[i] = amplitude-((float)i/duration)*2*amplitude;
      }
      break;
    case 3 : //tri
      for (int i = 0; i < duration; i++){
        prePhase[i] = amplitude-abs(2*amplitude-((float)i/duration)*4*amplitude);
      }
      break; 
    case 4 : //noise
      float seed = seeds.get(int(cp5.get(Textfield.class, "modNoiseSeed"+str(id)).getText()));
      for (int i = 0; i < duration; i++){
        prePhase[i] = map((float)noise.eval(seed+cos((float)i*2*PI/duration), seed+sin((float)i*2*PI/duration)), -1, 1, -amplitude, amplitude);
      }
      break; 
    case 5 : //random
      for (int i = 0; i < duration; i++){
        prePhase[i] = random(2*amplitude)-amplitude;
      }
      break;   
    }
    //add phase offset
    for (int i = 0; i < duration; i++){
      modOuts[0].modData[i] = prePhase[(i+phase)%duration];
    }
    if (inv){
      inv();
    }
    if (rev){
      rev();
    }
    updateEnv();
  }
  
  void invertEnv(){
    inv = flick(inv);
    operate();
  }
  
  void reverseEnv(){
    rev = flick(rev);
    operate();
  }
  
  void inv(){
    for (int i = 0; i < modOuts[0].modData.length; i++){
      modOuts[0].modData[i] *= -1;
    }
    updateEnv();
  }
  
  void rev(){
    float[] temp = new float[duration];
    arrayCopy(modOuts[0].modData, temp);
    for (int i = 1; i <= duration; i++){
      modOuts[0].modData[i-1] = temp[duration-i];
    }
    updateEnv();
  }
  
  void updateEnv(){
    env.loadPixels();
    for (int i = 0; i < env.pixels.length; i++) {
      env.pixels[i] = color(0); 
    }
    for (int x = 0; x < env.width; x++) {
      env.pixels[x+(int)(25+map(modOuts[0].modData[(int)map(x, 0, env.width, 0, duration)], -1.2, 1.2, 25, -25))*env.width] = color(127) ; 
    }
    env.updatePixels();
  }
  
}

class Sampler extends Module{
  
  int duration = 100;
  float amplitude;
  PVector trackerPosition = new PVector(0, 25);
  PImage env;
    
  Sampler(PVector pos_){
    super(pos_);
    size = new PVector(100, 50);
    c = color(250, 150, 50);
    name = "sampler";
    helper = new HelpBox(samplerHelp);
    isModifier = true;
    
    cp5.addTextfield("duration"+str(id))
      .setLabel("duration") 
      .setText(str(100))
      .setPosition(6, 13)
      .setSize(25, 10)
      .setColor(color(255,0,0))
      .show()
      .setGroup("g"+str(id))
      ;
    
    cp5.addSlider("sampleAmp"+str(id))
      .setLabel("")
      .setPosition(6, 25)
      .setWidth(88)
      .setHeight(10)
      .setRange(.001, 1)
      .setValue(.5)
      .setLabelVisible(false)
      .plugTo(this, "operate")
      .setGroup("g"+str(id))
      ; 
     
    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));
    ins = new InputNode[1];
    modOuts = new ModOutput[1];    

    ins[0] = new InputNode(new PVector(id, 0), new PVector(pos.x, pos.y));
    modOuts[0] = new ModOutput(new PVector(id, 0, -1), new PVector(pos.x, pos.y+size.y-8));   
        
    env = createImage(100, 50, RGB); 
    modOuts[0].modData = new float[duration];
 
  }
  
  void display(){
    super.display();
    if (ins[0].flowId >= 0 && ins[0].lookUp){
      operate();
    }
    if (super.allSystemsGo() && ins[0].flowId > 0){
      trackOutput();
    }
    image(env, pos.x, pos.y+size.y);
  }
  
  //change env PImage to reflect where we are in the modifier envelope
  void trackOutput(){
    float prev = (float)((frameCount-1)%duration)/duration;
    float percent = (float)(frameCount%duration)/duration;
    env.loadPixels();
    for (int i = -1; i <= 1; i++){
      if (i == 0){
        env.pixels[(int)trackerPosition.x+(int)trackerPosition.y*env.width] = color(127);
      } else {
        env.pixels[(int)trackerPosition.x+((int)trackerPosition.y+i)*env.width] = color(0);
      }
    }
    for (int x = 0; x < env.width; x++) {
      if (abs((float)percent-(float)((float)x/env.width)) < .01){        
        trackerPosition.set(x, (int)(25+map(modOuts[0].modData[(int)map(x, 0, env.width, 0, duration)], -1.2, 1.2, 25, -25)));
        for (int i = -1; i <= 1; i++){
          env.pixels[(int)trackerPosition.x+((int)trackerPosition.y+i)*env.width] = color(255, 0, 0); 
        }
        break;
      } 
    }
    env.updatePixels();
  }
  
  //void headsUp(){
  //  super.headsUp();
  //}
  
  void sendModValue(){
    for (PVector p : modOuts[0].receivers){
      modules.get((int)p.x).modIns[(int)p.y].receiveModValue(modOuts[0].modData[frameCount%duration]);
    }
  }
  
  void operate(){
    //checking connections here because in Modifiers, we call operate directly instead of headsUp
    if (super.allSystemsGo() && ins[0].flowId > 0){
      super.operate();
      int in = ins[0].flowId;
      duration = int(cp5.get(Textfield.class, "duration"+str(id)).getText());
      amplitude = cp5.getController("sampleAmp"+str(id)).getValue();
      modOuts[0].modData = new float[duration];    
      for (int i = 0; i < duration; i++){
        float progress = globalWidth*(float)i/duration;
        int floor = floor(progress);
        float interp = progress%1;
        float lowerVal = map(stack.get(in).data[floor], 0, 255, -amplitude, amplitude);
        float upperVal = map(stack.get(in).data[floor+1], 0, 255, -amplitude, amplitude);
        modOuts[0].modData[i] = (1-interp)*lowerVal + interp*upperVal;         
      }
      updateEnv();
    }
  }
  
  void updateEnv(){
    env.loadPixels();
    for (int i = 0; i < env.pixels.length; i++) {
      env.pixels[i] = color(0); 
    }
    for (int x = 0; x < env.width; x++) {
      float yOff = map(modOuts[0].modData[x], -1, 1, 45, 5);
      env.pixels[x+(int)yOff*env.width] = color(127) ; 
    }
    env.updatePixels();
  }
  
}

class MidiMod extends Module{
  
    
  MidiMod(PVector pos_){
    super(pos_);
    size = new PVector(113, 36);
    c = color(250, 150, 50);
    name = "midi";
    helper = new HelpBox(midiHelp);
    isMidi = true;
    isModifier = true;
        
    grabber = new GrabberNode(new PVector(id, 1), new PVector(pos.x+size.x/2-4, pos.y));
    modOuts = new ModOutput[8];    
    modOuts[0] = new ModOutput(new PVector(id, 0, -1), new PVector(pos.x, pos.y+size.y-8));
    modOuts[1] = new ModOutput(new PVector(id, 1, -1), new PVector(pos.x+15, pos.y+size.y-8));
    modOuts[2] = new ModOutput(new PVector(id, 2, -1), new PVector(pos.x+30, pos.y+size.y-8));
    modOuts[3] = new ModOutput(new PVector(id, 3, -1), new PVector(pos.x+45, pos.y+size.y-8));
    modOuts[4] = new ModOutput(new PVector(id, 4, -1), new PVector(pos.x+60, pos.y+size.y-8));
    modOuts[5] = new ModOutput(new PVector(id, 5, -1), new PVector(pos.x+75, pos.y+size.y-8));
    modOuts[6] = new ModOutput(new PVector(id, 6, -1), new PVector(pos.x+90, pos.y+size.y-8));
    modOuts[7] = new ModOutput(new PVector(id, 7, -1), new PVector(pos.x+105, pos.y+size.y-8));
      
  }
  
  void sendMidi(int num, float val){
    for (PVector p : modOuts[num].receivers){
      modules.get((int)p.x).modIns[(int)p.y].receiveModValue(map(val, 0, 127, 0, 1));
    }
  }
  
}
