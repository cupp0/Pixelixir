//~Connection


enum ConnectionStyle {CABLE, DOTS}

//spring physics for connection animation
class Connection implements Hoverable{
  
  final PortUI source;
  final PortUI destination;
  ConnectionStyle connectionStyle;
  
  PVector[] pos = new PVector[4];       //anchor points
  PVector[] prev = new PVector[4];      //previous anchors
  PVector[] acc = new PVector[4];       //holds accel vals for spring animation
    
  Style style;  
    
  float restLength;               
  float stiffness;                      // spring strength
  float damping;                        // slows down motion
  PVector gravity;

  Connection(PortUI source_, PortUI destination_, DataStatus ds){
    source = source_; destination = destination_;
    if (ds == DataStatus.CONTINUATION){ connectionStyle = ConnectionStyle.CABLE; }
    if (ds == DataStatus.OBSERVATION){ connectionStyle = ConnectionStyle.DOTS; }

    PVector sPos = source.getAbsolutePosition().copy().add(4, 8);
    PVector dPos = destination.getAbsolutePosition().copy().add(4, 0);
    stiffness = 0.5+random(100)/1000;                
    damping = 0.75+random(100)/1000;                 
    gravity = new PVector(0, 0.8+random(100)/1000);
    // Initialize rope straight across
    for (int i = 0; i < 4; i++) {
      pos[i] = sPos.copy().lerp(dPos, i/3);
      prev[i] = pos[i].copy();
      acc[i] = new PVector();
    }
    restLength = vecDistance(pos[0], pos[3])/10; // each segment natural length
    computeAnchorPoints();
    setStyle(source.getStyle());
  }
  
  void setStyle(Style s){
    style = s;
    style.fill = color(0);
  }
  
  Style getStyle(){
    return style;
  }
  
  void display(){
    
    applyStyle(source.parent.getWindow().eventManager.styleResolver.resolve(this));

    if (connectionStyle == ConnectionStyle.CABLE){
      displayCable();
    }

    if (connectionStyle == ConnectionStyle.DOTS){
      displayDots(); 
    }
    
  }
  
  void displayCable(){

    //update pos if we are jiggly
    if (!source.getAbsolutePosition().equals(pos[0]) || 
        !destination.getAbsolutePosition().equals(pos[3]) ||
        vecDistance(pos[1], prev[1]) > .1){
        computeAnchorPoints();
    } 
      
    bezier(pos[0].x, pos[0].y, pos[1].x, pos[1].y, pos[2].x, pos[2].y, pos[3].x, pos[3].y); 
  }
  
  void displayDots(){
    PVector start = source.getAbsolutePosition().copy().add(4, 8);
    PVector dir = PVector.sub(destination.getAbsolutePosition().copy().add(4, 8), start);
    float dist = dir.mag();
    dir.normalize();
    PVector offsetVector = dir.copy().mult(5);
    
    float spacing = 10;   // distance between dots
    float speed = 1;      // animation speed
    float offset = (frameCount * speed) % spacing;

    // draw the flowing lines
    for (float d = offset; d < dist-spacing; d += spacing) {
      PVector pos = PVector.add(start, PVector.mult(dir, d));
      PVector pos2 = PVector.add(pos, offsetVector);
      line(pos.x, pos.y, pos2.x, pos2.y);
    }
  }

  void applyStyle(Style s){
    if (s.fill == color(0)){
      noFill();
    } else {
      fill(s.fill);
    }
    stroke(s.stroke);
    strokeWeight(s.strokeWeight);
  }
  
  void computeAnchorPoints(){
    prev[0] = pos[0].copy();
    pos[0] = source.getAbsolutePosition().copy().add(4, 8);
    prev[3] = pos[3].copy();
    pos[3] = destination.getAbsolutePosition().copy().add(4, 0);
    restLength = vecDistance(pos[0], pos[3])/7; 
    
    // Reset accelerations    
    for (int i = 0; i < 4; i++) {
      acc[i].set(0, 0);
    }
  
    // Apply gravity to interior points
    for (int i = 1; i < 3; i++) {
      acc[i].add(gravity);
    }
  
    // Apply spring forces between neighbors
    for (int i = 0; i < 3; i++) {
      applySpring(i, i+1);
    }
  
    // Verlet integration (skip anchors)
    for (int i = 1; i < 3; i++) {
      PVector temp = pos[i].copy();
      PVector vel = PVector.sub(pos[i], prev[i]);
      vel.mult(damping);
      pos[i].add(vel);
      pos[i].add(acc[i]);
      prev[i] = temp;
    } 
  }
  
  void applySpring(int i, int j) {
    PVector delta = PVector.sub(pos[j], pos[i]);
    float dist = delta.mag();
    if (dist == 0) return;
    float diff = dist - restLength;
    delta.normalize();
    PVector force = PVector.mult(delta, stiffness * diff);
  
    // Apply to each mass if not an anchor
    if (i != 0 && i != 3) acc[i].add(force);
    if (j != 0 && j != 3) acc[j].sub(force);
  }
  
  HoverTarget hitTest(float x, float y) {
    return isHovered(x, y)
      ? new HoverTarget(this)
      : new HoverTarget();
  }
  
  //check if any segment between each anchors is hovered
  boolean isHovered(float x, float y) {
    
    for (int i = 0; i < pos.length-1; i++){
      if (isInside(new PVector(x, y), pos[i], pos[i+1])){
        if (distToSegment(x, y, pos[i].x, pos[i].y, pos[i+1].x, pos[i+1].y) < 4) {
          return true;
        }
      }
    }
    
    return false;
  }

  float distToSegment(float px, float py, float x1, float y1, float x2, float y2) {
    float vx = x2 - x1;
    float vy = y2 - y1;
    float wx = px - x1;
    float wy = py - y1;
  
    float c1 = vx*wx + vy*wy;
    if (c1 <= 0) return dist(px, py, x1, y1);
  
    float c2 = vx*vx + vy*vy;
    if (c2 <= c1) return dist(px, py, x2, y2);
  
    float b = c1 / c2;
    float bx = x1 + b*vx;
    float by = y1 + b*vy;
    return dist(px, py, bx, by);
  }
}
