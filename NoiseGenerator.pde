class NoiseGenerator{
  
  OpenSimplexNoise gen = new OpenSimplexNoise();
  
  float nx = 0;
  float ny = 10000;
  float nz = 20000;
  
  // speed of meander
  float speed = 0.12;
  
  color c;
  
  NoiseGenerator(){
  }
  
  color getColor(){
    return c;
  }
  
  void stepColor(){
    // advance the noise position
    nx += speed;
    ny += speed;
    nz += speed;
    
    // sample noise
    double r = gen.eval(nx, 0, 0); // returns -1 to 1
    double g = gen.eval(ny, 0, 0); // returns -1 to 1
    double b = gen.eval(nz, 0, 0); // returns -1 to 1
    
    float rr = map((float)r, -1, 1, 50, 200);
    float gg = map((float)g, -1, 1, 50, 200);
    float bb = map((float)b, -1, 1, 50, 200);
    
    c = color(rr, gg, bb);
  }
}
