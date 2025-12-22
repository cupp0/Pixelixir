abstract class LogicOp extends PrimeOperator implements LogicOperator<Boolean>{
  
  LogicOp(){
    super();
  }
  
  void initialize(){
    addInPork(DataCategory.BOOL); addInPork(DataCategory.BOOL); addOutPork(DataCategory.BOOL);
  }
  
  void execute(){
                          //gather input data
    outs.get(0).data.setBoolValue(apply(inFlows.get(0).getBoolValue(), inFlows.get(1).getBoolValue()));
  }
  
  public abstract boolean apply(boolean a, boolean b);
}

class AndOperator extends LogicOp{
  AndOperator(){super();name = "and"; expSymbol =  "&&";}
  public boolean apply(boolean a, boolean b) { 
    return a&&b; 
  }
}

class OrOperator extends LogicOp{
  OrOperator(){super();name = "or";expSymbol =  "||";}
  public boolean apply(boolean a, boolean b) { 
    return a||b; 
  }
}

class XOrOperator extends LogicOp{
 XOrOperator(){super();name = "xOr";expSymbol =  "^";}
  public boolean apply(boolean a, boolean b) { 
    return a^b; 
  }
}

class NotOperator extends LogicOp{
  
 NotOperator(){super();name = "not";expSymbol =  "!";}
  void initialize(){
    addInPork(DataCategory.BOOL); addOutPork(DataCategory.BOOL);
  }
  
  void execute(){                  
    outs.get(0).data.setBoolValue(apply(inFlows.get(0).getBoolValue(), true));
  }
  
  public boolean apply(boolean a, boolean b) { 
    return !a; 
  }
}