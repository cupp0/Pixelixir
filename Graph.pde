//~Graph

class Graph {
  
  ArrayList<Edge> edges = new ArrayList<>();                          //stores connections between porks    
  ArrayList<Operator> allOps = new ArrayList<Operator>();             //unordered list
  ArrayList<Operator> topoSort = new ArrayList<Operator>();           //updated when we add/remove a module/connection
  ArrayList<Operator> evaluationSequence = new ArrayList<Operator>(); //recalculated each frame                                            
  ArrayList<OutPork> updaters = new ArrayList<>();                    //ports that are providing new data
  
Graph(){}
  
  
  //graph should probably handle all that onConnection stuff currently in Pork
  void addEdge(OutPork from, InPork towards, DataAccess ds){    
    edges.add(new Edge(from, towards, ds));    
    from.onConnection(towards);        
    computeTopoSort();       
  }
  
  void removeEdge(Edge e){  
    for (Edge ed : edges){
      if (e == ed){
        edges.remove(e);
        break;
      }      
    }
    
    e.source.onConnectionRemoved(e.destination);
    computeTopoSort();
  }
  
  void addOperator(Operator op){
    allOps.add(op);
    computeTopoSort();
  }  
  
  void removeOperator(Operator op){
    allOps.remove(op);
    computeTopoSort();
  }
  
  //kahns algorithm.
  private void computeTopoSort(){
    topoSort.clear();
    
    //we need all in degrees of all operators in the graph
    HashMap<Operator, Integer> inDegrees = new HashMap<>();  //in degree of every module in the graph 
    for (Operator op : allOps){
      inDegrees.put(op, 0);
    }
    
    //increment inDegree value for each destination in edge list
    for (Edge e : edges){
      inDegrees.merge(e.destinationOwner(), 1, Integer::sum);
    }
    
    //enqueueue any operator with zero incoming edges
    Queue<Operator> q = new LinkedList<>();            
    for (Map.Entry<Operator, Integer> entry : inDegrees.entrySet()) {
      if (entry.getValue() == 0) {
        q.add(entry.getKey());
      }
    }
    
    //begin sorting. If an operator has in degree 0, that means anything upstream has already been q'd
    //and it is good to go.
    while (!q.isEmpty()) {                
      Operator current = q.poll();                        
      topoSort.add(current);
      
      //decrement in degree of any operator downstream from what we just removed
      for (Edge e : edges){
        if (e.sourceOwner() == current){
          Operator downstream = e.destinationOwner();
          inDegrees.put(downstream, inDegrees.get(downstream)-1);
          if (inDegrees.get(downstream) ==0){
            q.add(downstream);
          }
        }
      }
    }
  }
  
  void addUpdater(OutPork o){    
    updaters.add(o);
  }
  
  //before generating eval sequence, primer all outputs that are continuous (valve
  void primerContinousUpdaters(){
    for (Operator op : topoSort){
      if (op.isContinuous()){        
        op.outs.get(0).dataNotification(); //assumes all continuous ops send continuous data to output 0        
      }
    }
  }
  
  //filters its topoSort by the combined BFS's of any updating OutPork
  void generateEvaluationSequence(){
    evaluationSequence.clear();     
    
    if (updaters.size() == 0){return; } //if nothing is updating we can leave operationOrder empty.
 
    //create an unordered list of all ops that need to operate
    Set<Operator> neededOps = new HashSet<>(); 
    
    //collects BFS from all updaters
    for (OutPork o : updaters){      
      neededOps.add(o.owner);
      for (Operator op : graph.reachableOps(o)){
        neededOps.add(op);
      }
    }
        
    //filter topoSort by this list.
    for (Operator op : topoSort){
      if (neededOps.contains(op)){
        evaluationSequence.add(op);
      }
    }
    
    updaters.clear();   
  }
  
  void evaluate(){
    for (Operator op : evaluationSequence){
      op.evaluate(); 
    }
    for (Operator op : evaluationSequence){
      op.setPortsCold();       
    }
  }
  
  //return OutPork sending to a given InPork
  OutPork getSource(InPork towards){
    for (Edge e : edges){
      if (e.destination == towards){
        return e.source;
      }
    }
    return null;
  }
  
  //void stringExp(){
  //  String oprtrs = "";
  //  String oprnds = "";
  //  int oprndCount = 0;
  //  for (Operator op : topoSort){
  //    if (op instanceof BinaryOp){
  //      oprtrs += op.label+",";
  //    } else {
  //      oprnds += "x"+str(oprndCount)+","; 
  //      oprndCount++;
  //    }
  //  }
  //}
  
  //return list of receiving porks
  ArrayList<InPork> getDestinations(OutPork from){
    ArrayList<InPork> dests = new ArrayList<InPork>();
    for (Edge e : edges){
      if (e.source == from){
        dests.add(e.destination);
      }
    }
    return dests;
  }
  
  //BFS list of inporks reachable from a given starting port
  Set<InPork> reachablePorks(OutPork start) {
    Set<InPork> visited = new HashSet<>();
    Deque<InPork> stack = new ArrayDeque<>();
    for (InPork i : start.getDestinations()){
      stack.push(i);
    }

    while (!stack.isEmpty()) {
      InPork current = stack.pop(); 
      if (!visited.add(current)) continue;  //add returns true if it had to be added, false if it was already there
      for (OutPork o : current.owner.outs) {
        for (InPork i : getDestinations(o)) {
          stack.push(i);
        }
      }
    }
    return visited;
  }
  
  //BFS list of operators reachable from a given starting port
  Set<Operator> reachableOps(OutPork start) {
    Set<InPork> porks = reachablePorks(start);
    Set<Operator> ops = new HashSet<>();
    for (InPork in : porks){
      ops.add(in.owner);
    }
    
    return ops;
  }
  
  //returns any edges that connect 2 mods contained in fromMods
  ArrayList<Edge> getConnectingEdges(ArrayList<Module> fromMods, Window where){
    ArrayList<Edge> connectingEdges = new ArrayList<Edge>();
    for (Edge e : edges){
      PortUI sender = where.portMap.getPort(e.source);
      PortUI receiver = where.portMap.getPort(e.destination);
      
      if (fromMods.contains(sender.parent) && fromMods.contains(receiver.parent)){
        connectingEdges.add(e);
      }
    }
    return connectingEdges;
  }
  
  Edge getEdge(Window w, Connection c){
    for (Edge e : edges){
      if (c.source == w.portMap.getPort(e.source) && c.destination == w.portMap.getPort(e.destination)){
        return e;
      }
    }
    return null;
  }
  
  boolean isConnected(OutPork start, InPork target){
    if (reachablePorks(start).contains(target)){
      return true;
    }
    return false;
  }
  
  public ArrayList<Operator> getTopoSort(){ return topoSort; }
  
  String getAddress(){
    return this.toString().substring(this.toString().indexOf('@'));
  }
  
}
