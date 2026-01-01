//~Animation
abstract class Animation{
  
  int time;
  
  Animation(){
    time = 0;
  }
  
  abstract void display(PVector where);

}

//~ConnectionLine
class ConnectionLine extends Animation{
  
  OutPortUI anchor;
  
  ConnectionLine(OutPortUI anchor_){
    anchor = anchor_;
  }
  
  void display(PVector where){
    PVector anchorPos = anchor.getAbsolutePosition().copy().add(portSize/2, portSize);
    PVector dir = PVector.sub(where, anchorPos);
    float dist = dir.mag();
    dir.normalize();
    
    
    float spacing = 10;   // distance between dots
    float speed = 1;      // animation speed
    float offset = (frameCount * speed) % spacing;
    
    strokeWeight(3);
    stroke(0);
    noFill();
    
    // draw the flowing dots
    for (float d = offset; d < dist; d += spacing) {
      PVector pos = PVector.add(anchorPos, PVector.mult(dir, d));
      ellipse(pos.x, pos.y, 2, 2);
    }
  }

}

//~SelectionRectangle
class SelectionRectangle extends Animation{
  
  PVector anchor;
  
  SelectionRectangle(PVector anchor_){
    anchor = anchor_.copy();
  }
  
  void display(PVector where){
    strokeWeight(2/currentWindow.cam.scl);
    stroke(0);    
    noFill();
    rect(anchor.x, anchor.y, where.x-anchor.x, where.y-anchor.y);
  }

}
