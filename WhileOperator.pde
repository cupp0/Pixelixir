class WhileOperator extends PrimeOperator implements GraphListener{
  
  Graph subgraph;
  
  WhileOperator(){
    super();
    name = "while";
  }
  
  void initialize(){
    addInPork(DataType.TEXT); 
    addOutPork(DataType.BOOL).setTargetFlow(new Flow(DataType.BOOL)); 
    graph.addListener(this);
  }
  
  void onGraphChange(){
    subgraph = graph.getSubgraph(this);
  }
  
  void execute(){       
    //check registry for text value at input, if true, enter the loop
    Flow f = flowRegistry.readFlow(ins.get(0).targetFlow.getTextValue());
    if (f == null) return;
    if (f.getType() != DataType.BOOL) return;
    if (f.getBoolValue() != true){
      outs.get(0).targetFlow.setBoolValue(false);
      return;
    }
    
    subgraph.addUpdater(outs.get(0));
    subgraph.generateEvaluationSequence();
        
    while(f.getBoolValue()){
      //evaluate subgraph
      outs.get(0).targetFlow.setBoolValue(true); 
      outs.get(0).setDataStatus(DataStatus.HOT);
      subgraph.evaluate(); 
      
      //reread input condition
      f = flowRegistry.readFlow(ins.get(0).targetFlow.getTextValue());
      if (f == null) break;
      if (f.getType() != DataType.BOOL) break;
    }
    
    outs.get(0).targetFlow.setBoolValue(false);
  }
  
}
