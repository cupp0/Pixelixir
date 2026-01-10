//~Style
class Style {
  color fill, stroke;
  float strokeWeight;
  
  //for most UI
  Style(color fill_, color stroke_, float strokeWeight_){
    fill = fill_; stroke = stroke_; strokeWeight = strokeWeight_;
  }
  
  //for Windows
  Style(color fill_){
    fill = fill_;
  }
  
  Style copyStyle(){
    return new Style(fill, stroke, strokeWeight);
  }
  
  color getFill(){ return fill; }
  color getStroke(){ return stroke; }
  float getStrokeWeight(){ return strokeWeight; }
}

//should b static

//~StyleResolver
class StyleResolver {
  
  //who it's resolving styles for.
  Window scope;
  
  StyleResolver(Window scope_){
    scope = scope_;
  }
  
  Style resolve(Renderable ui) {
    
    //curent program state, and what we are currently hovering, for convenience
    StateMan currentState = scope.windowMan.stateMan;
    HoverTarget currentHover = currentState.hoverMan.currentHover;
    //base style we will be modifying
    Style modifiedStyle = ui.getStyle().copyStyle();
    
    //color connections
    if (ui instanceof Connection){
      modifiedStyle.fill = color(0);
      Pork carriedData = scope.portMap.getPork(((Connection)ui).source);
      modifiedStyle.stroke = getConnectionColorByPork(carriedData);
      if (ui == currentHover.getUI()){
        modifiedStyle.strokeWeight++;
        modifiedStyle.stroke = addColor(modifiedStyle.stroke, color(25));
      }
    }
    
    //color ports
    if (ui instanceof PortUI){      
      modifiedStyle.fill = getColorByPork(scope.portMap.getPork((PortUI) ui));
      modifiedStyle.stroke = getStrokeByPork(scope.portMap.getPork((PortUI) ui));
    }
    
    //if module is selected, change module body appearance
    if (ui instanceof ModuleUI){
      if (ui == currentHover.getUI()){
        modifiedStyle.stroke = addColor(modifiedStyle.stroke, color(25));
        modifiedStyle.fill = addColor(modifiedStyle.fill, color(25));
      }
      
      if (selectionMan.modules.contains(((ModuleUI)ui).parent)){
        modifiedStyle.fill = addColor(modifiedStyle.fill, color(70));
        modifiedStyle.stroke = addColor(modifiedStyle.stroke, color(75));
        modifiedStyle.strokeWeight = (modifiedStyle.strokeWeight+1); 
        if (currentState.interactionMan.state == InteractionState.DRAGGING_MODULES){
          modifiedStyle.fill = setTransparency(modifiedStyle.fill, 127);
          modifiedStyle.stroke = setTransparency(modifiedStyle.stroke, 127);
        }
      }
    }
    
    if (ui instanceof BodyUI){
      modifiedStyle.strokeWeight = modifiedStyle.strokeWeight*currentWindow.windowMan.stateMan.cam.scl;
    }
    
    if (ui instanceof MenuOption){
      if (ui == currentState.hoverMan.currentHover.getUI()){
        modifiedStyle.fill = addColor(modifiedStyle.fill, color(30));
      }
    }
    
    return modifiedStyle;
  }
  
  color addColor(color a, color b){
    return color(red(a)+red(b), green(a)+green(b), blue(a)+blue(b));
  }
  
  color subtractColor(color a, color b){
    return color(red(a)-red(b), green(a)-green(b), blue(a)-blue(b));
  }
  
  color setTransparency(color c, float alpha){
    return color(red(c), green(c), blue(c), alpha);
  }
  
  color getBoolFill(Pork p){
    if (p.targetFlow != null){
      return boolCol(p.targetFlow.getBoolValue());
    }
    return boolCol(false);
  }
  
  color boolCol(boolean b){
    return (b ? color(200) : color(50));
  }
  
  color getUnknownColor(){
    return noiseGen.getColor();
  }
  
  color getColorByLastEval(OutPork p){
    color c = 0;
    if (p.targetFlow != null){
      c = getDataTypeColor(p.targetFlow.getType());
    }
    else {
      c = getDataTypeColor(p.getCurrentDataType());
    }
    int framesSinceEval = frameCount - ((OutPork)p).lastEval;
    if (framesSinceEval < 10){
      c = addColor(c, color((10-framesSinceEval) * 12));
    }
    return c;
  }
  
  color getConnectionColorByPork(Pork p){
    color c = 0;
    if (p.getDataStatus() == DataStatus.BAD){
      return color(255, 0, 0);
    }
    if (p.targetFlow != null){
      c = getDataTypeColor(p.targetFlow.getType());
    }
    else {
      c = getDataTypeColor(p.getCurrentDataType());
    }
    int framesSinceEval = frameCount - ((OutPork)p).lastEval;
    if (framesSinceEval < 10){
      c = addColor(c, color((10-framesSinceEval) * 12));
    }
    return c;
  }
  
  color getColorByPork(Pork p){
    switch (p.getCurrentDataType()) {
      case BOOL : return getBoolFill(p);
      default : return getDataTypeColor(p.getCurrentDataType());
    } 
  }
  
  color getDataTypeColor(DataType dt){
    switch (dt) {
      case NUMERIC : return color(175, 125, 75);
      case TEXT : return color(75, 175, 125);
      case LIST : return color(75, 125, 175);
      case MODULE : return color(175, 75, 125);
      case WINDOW : return color(50, 75, 150);
      case PORT : return color(150, 175, 50);
      case UNDETERMINED : return getUnknownColor();
      default : return color(0);
    } 
  }
  
  color getColorByInputData(Operator op){
    if (op.ins.size() == 0) return color(0);
    if (!op.ins.get(0).isConnected()) return color(0);
    return getDataTypeColor(op.ins.get(0).getCurrentDataType());
  }
  
  color getStrokeByPork(Pork p){
    if (p.getCurrentAccess() == null) return color(0);
    return getDataTypeColor(p.getCurrentDataType()); 
  }
}
