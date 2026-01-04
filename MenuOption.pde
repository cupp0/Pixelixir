//~MenuOption
abstract class MenuOption implements Hoverable{
  
  Menu parent;
  String label;
  PVector pos, size;
  int index;

  MenuOption(Menu parent_, String label_, int index_) {
    parent = parent_; label = label_; index = index_; size = parent.optionSize.copy();setPosition(new PVector(0, index*size.y));
  }
  
  void display(){
    PVector p = getAbsolutePosition();    
    applyStyle(parent.getWindow().eventManager.styleResolver.resolve(this));
    rect(p.x, p.y, size.x, size.y, 4);
    
    
    fill(255);
    textSize(12);
    text(label, p.x+3, p.y+14);
  }
  
  void applyStyle(Style s){
    fill(s.fill);
    stroke(s.stroke);
    strokeWeight(s.strokeWeight);
  }
  
  PVector getAbsolutePosition(){
    return PVector.add(parent.pos.copy(), this.pos);
  }

  abstract void execute();
  
  HoverTarget hitTest(float x, float y){
    return isHovered(x, y)
      ? new HoverTarget(this)
      : new HoverTarget();
  }
  
  Style getStyle(){
    return new Style(color(30, 40, 50), color(15, 25, 35), 0);  
  }
  
  boolean isHovered(float x, float y){
    return isInside(new PVector(x, y), getAbsolutePosition(), PVector.add(getAbsolutePosition(), size));
  }
  
  void setPosition(PVector pos_){
    pos = pos_.copy(); 
  }
   
}
