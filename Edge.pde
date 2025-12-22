//~Edge
class Edge{
  
  OutPork source;
  InPork destination;
  
  Edge(OutPork from, InPork towards){
    source = from; destination = towards;
  }
  
  Operator sourceOwner(){return source.owner;}
  Operator destinationOwner(){ return destination.owner;}
  
  boolean isConnectedToModule(Module m){
    Window where = windows.get(source.owner.parent); //make sure we are looking at the correct graph
    if (where.portMap.getPort(source).parent == m || where.portMap.getPort(destination).parent == m){
      return true;
    }
    return false;
  }
  
}
