//~Edge

enum DataStatus {CONTINUATION, OBSERVATION}

class Edge{
  
  OutPork source;
  InPork destination;
  final DataStatus dataStatus;
  
  Edge(OutPork from, InPork towards, DataStatus dataStatus_){
    source = from; destination = towards; dataStatus = dataStatus_; 
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
