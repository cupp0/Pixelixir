//~DisplayUI
class DisplayUI extends DBUI{
  
  DisplayUI(){
    super();
    name = "display";
    Style s = new Style(color(0, 255), color(0), 3);
    applyStyle(s);
  } 
  
  void display(){ 
    if (state.getData() != null){
      PImage img = state.getData().getImgValue();
      if (img != null){
        if (img.width != this.size.x || img.height != this.size.y){
          setSize(new PVector(img.width, img.height));
          parent.organizeUI();
        }
  
        strokeWeight(2);
        rect(getAbsolutePosition().x, getAbsolutePosition().y, size.x, size.y, 4);
        image(img, getAbsolutePosition().x, getAbsolutePosition().y);    
  
      }
      
      displayIdentity();
    }
  }
  
  void onInteraction(HumanEvent e){}
  
}
