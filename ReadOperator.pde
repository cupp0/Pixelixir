class ReadOperator extends PrimeOperator{  
  
  String address = "";
  
  ReadOperator(){
    super();
    name = "read";  
  }
  
  void initialize(){
    addInPork(DataCategory.TEXT); addOutPork(DataCategory.UNKNOWN);
  }
  
  void execute(){
    println("reading");
    String address = inFlows.get(0).getTextValue(); 
    Flow receivedData = flowRegistry.readFlow(address);
    
    //if nothing found at this address do nothing
    if (receivedData == null){ return; }    
    
    //else, copy the data to the output
    outs.get(0).data = receivedData.copyFlow();
  }
  
}
