class MetaHelper{
  
  Window w;
  PortUI p;
  
  MetaHelper(Window w_, PortUI p_){
    w = w_; p = p_;
  }
  
}

class ConnectOperator extends PrimeOperator {
  
  ConnectOperator(){
    super();
    name = "connect";
  }
  
  void initialize(){    
    addInPork(DataCategory.PORT);
    addInPork(DataCategory.PORT);
  }
  
  void execute(){
    MetaHelper src = getPort(ins.get(0).targetFlow.getPortValue());
    MetaHelper dest = getPort(ins.get(1).targetFlow.getPortValue());
    
    if (src == null){println("no source found"); return; }
    if (dest == null){println("no dest found"); return; }   
    OutPortUI ui = (OutPortUI)src.p;
    if (!((OutPork)ui.getPorkPair()).elligibleForConnection()){return; }
    
    src.w.attemptConnection(((OutPortUI)src.p), ((InPortUI)dest.p), DataAccess.READONLY);

  }
  
  MetaHelper getPort(String id){
    for (Window w : windows.values()){
      for (Module m : w.modules){
        for (InPortUI ui : m.ins){
          if (ui.id == id){
            return new MetaHelper(w, ui);
          }
        }
        for (OutPortUI ui : m.outs){
          if (ui.id == id){
            return new MetaHelper(w, ui);
          }
        }
      }
    }
    
    println("port not found");
    return null;
  }
 
}
