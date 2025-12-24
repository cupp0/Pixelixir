abstract class PrimeOperator extends Operator{
  
  PrimeOperator(){
    super();
  }
  
  void setDefaultDataStatuses(){
    
    //by default, first input is the continuation port
    for (int i = 0; i < ins.size(); i++){
      if (i == 0){
        ins.get(i).addAllowedStatus(DataStatus.CONTINUATION);
      } else {
        ins.get(i).allowAllStatuses();
      }
    }
    
    //outs can always be either read or write by default
    for (int i = 0; i < outs.size(); i++){
      outs.get(i).allowAllStatuses();
    }
  }
    
}
