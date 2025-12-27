public abstract class UnaryOp extends PrimeOperator implements UnaryOperator<Float>{
  
  UnaryOp(){
    super();
    setExecutionSemantics(ExecutionSemantics.MUTATES);
  }
  
  void initialize(){
    addInPork(DataCategory.FLOAT); addOutPork(DataCategory.FLOAT);
  }

  public abstract float apply(float value);

  void execute(){    
   outs.get(0).targetFlow.setFloatValue(apply(ins.get(0).targetFlow.getFloatValue()));
  }  
}

class SinOperator extends UnaryOp{
  SinOperator(){super();name = "sin";expSymbol =  "sin";}
  public float apply(float x) { 
    return sin(x); 
  }
}

class CosOperator extends UnaryOp{
  CosOperator(){super();name = "cos";expSymbol =  "cos";}
  public float apply(float x) { 
    return cos(x); 
  }
}

class TanOperator extends UnaryOp{
  TanOperator(){super();name = "tan";expSymbol =  "tan";}
  public float apply(float x) { 
    return tan(x); 
  }
}

class AbsOperator extends UnaryOp{
  AbsOperator(){super();name = "abs";expSymbol =  "abs";}
  public float apply(float x) { 
    return abs(x); 
  }
}
