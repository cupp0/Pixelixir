class IteratorOperator extends PrimeOperator implements GraphListener{
  
  Graph subgraph;
  
  IteratorOperator(){
    super();
    name = "iterator";
  }
  
  void initialize(){
    addInPork(DataType.NUMERIC); 
    addOutPork(DataType.NUMERIC).setTargetFlow(new Flow(DataType.NUMERIC)); 
    graph.addListener(this);
  }
  
  void onGraphChange(){
    subgraph = graph.getSubgraph(this);
  }
  
  void execute(){    
    int loops = constrain((int)ins.get(0).targetFlow.getFloatValue(), 1, 30);
    subgraph.addUpdater(outs.get(0));
    subgraph.generateEvaluationSequence();
    println(subgraph.evaluationSequence);
        
    for (int i = 0; i < loops-1; i++){
      outs.get(0).targetFlow.setFloatValue((float)i); 
      outs.get(0).setDataStatus(DataStatus.HOT);
      subgraph.evaluate();     
    }
    
    outs.get(0).targetFlow.setFloatValue(loops-1);
  }
  
}
