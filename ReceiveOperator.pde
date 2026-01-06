class ReceiveOperator extends IOOperator{  
  
  ReceiveOperator(){
    super();
    name = "receive"; setExecutionSemantics(ExecutionSemantics.MUTATES);
  }
  
  //hide input, exposed on enclosing composite
  @Override
  void addBoundPair(){
    super.addBoundPair();
    ins.get(ins.size()-1).setHidden(true);
  }
  
  //only difference is we don't tell listener (Module) to make 
  //a corresponding InPortUI
  @Override
  InPork addInPork(DataType dt){                             
    InPork in = new InPork(this, ins.size());                //create the pork
    in.setDefaultDataType(dt);
    ins.add(in);                                             //store it
    return in;
  }
  
  void rebuildPorks(int inCount, int outCount){
    while (outs.size() < outCount) addCanonicalPork(); 
  }

  //receive just built a connection. Do we need to make a port on the enclosing composite?
  //do we need to make a port on the receive?
  @Override
  void onConnectionAdded(OutPork where){
    //if all outs are full, add a new one
    if (outPorksFull()){
      addCanonicalPork();
    }    
    tryExposingHiddenPorts();
  }
  
}
