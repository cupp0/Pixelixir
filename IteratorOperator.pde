class IteratorOperator extends PrimeOperator implements GraphListener{
  
  Graph subgraph;
  
  IteratorOperator(){
    super();
    name = "iterator"; setExecutionSemantics(ExecutionSemantics.MUTATES);
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
    int loops = constrain((int)ins.get(0).targetFlow.getFloatValue(), 0, 1000000);
    subgraph.addUpdater(outs.get(0));
    subgraph.generateEvaluationSequence();
        
    for (int i = 0; i < loops; i++){
      outs.get(0).targetFlow.setFloatValue((float)i); 
      outs.get(0).setDataStatus(DataStatus.HOT);
      subgraph.evaluate();     
    }
    
    outs.get(0).targetFlow.setFloatValue(loops);
  }
  
}
