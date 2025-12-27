//every operator that is not primitive is a composite operator
class CompositeOperator extends Operator implements DynamicPorts{

  ArrayList<UpdateObject> updaters = new ArrayList<>(); //which porks are providing new data to the window
                                                        //keyed by this operator
  CompositeOperator(){
    super();
    name = "composite";
  }
  
  void initializeWindow(){
    windows.put(this, new Window(this));
  }
  
  void initialize(){}
  
  void primerContinousUpdaters(){
    for (Operator op : kids){
      if (op.continuous){
        
        if (op instanceof PrimeOperator){
          op.outs.get(0).dataNotification();     //assumes continuous prime ops send data to output zero
        }
        
        else {
          ((CompositeOperator)op).primerContinousUpdaters();
        }
        
      }
    }
  }

  //filters its topoSort by the combined BFS's of any updating OutPork
  void generateEvaluationSequence(){
    evaluationSequence.clear();     
    
    if (updaters.size() == 0){return; } //if nothing is updating we can leave operationOrder empty.

    else {  
      //create an unordered list of all objects that need to operate
      Set<Operator> neededOps = new HashSet<>(); 
      
      for (UpdateObject uo : updaters){
        
        // ~~ updater is a specific port ~~//
        if (uo.out != null){
          //add whatever operator is updating
          neededOps.add(uo.out.owner);
          
          //add any operator reachable from that pork
          for (Operator op : graph.reachableOps(uo.out)){
            neededOps.add(op);
          }
        }
        
        
        //~~ updater is an Operator with no designated port ~~//
        else {
          neededOps.add(uo.op);
        }
      }
      
      //filter topoSort by this list.
      for (Operator op : graph.topoSort){
        if (neededOps.contains(op)){
          evaluationSequence.add(op);
          
          //if we run into a composite, generate its sequence as well
          if (op instanceof CompositeOperator){
            ((CompositeOperator)op).generateEvaluationSequence();
          }
          
        }
      }
    }

    updaters.clear();   
  }
  
  void execute(){
    for (int i = 0; i < evaluationSequence.size(); i++){
      evaluationSequence.get(i).evaluate(); 
      
      //if nothing downstream relies on the same data, set to upstream to cold
      for (InPork in : ins){
        
        boolean stillHot = false;
        for (InPork lateralIn : in.getSource().getDestinations()){
          if (this.evaluatesBefore(lateralIn.owner)){
            stillHot = true;
          }
        }
        in.getSource().setHot(stillHot);

      }
    }
  }
  
  boolean evaluatesBefore(Operator other){
    for (int i = 0; i < evaluationSequence.size(); i++){
      if (evaluationSequence.get(i) == this) return true;
      if (evaluationSequence.get(i) == other) return false;
    }
    return false;
  }
  
  boolean isSpeaker() { return true; }
  boolean isListener() { return true; }
  
  //InPork where is the input of the composite that is receiving new data.
  //it calls notify listeners at the appropriate PortUI of its contained receive Op
  void onSpeaking(InPork where){
    if (where != null){
      int whichPort = where.index;
      if (getReceiver() != null){
        getReceiver().outs.get(whichPort).dataNotification();
      }
    } 
  }
  
  void addUpdater(UpdateObject uo){
    
    //typically this is adding an outpork, so each scope knows exactly where its
    //getting new data
    if (!updaters.contains(uo)){
      updaters.add(uo);
    }
    
    //in the case where the update object is an operator with no specified pork, propagate 
    //thagt info outward. It means there is a graph island that needs to update
    if (uo.op != null){
      if (this != bigbang){
        parent.addUpdater(new UpdateObject(this));
      }
    }
  }
  
  boolean isUpdater(OutPork out){
    return updaters.contains(out);
  }
  
  void onConnectionAdded(Pork where){
    //resolveType(where); 
  }
   
  void onConnectionRemoved(Pork where){}
  
}
