boolean isInside(PVector p, PVector p1, PVector p2){

  if (p1.y-2 <= p.y){
    if (p.y <= p2.y+2){
    } else{
      return false;
    }      
  }else if(p.y >= p2.y-2){
  } else {
    return false;
  }
  if (p1.x-2 <= p.x){
    if (p.x <= p2.x+2){
    } else{
      return false;
    }      
  }else if(p.x >= p2.x-2){
  } else {
    return false;
  }
  return true;
}

PVector rotatePV(PVector point, PVector axis, float angle){
  float s = sin(angle);
  float c = cos(angle);
  point.x -= axis.x;
  point.y -= axis.y;
  float xnew = point.x * c - point.y * s;
  float ynew = point.x * s + point.y * c;
  point.x = xnew + axis.x;
  point.y = ynew + axis.y;
  return point;
}

float distanceFromLine(PVector A, PVector B, PVector C) {
    float numerator = Math.abs((B.x - A.x) * (A.y - C.y) - (A.x - C.x) * (B.y - A.y));
    float denominator = (float)Math.sqrt(Math.pow(B.x - A.x, 2) + Math.pow(B.y - A.y, 2));
    return numerator / denominator;
}

//returns the sum of the differences between components of the vector 
float vecDistance(PVector p1, PVector p2){
  PVector diff = PVector.sub(p1, p2);
  diff.set(abs(diff.x), abs(diff.y), abs(diff.z));
  return (diff.x+diff.y+diff.z);
}

float colorDistance(color c1, color c2){
  return abs((c1 >> 16) & 0xFF - (c2 >> 16) & 0xFF)+abs((c1 >> 8) & 0xFF - (c2 >> 8) & 0xFF)+abs((c1 & 0xFF) - (c2 & 0xFF));
}

// Distance from point to segment
float distToSegment(float px, float py, float x1, float y1, float x2, float y2) {
  float vx = x2 - x1;
  float vy = y2 - y1;
  float wx = px - x1;
  float wy = py - y1;

  float c1 = vx * wx + vy * wy;
  if (c1 <= 0) return dist(px, py, x1, y1);
  float c2 = vx * vx + vy * vy;
  if (c2 <= c1) return dist(px, py, x2, y2);
  float b = c1 / c2;
  float bx = x1 + b * vx;
  float by = y1 + b * vy;
  return dist(px, py, bx, by);
}

color hoveredColor(color c){
  return color(red(c)+55, green(c)+55, blue(c)+55);
}

float[] roundIsosceles(PVector p1, PVector p2, PVector p3, float t) {
  float mt = 1-t,
  c1x = (mt*p1.x + t*p2.x),
  c1y = (mt*p1.y + t*p2.y),
  c2x = (mt*p3.x + t*p2.x),  
  c2y = (mt*p3.y + t*p2.y);
  return new float[]{ c1x, c1y, c2x, c2y };
}

ArrayList<PVector> convertToClosed(ArrayList<PVector> points, float radius) {
  // this value *actually* depends on the angle between the lines.
  // a 180 degree angle means f can be 1, a 10 degree angle needs
  // an f closer to 4!
  ArrayList<PVector> closed = new ArrayList<PVector>();
  PVector p1,p2,p3,p2l,p2r;
  float dx1, dy1, dx2, dy2, m;
  for(int i=0, last=points.size(); i<last; i++) { // >
    p1 = points.get(i);
    p2 = points.get((i+1)%last);
    p3 = points.get((i+2)%last);

    dx1 = p2.x - p1.x;
    dy1 = p2.y - p1.y;
    m = sqrt(dx1*dx1+dy1*dy1);
    p2l = new PVector(p2.x-radius*dx1/m, p2.y-radius*dy1/m);

    dx2 = p3.x-p2.x;
    dy2 = p3.y-p2.y;
    m = sqrt(dx2*dx2+dy2*dy2);
    p2r = new PVector(p2.x+radius*dx2/m, p2.y+radius*dy2/m);

    closed.add(p2l);
    closed.add(p2);
    closed.add(p2r);
  }
  return closed;
}

void p(){println("come on");}
void q(){println("work it baby");}
void r(){println("you can do it");}
void s(){println("make it through it");}

PApplet sketchRef(){
  return this;
}
