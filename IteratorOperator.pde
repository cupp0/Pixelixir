class IteratorOperator extends PrimeOperator implements GraphListener{
  
  Graph subgraph;
  
  IteratorOperator(){
    super();
    name = "iterator"; setExecutionSemantics(ExecutionSemantics.MUTATES);
  }
  
  void initialize(){
    addInPork(DataType.UNDETERMINED); addInPork(DataType.NUMERIC);
    addOutPork(DataType.UNDETERMINED).setTargetFlow(new Flow(DataType.UNDETERMINED));
    addOutPork(DataType.NUMERIC).setTargetFlow(new Flow(DataType.NUMERIC)); 
    initializeTypeBinder(ins.get(0), outs.get(0));
    
    graph.addListener(this);    
  }
  
  void onGraphChange(){
    subgraph = graph.getSubgraph(this);
  }
  
  void execute(){    
    int loops = constrain((int)ins.get(1).targetFlow.getFloatValue(), 0, 1000000);
    subgraph.addUpdater(outs.get(0));
    subgraph.addUpdater(outs.get(1));
    subgraph.generateEvaluationSequence();
        
    for (int i = 0; i < loops; i++){
      outs.get(1).targetFlow.setFloatValue((float)i); 
      outs.get(0).setDataStatus(DataStatus.HOT);
      outs.get(1).setDataStatus(DataStatus.HOT);
      subgraph.evaluate();     
    }
    
    outs.get(1).targetFlow.setFloatValue(loops);
  }
  
}
