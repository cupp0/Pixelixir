//~Style
class Style {
  color fill, stroke;
  float strokeWeight;
  
  Style(color fill_, color stroke_, float strokeWeight_){
    fill = fill_; stroke = stroke_; strokeWeight = strokeWeight_;
  }
  
  Style copyStyle(){
    return new Style(fill, stroke, strokeWeight);
  }
}

//Who should own styleresolver?

//~StyleResolver
class StyleResolver {
  
  //who it's resolving styles for.
  EventManager eventManager;
  
  StyleResolver(EventManager eventManager_){
    eventManager = eventManager_;  
  }
  
  Style resolve(Hoverable ui) {
    
    Window w = eventManager.scope;
    HoverTarget currentHover = w.windowManager.hoverManager.getCurrent();
    Style modifiedStyle = ui.getStyle().copyStyle();
    
    //color connections
    if (ui instanceof Connection){
      modifiedStyle.fill = color(0);
      Pork carriedData = w.portMap.getPork(((Connection)ui).source);
      modifiedStyle.stroke = getConnectionColorByPork(carriedData);
      if (ui == currentHover.connection){
        modifiedStyle.strokeWeight++;
        modifiedStyle.stroke = addColor(modifiedStyle.stroke, color(25));
      }
    }
    
    //color ports
    if (ui instanceof PortUI){      
      modifiedStyle.fill = getColorByPork(w.portMap.getPork((PortUI) ui));
      modifiedStyle.stroke = getStrokeByPork(w.portMap.getPork((PortUI) ui));
    }
    
    //if module is selected, change module body appearance
    if (ui instanceof ModuleUI){
      if (ui == currentHover.modUI){
        modifiedStyle.stroke = addColor(modifiedStyle.stroke, color(25));
        modifiedStyle.fill = addColor(modifiedStyle.fill, color(25));
        if (eventManager.is(InteractionState.HOLDING_BUTTON)){
          modifiedStyle.fill = addColor(modifiedStyle.fill, color(50));
        }
      }
      
      if (selectionManager.modules.contains(((ModuleUI)ui).parent)){
        modifiedStyle.fill = addColor(modifiedStyle.fill, color(50));
        modifiedStyle.stroke = addColor(modifiedStyle.stroke, color(75));
        modifiedStyle.strokeWeight = (modifiedStyle.strokeWeight+1); 
        if (eventManager.is(InteractionState.DRAGGING_MODULES)){
          modifiedStyle.fill = setTransparency(modifiedStyle.fill, 127);
          modifiedStyle.stroke = setTransparency(modifiedStyle.stroke, 127);
        }
      }
      if (ui == eventManager.focusedUI){
        modifiedStyle.strokeWeight++;
      }

    }
    
    if (ui instanceof BodyUI){
      modifiedStyle.strokeWeight = modifiedStyle.strokeWeight*currentWindow.cam.scl;
    }
    
    if (ui instanceof MenuOption){
      if (ui == currentHover.menuOption){
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
  
  color getConnectionColorByPork(Pork p){
    color c = 0;
    if (p.targetFlow != null){
      c = getDataTypeColor(p.targetFlow.getType());
    }
    else {
      c = getDataTypeColor(p.getCurrentDataCategory());
    }
    int framesSinceEval = frameCount - ((OutPork)p).lastEval;
    if (framesSinceEval < 10){
      c = addColor(c, color((10-framesSinceEval) * 12));
    }
    return c;
  }
  
  color getColorByPork(Pork p){
    switch (p.getCurrentDataCategory()) {
      case BOOL : return getBoolFill(p);
      default : return getDataTypeColor(p.getCurrentDataCategory());
    } 
  }
  
  color getDataTypeColor(DataCategory dc){
    switch (dc) {
      case FLOAT : return color(175, 125, 75);
      case TEXT : return color(75, 175, 125);
      case LIST : return color(75, 125, 175);
      case MODULE : return color(175, 75, 125);
      case UNKNOWN : return getUnknownColor();
      default : return color(0);
    } 
  }
  
  color getStrokeByPork(Pork p){
    if (p.getCurrentAccess() == null){
      return color(0);
    }
    switch(p.getCurrentAccess()){
      case READ : return addColor(color(30), getDataTypeColor(p.getCurrentDataCategory()));      
      case READWRITE : return getDataTypeColor(p.getCurrentDataCategory());      
      default : return color(0);
    }
  }
}
