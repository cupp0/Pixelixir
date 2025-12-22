//~CompositeUI
class CompositeUI extends ModuleUI<CompositeUIState>{
    
  float irisR = 9;     // iris radius
  float pupilR = 6;    // pupil radius
  
  CompositeUI(){
    super();
    name = "eye"; setSize(new PVector(12, 12));
  } 
  
  boolean isHovered(){
    return (vecDistance(currentWindow.cam.wMouse, getAbsolutePosition().copy().add(size.x/2, size.y/2)) < irisR);
  }
  
  void display(){   
    // --- Sclera (white of the eye) ---
    noStroke();
    fill(255);
    ellipse(getAbsolutePosition().x+size.x/2, getAbsolutePosition().y+size.y/2, size.x*2, size.y*2);
  
    // --- Iris and pupil follow the mouse ---
    float dx = (currentWindow.cam.wMouse.x - getAbsolutePosition().x-size.x/2);
    float dy = (currentWindow.cam.wMouse.y - getAbsolutePosition().y-size.y/2);
    float angle = atan2(dy, dx);
    float distMax = size.x*1.1; // how far iris can move inside sclera
    float d = min(dist(dx, dy, 0, 0), distMax);
    float irisX = cos(angle) * d * 0.25; // scale motion for smoothness
    float irisY = sin(angle) * d * 0.25;
    float pupilX = cos(angle) * d * 0.4; // scale motion for smoothness
    float pupilY = sin(angle) * d * 0.4;
  
    if (isHovered()){
      PVector jitter = new PVector(random(12), random(12)).div(12).sub(.5, .5);
      irisX += jitter.x;
      irisY += jitter.y;
      pupilX += jitter.x;
      pupilY += jitter.y;
    }
    
    // --- Iris ---
    fill(hoveredColor(style.fill));
    ellipse(getAbsolutePosition().x+irisX+size.x/2, getAbsolutePosition().y+irisY+size.y/2, irisR*2, irisR*2);
  
    // --- Pupil ---
    fill(style.fill);
    ellipse(getAbsolutePosition().x+pupilX+size.x/2, getAbsolutePosition().y+pupilY+size.y/2, pupilR*2, pupilR*2);
  }


}
