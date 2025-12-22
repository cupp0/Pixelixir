//~FlowRegistry

//store and retrieve data with read/write operators
class FlowRegistry{
  
  HashMap<String, Flow> flows = new HashMap<String, Flow>();
  
  FlowRegistry(){}
  
  void writeFlow(String address, Flow f){
    println(f.getType());
    flows.put(address, f);
  }
  
  Flow readFlow(String address){
    if (flows.containsKey(address)){
      println(flows.get(address).getType());
      return flows.get(address);
    } 
    return null;
  }
  
  //called any time a writer's textfield changes so we don't hold on to extra addresses
  void removeFlow(String s){
    if (flows.containsKey(s)){
      flows.remove(s);
    } else {println("nothing to remove");}
  }
}
