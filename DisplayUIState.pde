//~DisplayUIState
class DisplayUIState extends DBUIState{
    
  transient PImage img = createImage(10, 10, ARGB);
  
  DisplayUIState() {
    super(); 
    setData(new UIPayload(new PImage()));
  }
  
  PImage getImg(){
    return img;
  }
  
  void onDataChange(Operator op){
    int w = (int)op.inFlows.get(0).getFloatValue();
    int h = (int)op.inFlows.get(1).getFloatValue();    
    List<Flow> buffer = op.inFlows.get(2).getListValue();
    
    if ((w != img.width || h != img.height) && (w > 0 && h > 0)){
      resizeImg(w, h);
    }
    
    img.loadPixels();    
    for (int i = 0; i < img.pixels.length; i++){
      if (buffer.size() > i){
        img.pixels[i] = color(buffer.get(i).getFloatValue());
      }
    } 
    img.updatePixels();
    
    onLocalEvent(new UIPayload(img));
  }
  
  void resizeImg(int x, int y){
    img.resize(x, y, ARGB);
    img.loadPixels();    
    for (int i = 0; i < img.pixels.length; i++){
      img.pixels[i] = color(random(255));
    } 
    img.updatePixels();
  }

  String getType(){ return "display"; }
}