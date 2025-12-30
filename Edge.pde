//~Edge

enum DataAccess {READWRITE, READ}

class Edge{
  
  OutPork source;
  InPork destination;
  final DataAccess dataAccess;
  
  Edge(OutPork from, InPork towards, DataAccess dataAccess_){
    source = from; destination = towards; dataAccess = dataAccess_; 
  }
  
  Operator sourceOwner(){return source.owner;}
  Operator destinationOwner(){ return destination.owner;}
  
  boolean isConnectedToModule(Module m){
    Window where = m.getWindow();
    if (where.portMap.getPort(source).parent == m || where.portMap.getPort(destination).parent == m){
      return true;
    }
    return false;
  }
  
}
