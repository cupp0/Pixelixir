//~ModuleUI
abstract class ModuleUI<T extends UIState> extends BaseUI implements UIStateListener, Hoverable{
  
  protected T state;                                        //UI state object
  Module parent;                                            //the Module this piece of UI is owned by
  String id = UUID.randomUUID().toString();
  
  PVector size = new PVector();
  ArrayList<CornerPoint> cornerPoints = new ArrayList<>();
  float radius = 5;                                         //roundover on corners
  PShape shape;
    
  ModuleUI(){
    super();
    style = new Style(color(120), color(0), 2); //default style 
  }
  
  abstract void display();
  
  void drag(PVector dragAmount){    
    state.pos.add(dragAmount);
  }
    
  void applyStyle(Style s){
    fill(s.fill);
    stroke(s.stroke);
    strokeWeight(s.strokeWeight);
  }
  
  void setColor(color c){
    style.fill = c;
  }
   
  void setState(T state_){
    state = state_;
    state.setListener(this);
  }
  
  void setParent(Module m){
    parent = m;
  }
  
  void setPosition(PVector position){    
    state.pos.set(position);
  }
  
  //everything except for BodyUI uses Processing's rect() to display. BodyUI makes a PShape.
  //In both cases, we need to update CornerPoints
  void setSize(PVector size_){
    size.set(size_);
    cornerPoints.clear();
    cornerPoints.add(new CornerPoint(new PVector(0, 0), this));
    cornerPoints.add(new CornerPoint(new PVector(size.x, 0), this));
    cornerPoints.add(new CornerPoint(new PVector(size.x, size.y), this));
    cornerPoints.add(new CornerPoint(new PVector(0, size.y), this));
  }
  
  public T getState(){return state;} 
   
  //returns the world position of a UI element
  PVector getAbsolutePosition(){    
    if (this instanceof BodyUI){
      return state.pos;    
    }
    return PVector.add(state.pos, parent.getBodyPosition());
  }  
    
  void buildRectangle(PVector size_){
    setSize(size_);    
    updateShape();
  } 
  
  Window getWindow(){
    return parent.getWindow();
  }
  
  void updateShape(){
    ArrayList<PVector> pointList = new ArrayList<>();
    for (CornerPoint p : cornerPoints){
      pointList.add(p.pos);
    }
    ArrayList<PVector> closed = convertToClosed(pointList, radius);
    PVector p1,p2,p3;
    shape = createShape();
    shape.beginShape();
    for(int i=0, last=closed.size(); i<last; i+=3) { 
      p1 = closed.get(i);
      p2 = closed.get(i+1);
      p3 = closed.get(i+2);
      // rounded isosceles triangle connector values:
      float[] c = roundIsosceles(p1, p2, p3, 0.75);
      // tell Processing that we have points to add to our shape:
      shape.vertex(p1.x,p1.y);
      shape.bezierVertex(c[0], c[1], c[2], c[3], p3.x, p3.y);
    }
    shape.endShape(CLOSE);
    shape.disableStyle();
  }
  
  // ~ ~ ~ HOVER STUFF ~ ~ ~//  
  //checks if mouse is inside this piece of UI. default is a rectanlge. subclasses override
  boolean isBodyHovered(float x, float y){
    
    return isInside(new PVector(x, y), getAbsolutePosition(), PVector.add(getAbsolutePosition(), size));
  }
  
  //corners take precedence over edges take precedence over body
  HoverTarget hitTest(float x, float y) {  
    if (isCornerHovered(x, y) != null){
      return new HoverTarget(this, HoverType.CORNER, isCornerHovered(x, y).index);      
    }
    if (isEdgeHovered(x, y) != null){
      return new HoverTarget(this, HoverType.EDGE, isEdgeHovered(x, y).index);   
    }
    if (isBodyHovered(x, y)){
      return new HoverTarget(this, HoverType.BODY, -1);
    }
    return new HoverTarget();
  }
  
  //returns the lower index of the two CornerPoints that comprise the edge hovered
  //returns null if edge not hovered
  CornerPoint isEdgeHovered(float x, float y){
    int count = cornerPoints.size();
    for (int i = 0; i < count; i++) {
      
      //check bounding box made by two edge points
      PVector a = cornerPoints.get(i).getAbsolutePosition();
      PVector b = cornerPoints.get((i + 1) % count).getAbsolutePosition(); 
      if (isInside(new PVector(x, y), a, b)){
        
        //if inside, check if we are close to the line
        float d = distToSegment(x, y, a.x, a.y, b.x, b.y);
        if (d < 5){        
          return cornerPoints.get(i);
        }  
      }
    }
    
    return null;
  }
  
  //returns the hovered corner, null if none
  CornerPoint isCornerHovered(float x, float y){
    int count = cornerPoints.size();
    for (int i = 0; i < count; i++) {
      
      PVector a = cornerPoints.get(i).getAbsolutePosition(); 
      if (vecDistance(new PVector(x, y), a) < 5){        
        return cornerPoints.get(i);
      }  
    }
    
    return null;
  }
  
  void onUIPayloadChange(DBUIState s){
    if (parent.owner instanceof PrimeOperator){
      parent.sendDataToOperator(((DataBender)s).getData());
    }
  }
}
