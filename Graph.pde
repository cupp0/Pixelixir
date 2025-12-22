//~Graph

class Graph {
  
  Window view;                                                      
  ArrayList<Edge> edges = new ArrayList<>();                        //stores connections between porks    
  ArrayList<Operator> topoSort = new ArrayList<Operator>();         //graph maintains a sort
                                                              
  //construct Graph from list of Modules and their edges
  Graph(){}
  
  void addEdge(OutPork from, InPork towards){
    //if making a connection between different, but compatible ports, collapse type
    //Flow.mergeTypes(from.data, towards.data);
    
    edges.add(new Edge(from, towards));
    from.onConnection(towards);
    towards.onConnection(from);
        
    computeTopoSort();     
  }
  
  void removeEdge(Edge e){  
    for (Edge ed : edges){
      if (e == ed){
        edges.remove(e);
        break;
      }      
    }
    computeTopoSort();
  }
  
  //kahns algorithm.
  private void computeTopoSort(){
    
    topoSort.clear();
    
    //create list of all operators
    Set<Operator> allOps = new HashSet<>();
    for (Module m : view.modules) {
      allOps.add(m.owner);
    }
    
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
  
  //return OutPork sending to a given InPork
  OutPork getSource(InPork towards){
    for (Edge e : edges){
      if (e.destination == towards){
        return e.source;
      }
    }
    return null;
  }
  
  void stringExp(){
    String oprtrs = "";
    String oprnds = "";
    int oprndCount = 0;
    for (Operator op : topoSort){
      if (op instanceof BinaryOp){
        oprtrs += op.expSymbol+",";
      } else {
        oprnds += "x"+str(oprndCount)+","; 
        oprndCount++;
      }
    }
  }
  
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
