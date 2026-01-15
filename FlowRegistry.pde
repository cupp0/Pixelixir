//~FlowRegistry

//store and retrieve data with read/write operators
class FlowRegistry{
  
  HashMap<String, Flow> flows = new HashMap<String, Flow>();
  
  FlowRegistry(){}
  
  void writeFlow(String address, Flow f){
    flows.put(address, f.copyFlow());
  }
  
  Flow readFlow(String address){
    if (flows.containsKey(address)){
      return flows.get(address);
    } else { println("nothing to read"); }
    return null;
  }

}
