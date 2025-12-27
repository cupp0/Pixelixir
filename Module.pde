public class Module implements OperatorListener{
  
  String id = UUID.randomUUID().toString();
  String name, label; 
  Operator owner;
  ArrayList<ModuleUI> uiBits = new ArrayList<>();     //holds all every display element
  
  ArrayList<InPortUI> ins = new ArrayList<>();        //keeping these as well for cleanliness
  ArrayList<OutPortUI> outs = new ArrayList<>();  
  
  boolean isFocus;
  
  Module(String name_){ 
    name = name_; label = name; initializeUI();
  }
  
  void setOwner(Operator op){
    owner = op;
  }
  
  //when the owner of this module adds/removes a pork, we need to add a port
  void onPorkAdded(Pork p){
    if (p instanceof InPork){
      addInPort(p);
    } else {
      addOutPort(p);
    }
    
    organizeUI();
  }
  
  void onPorkRemoved(Pork p){
  }
  
  void addInPort(Pork p){
    InPortUI in = (InPortUI)partsFactory.createUI("inPort");
    in.setIndex(ins.size());
    addUI(in);        
    getWindow().addPortToMap(in);
  }
  
  void addOutPort(Pork p){
    OutPortUI out = (OutPortUI)partsFactory.createUI("outPort");
    out.setIndex(outs.size());
    addUI(out);        
    getWindow().addPortToMap(out);
  }
  
  //the window this module is visible in
  Window getWindow(){
    return windows.get(this.owner.parent);
  }
  
  Window getParentWindow(){
    if (this.owner.parent.parent != null){
      return windows.get(this.owner.parent.parent);
    }
    else{ return null; }
  }
  
  Module getParentModule(){
    if (this.owner.parent != null){
      return ((Module)this.owner.parent.listener);
    }
    return null;
  }
  
  String getId(){
    return id;
  }
  
  ModuleUI addUI(ModuleUI ui){
    ui.setParent(this);
    uiBits.add(ui);   
    
    if (ui instanceof InPortUI){ ins.add((InPortUI)ui); }
    if (ui instanceof OutPortUI){ outs.add((OutPortUI)ui); }

    return ui;
  }
  
  void removeUI(ModuleUI ui){    
    uiBits.remove(ui);    
  }
  
  //clean slate with fresh module body
  void initializeUI(){
    uiBits.clear();
    ins.clear();
    outs.clear();
    addUI((BodyUI)partsFactory.createUI("body"));
  }  
  
  //default method for ui layout. sizes the body, positions UI and ports
  //called any time UI is added or removed
  void organizeUI() {
    int spacing = 10; //the closest any two pieces of UI should be to eachother
    
    //mininumum mododule sizize
    int moduleWidth = (max(2, max(ins.size(), outs.size()))-1)*(portSize+portGap)+portSize;
    int moduleHeight = 2*portSize + portGap;
    
    // Group UIs by type
    HashMap<Class<?>, List<ModuleUI>> grouped = new HashMap<Class<?>, List<ModuleUI>>();    
    for (ModuleUI ui : uiBits) {
      Class<?> type = ui.getClass();
      grouped.putIfAbsent(type, new ArrayList<ModuleUI>());
      grouped.get(type).add(ui);
    }
  
    // Define UI positioning order 
    Class<?>[] UIOrder = new Class<?>[] {CompositeUI.class, SliderUI.class, TextfieldUI.class, ButtonUI.class, SwitchUI.class, DisplayUI.class };

    // Track layout cursor on both axes
    int x = spacing;
    int y = spacing;
    
    PVector currentLayout = new PVector(x, y);
    PVector lastChunkSize = new PVector(0, 0);
    
    boolean first = true;
    
    for (Class<?> type : UIOrder) {
      List<ModuleUI> group = grouped.get(type);
      if (group == null) continue;
      
      //if the module is wider than it is long, stack beneath previous list,
      //otherwise, to the right
      
      if (!first){
        if (moduleWidth > moduleHeight){
          x = (int)currentLayout.x;
          y = (int)currentLayout.y+(int)lastChunkSize.y + spacing;
        } else {
          x = (int)currentLayout.x + (int)lastChunkSize.x + spacing;
          y = (int)currentLayout.y;
        }
      }
      
      first = false;
      
      //if elements are wider than they are long, stack vertically, 
      //otherwise, horizontal
      
      float largestWidth = 0; float largestHeight = 0;
      for (ModuleUI ui : group) {
        largestWidth = max(largestWidth, ui.size.x);
        largestHeight = max(largestHeight, ui.size.y);
      }
      
      //store current layout position
      currentLayout.set(x, y);
      
      //eye always goes in the same spot
      if (group.get(0) instanceof CompositeUI){
        for (ModuleUI ui : group) {
          moduleWidth = max(moduleWidth, x+(int)ui.size.x+spacing);
          moduleHeight = max(moduleHeight, y+(int)ui.size.y+spacing);
          ui.state.pos = new PVector(x, y);
          y += ui.size.y + spacing;
          lastChunkSize.set(ui.size.x, ui.size.y);
        }
        currentLayout.set(spacing, spacing);
      } else {
      
        // Stack vertically
        if (largestWidth > largestHeight){
          for (ModuleUI ui : group) {
            moduleWidth = max(moduleWidth, x+(int)ui.size.x+spacing);
            moduleHeight = max(moduleHeight, y+(int)ui.size.y+spacing);
            ui.state.pos = new PVector(x, y);
            y += ui.size.y + spacing;
          }
          lastChunkSize.set(largestWidth, y - spacing - currentLayout.y);
        } 
        
        //horizontal
        else {
          for (ModuleUI ui : group) {
            moduleWidth = max(moduleWidth, x+(int)ui.size.x+spacing);
            moduleHeight = max(moduleHeight, y+(int)ui.size.y+spacing);
            ui.state.pos = new PVector(x, y);
            x += ui.size.x + spacing;
          }
          lastChunkSize.set(x - spacing - currentLayout.x, largestHeight);
        }
      }
    }
    
    ((BodyUI)uiBits.get(0)).buildRectangle(new PVector(moduleWidth, moduleHeight));
    
    //position ports and roundOver the correct corners
    float inportSpacing= (moduleWidth - portSize)/max(1, (float)(ins.size()-1));
    float outportSpacing= (moduleWidth - portSize)/max(1, (float)(outs.size()-1));
    for (InPortUI i : ins){ 
      i.state.pos.set(i.index*inportSpacing, 0);
      i.setCornerRadii(true); 
    } 
    for (OutPortUI o : outs){ 
      o.state.pos.set(o.index*outportSpacing, uiBits.get(0).size.y-portSize);
      o.setCornerRadii(false); 
    } 
  }

  boolean isEvaluating(){
    return owner.parent.evaluationSequence.contains(owner);
  }
  
  void display(){
  //display ports, sliders, buttons, etc.
    for (ModuleUI ui : uiBits){
      ui.applyStyle(getWindow().eventManager.styleResolver.resolve(ui));
      ui.display();
    }
    
    if (label != null && !(owner instanceof UIOperator)){
      displayLabel();
    }
  }
  
  void displayLabel(){
    fill(0);   
    textSize(10); 
    
    text(label, uiBits.get(0).state.pos.x+2, uiBits.get(0).state.pos.y+12); 
  }
  
  void drag(PVector dragAmount){
    uiBits.get(0).state.pos.add(dragAmount);
  }
  
  String getAddress(){
    return this.toString().substring(this.toString().indexOf('@'));
  }
  
  //returns the position of the module body
  PVector getBodyPosition(){
    if (uiBits.get(0) instanceof BodyUI){
      return uiBits.get(0).getAbsolutePosition();
    }
    return null;
  }
  
  void setBodyPosition(PVector p){
    if (uiBits.get(0) instanceof BodyUI){
      uiBits.get(0).setPosition(p);
    }
    
    getWindow().setCursor(PVector.add(p, new PVector(0, uiBits.get(0).size.y+16)));
  }

  color getColor(){
    for (int i = 0; i < UIText.length; i++){
      for (String s : UIText[i]){
        if (s.equals(name)){
          switch(i){
            case 0: 
            return UICol;
            
            case 1: 
            return binaryCol;
            
            case 2: 
            return unaryCol;
            
            case 3: 
            return logicCol;
            
            case 4: 
            return comparisonCol;

            case 5: 
            return utlityCol;

          }
        }
      }
    }
    return color(0);
  }

  //this is the bridge between UI and data
  void sendDataToOperator(UIPayload p){
    ((UIOperator)owner).onPayloadChange(p); 
  }
   
}
