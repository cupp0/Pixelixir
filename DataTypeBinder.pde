//type contract for porks
class DataTypeBinder {
  
  EnumSet<DataType> allowedTypes;
  DataType currentType;
  ArrayList<Pork> boundPorks = new ArrayList<Pork>();

  DataTypeBinder(Pork p){
    addPork(p);  
    setCurrentType(p.getCurrentDataType());
  }
  
  void addPork(Pork p){ boundPorks.add(p); }
  
  ArrayList<Pork> getBoundPorks(){ return boundPorks; }
  
  //propagates type to anyting connected as well
  void setCurrentType(DataType dt){ 
    currentType = dt;
    for (Pork p : boundPorks){
      p.setCurrentDataType(currentType);
      ArrayList<Pork> ps = p.getConnectedPorks();
      for (Pork por : ps){
        if (por.getCurrentDataType() != dt){
          por.owner.propagateCurrentDataType(por, dt); 
        }
      }
    }
  }
  
  DataType getCurrentType(){ return currentType; }
  
}
