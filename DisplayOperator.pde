class DisplayOperator extends UIOperator{
  
  DataBender dataListener;
  
  DisplayOperator(){
    super();
    name = "display"; uiPayload = new UIPayload(new PImage());
  }  

  void initialize(){
    addInPork(DataCategory.FLOAT);addInPork(DataCategory.FLOAT);addInPork(DataCategory.LIST);
  }
  
  void setDataListener(DataBender dl){
    dataListener = dl;
  }
  
  //temporary input validation til we have a dedicated image buffer type
  //wants a list of floats, and floats for width and height
  boolean isInputValid(){
    
    int w = (int)inFlows.get(0).getFloatValue();
    int h = (int)inFlows.get(1).getFloatValue();    
    List<Flow> buffer = inFlows.get(2).getListValue();
    
    for (Flow f : buffer){
      if (f.getType() != DataCategory.FLOAT){
        return false;
      }
    }
    
    if (w * h != buffer.size()){
      return false; 
    }
    
    return true;
  }
  
  void execute(){    
    dataListener.onDataChange(this);   
  }
        
}