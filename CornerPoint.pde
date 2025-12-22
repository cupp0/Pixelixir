//~CornerPoint
//for reshaping modules eventually. Not well implemented.
class CornerPoint{
  
  ModuleUI owner;
  PVector pos;
  boolean dragging;
  int index;
  
  CornerPoint(PVector pos_, ModuleUI owner_){
    pos = pos_.copy(); owner = owner_; setIndex(owner.cornerPoints.size());
  }  
  
  void setIndex(int i){
    index = i;
  }
  
  void drag(PVector amount){
    pos.add(amount);
  }
  
  boolean isHovered(int x, int y){
    return vecDistance(pos, new PVector(x, y)) < 5;
  }
  
  void display(){
    circle(getAbsolutePosition().x, getAbsolutePosition().y, 8);
  }
  
  PVector getAbsolutePosition(){
    return PVector.add(pos, owner.getAbsolutePosition());
  }
  
}
