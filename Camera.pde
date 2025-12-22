//~Camera
class Camera {
  
  Window view;
  
  float xOff, yOff, scl;                          // current offsets
  float targetXOff, targetYOff, targetScl;        //for easing zoom

  float zoomSpeed = 0.25;  // how fast we ease toward targets
  float zoomFactor = 1.5;

  float maxScl = 200;
  float minScl = .05;
  
  PVector wMouse = new PVector();
  
  Camera(Window view_) {
    view = view_;
    xOff = yOff = targetXOff = targetYOff = 0;
    scl = targetScl = 1;
  }

  // call in draw()
  void update() {
    scl += (targetScl - scl) * zoomSpeed;
    xOff += (targetXOff - xOff) * zoomSpeed;
    yOff += (targetYOff - yOff) * zoomSpeed;
    wMouse = toWorld(new PVector (mouseX, mouseY)).copy();
  }

  // handle mouse wheel events
  void zoom(float delta) {
    if (delta == 0) return;
        
    float factor = delta > 0 ? zoomFactor : 1.0 / zoomFactor;

    targetXOff -= mouseX;
    targetYOff -= mouseY;
    targetXOff *= factor;
    targetYOff *= factor;
    targetXOff += mouseX;
    targetYOff += mouseY;

    targetScl *= factor;
  }
    
  // center the average module position of the viewing window where the mouse is and set zoom far away
  void setCamOnCompositeZoom() {
    PVector avgModPos = view.avgModPos().copy();
    targetScl = minScl;
    targetXOff = mouseX - minScl * avgModPos.x;
    targetYOff = mouseY - minScl * avgModPos.y;

    // snap immediately
    scl = targetScl;
    xOff = targetXOff;
    yOff = targetYOff;
  }
  
  public PVector toWorld(PVector screen){
    return screen.sub(xOff, yOff).div(scl);
  }

  public float toWorldX(int screen){
    return ((float)screen-xOff)/scl;
  }
  
  public float toWorldY(int screen){
    return ((float)screen-yOff)/scl;
  }

  public PVector toScreen(PVector world){
    return world.mult(scl).add(xOff, yOff);
  }
  
  public void pan(PVector amount){
    targetXOff += amount.x*scl;
    targetYOff += amount.y*scl;
  }
  
  public void setPan(PVector where){
    targetXOff = where.x;
    targetYOff = where.y;
  }
  
  public void setZoom(float where){
    targetScl = where;
  }
  
  public void resetCam(){
    setPan(view.avgModPos());
    setZoom(1);
  }
  
}
