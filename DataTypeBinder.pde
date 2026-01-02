//helper class for resolving ports that accept multiple data types
class DataTypeBinder {
  
  DataType dt;
  ArrayList<Pork> boundPorks = new ArrayList<Pork>();

  DataTypeBinder(Pork p){
    addPork(p);  
  }
  
  void addPork(Pork p){ boundPorks.add(p); }
  
  ArrayList<Pork> getBoundPorks(){ return boundPorks; }
  
  void setDataType(DataType dt_){ 
    dt = dt_;
    for (Pork p : boundPorks){
      p.setCurrentDataType(dt);
    }
  }
  
  DataType getDataType(){ return dt; }
  
}
