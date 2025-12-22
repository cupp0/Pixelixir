class ReadOperator extends PrimeOperator{  
  
  String address = "";
  
  ReadOperator(){
    super();
    name = "read";  
  }
  
  void initialize(){
    addInPork(DataCategory.TEXT); addInPork(DataCategory.BOOL); addOutPork(DataCategory.UNKNOWN);
  }
  
  void execute(){
    String address = inFlows.get(0).getTextValue(); 
    Flow receivedData = flowRegistry.readFlow(address);
    
    //if nothing found at this address do nothing
    if (receivedData == null){ return; }    
    
    //else, copy the data to the output
    outs.get(0).data = receivedData.copyFlow();
  }
  
  boolean shouldExecute(){
    if (inFlows.get(1).getBoolValue()){
      return true;
    }
    
    return false;
  }
  
  boolean isSpeaker() { return true; }

}