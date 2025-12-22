//~BodyUI
public class BodyUI extends ModuleUI<BodyUIState>{
  
  float radius = 5;       //roundover on corners
  
  BodyUI(){
    super();
    name = "body";
  }

  void display(){
    shape(shape, state.pos.x, state.pos.y);
  }
  
  //returns index of new corner
  int addCorner(){
    //cornerPoints.add(getEdgeIndex(), new CornerPoint(PVector.sub(currentWindow.cam.wMouse, state.pos), this));
    //updateShape();
    //return getEdgeIndex();
    return 1;
  }
  
  int getEdgeIndex() {
    int closestIndex = -1;
    float closestDist = Float.MAX_VALUE;
  
    int count = cornerPoints.size();
    for (int i = 0; i < count; i++) {
      PVector a = PVector.add(state.pos, cornerPoints.get(i).pos);
      PVector b = PVector.add(state.pos, cornerPoints.get((i+1) % count).pos); // wrap for closed shape
  
      //float d = distToSegment(currentWindow.cam.wMouse.x, currentWindow.cam.wMouse.y, a.x, a.y, b.x, b.y);
      //if (d < 5 && d < closestDist) {
      //  closestDist = d;
      //  closestIndex = i+1; 
      //}
    }
    return closestIndex;
  }
  
  int cornerHovered(){
    int which = -1;
    for (int i = 0; i < cornerPoints.size(); i++){
      //if (cornerPoints.get(i).isHovered()){ return i; }
    }
    return which;
  }
  
  //just checks if mouse is inside the UI element
  @Override
  boolean isBodyHovered(float x, float y){
    // Invert the transform to get the mouse position in shape space
    PMatrix2D mat = new PMatrix2D();
    mat.invert();
  
    PVector m = mat.mult(PVector.sub(new PVector(x, y), state.pos), null); //don't know why this works
    boolean hovered = false;
    int n = cornerPoints.size();
    for (int i = 0, j = n - 1; i < n; j = i++) {
      PVector vi = cornerPoints.get(i).pos;
      PVector vj = cornerPoints.get(j).pos;
      if (((vi.y > m.y) != (vj.y > m.y)) &&
          (m.x < (vj.x - vi.x) * (m.y - vi.y) / (vj.y - vi.y) + vi.x)) {
        hovered = !hovered;
      }
    }
    
    return hovered;    
  }
    
}
