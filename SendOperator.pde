//send and receive are the linkage between scopes
class SendOperator extends IOOperator{  
  
  SendOperator(){
    super();
    name = "send"; setExecutionSemantics(ExecutionSemantics.MUTATES);
  }
  
  //hide output, expose on enclosing composite
  @Override
  void addBoundPair(){
    super.addBoundPair();
    outs.get(outs.size()-1).setHidden(true);
  }

  //only difference here is we don't tell listener (Module) to expose this port
  //via and OutPortUI instance
  @Override
  OutPork addOutPork(DataType dt){                             
    OutPork out = new OutPork(this, outs.size());             //create the pork
    out.setDefaultDataType(dt);
    outs.add(out);                                            //store it
    return out;
  }  
  
  void rebuildPorks(int inCount, int outCount){
    while (ins.size() <inCount) addCanonicalPork(); 
  }
  
  //index_ tells us which Sender Pork just built a new connection
  @Override
  void onConnectionAdded(InPork where){
    if (inPorksFull()){
      addCanonicalPork();
    }    
    if (((Module)listener).parent.outs.size() <= where.index){
      exposeHiddenPork(outs.get(where.index));
    }
  }
  
  boolean isInputDynamic(){ return true; }
  boolean isOutputDynamic(){ return true; }

}
