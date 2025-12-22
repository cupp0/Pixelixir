//~BiMap for port2pork / pork2port
class BiMap {
  HashMap<Pork, PortUI> porkToPort = new HashMap<>();
  HashMap<PortUI, Pork> portToPork = new HashMap<>();
  
  void put(PortUI ui, Pork data) {
    // Remove old mappings if present
    if (porkToPort.containsKey(data)) {
      portToPork.remove(porkToPort.get(data));
    }
    if (portToPork.containsKey(ui)) {
      porkToPort.remove(portToPork.get(ui));
    }
    
    porkToPort.put(data, ui);
    portToPork.put(ui, data);
  }
  
  Pork getPork(PortUI ui) {
    return portToPork.get(ui);
  }
  
  PortUI getPort(Pork data) {
    return porkToPort.get(data);
  }
  
  void removeUI(PortUI ui) {
    if (porkToPort.containsKey(ui)) {
      Pork data = portToPork.get(ui);
      porkToPort.remove(ui);
      portToPork.remove(data);
    }
  }
 
  void removeData(PortUI data) {
    if (portToPork.containsKey(data)) {
      PortUI ui = porkToPort.get(data);
      portToPork.remove(data);
      porkToPort.remove(ui);
    }
  }
}
