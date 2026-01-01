class DisplayOperator extends UIOperator{
  
  DataBender dataListener;
  
  DisplayOperator(){
    super();
    name = "display"; uiPayload = new UIPayload(new PImage());
  }  

  void initialize(){
    addInPork(DataCategory.NUMERIC);addInPork(DataCategory.NUMERIC);addInPork(DataCategory.LIST);
  }
  
  void setDataListener(DataBender dl){
    dataListener = dl;
  }
  
  //temporary input validation til we have a dedicated image buffer type
  //wants a list of floats, and floats for width and height
  boolean isInputValid(){
    
    int w = (int)ins.get(0).targetFlow.getFloatValue();
    int h = (int)ins.get(1).targetFlow.getFloatValue();    
    List<Flow> buffer = ins.get(2).targetFlow.getListValue();
    
    for (Flow f : buffer){
      if (f.getType() != DataCategory.NUMERIC){
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
