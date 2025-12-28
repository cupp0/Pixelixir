abstract class LogicOp extends PrimeOperator implements LogicOperator<Boolean>{
  
  LogicOp(){
    super();
  }
  
  void initialize(){
    addInPork(DataCategory.BOOL); addInPork(DataCategory.BOOL); addOutPork(DataCategory.BOOL).setTargetFlow(new Flow(DataCategory.BOOL));
  }
  
  void execute(){
    Flow i1 = ins.get(0).targetFlow;
    Flow i2 = ins.get(1).targetFlow;
    Flow o = outs.get(0).targetFlow;
    o.setBoolValue(apply(i1.getBoolValue(), i2.getBoolValue()));
  }
  
  public abstract boolean apply(boolean a, boolean b);
}

class AndOperator extends LogicOp{
  AndOperator(){super();name = "and"; label =  "&&";}
  public boolean apply(boolean a, boolean b) { 
    return a&&b; 
  }
}

class OrOperator extends LogicOp{
  OrOperator(){super();name = "or";label =  "||";}
  public boolean apply(boolean a, boolean b) { 
    return a||b; 
  }
}

class XOrOperator extends LogicOp{
 XOrOperator(){super();name = "xOr";label =  "^";}
  public boolean apply(boolean a, boolean b) { 
    return a^b; 
  }
}

class NotOperator extends LogicOp{
  
 NotOperator(){super();name = "not";label =  "!";}
 
 @Override
  void initialize(){
    addInPork(DataCategory.BOOL); addOutPork(DataCategory.BOOL).setTargetFlow(new Flow(DataCategory.BOOL));
  }
  
  void execute(){                  
   outs.get(0).targetFlow.setBoolValue(apply(ins.get(0).targetFlow.getBoolValue(), true));
  }
  
  public boolean apply(boolean a, boolean b) { 
    return !a; 
  }
}
