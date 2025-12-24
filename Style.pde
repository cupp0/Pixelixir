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
        modifiedStyle.stroke = addColor(modifiedStyle.stroke, color(30));
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
  
  color setTransparency(color c, float alpha){
    return color(red(c), green(c), blue(c), alpha);
  }
  
  color getBoolFill(Pork p){
    if (p instanceof OutPork){
      return boolCol(p.data.getBoolValue());
    } else {
      if (((OutPork)((InPork)p).getSource()) != null){
        return boolCol(((OutPork)((InPork)p).getSource()).data.getBoolValue());
      }
    }
    return color(50);
  }
  
  color boolCol(boolean b){
    return (b ? color(200) : color(50));
  }
  
  color getUnknownColor(){
    return noiseGen.getColor();
  }
  
  color getConnectionColorByPork(Pork p){
    color c = 0;
    switch (p.data.getType()) {
      case FLOAT : c = color(200, 150, 100); break;
      case BOOL : c = getBoolFill(p); break;
      case TEXT : c = color(100, 200, 150); break;
      case LIST : c = color(100, 150, 200); break;
      case UNKNOWN : c = getUnknownColor(); break;
    } 
    int framesSinceEval = frameCount - p.owner.lastEval;
    if (framesSinceEval < 10){
      c = addColor(c, color((10-framesSinceEval) * 7));
    }
    return c;
  }
  
  color getColorByPork(Pork p){
    if (p.speaking){
      return color(0, 200, 200);
    }
    
    switch (p.data.getType()) {
      case FLOAT : return color(200, 150, 100);
      case BOOL : return getBoolFill(p);
      case TEXT : return color(100, 200, 150);
      case LIST : return color(100, 150, 200);
      case UNKNOWN : return getUnknownColor();
      default : return color(0);
    } 
  }
  
  color getStrokeByPork(Pork p){

    if (p.currentStatus != null){
      switch (p.currentStatus) {
        case CONTINUATION: return 0;
        case OBSERVATION: return getColorByPork(p);
      } 
    } else {
      if (p.allowsStatus(DataStatus.CONTINUATION) && !(p.allowsStatus(DataStatus.OBSERVATION))){
        return color(0);
      } else {
        return addColor(getColorByPork(p), color(30));
      }
    }
    
    return color(0);
  }
}
