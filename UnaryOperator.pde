public abstract class UnaryOp extends PrimeOperator implements UnaryOperator<Float>{
  
  UnaryOp(){
    super();
    setExecutionSemantics(ExecutionSemantics.MUTATES);
  }
  
  void initialize(){
    addInPork(DataType.NUMERIC); addOutPork(DataType.NUMERIC);
  }

  public abstract float apply(float value);

  void execute(){    
   outs.get(0).targetFlow.setFloatValue(apply(ins.get(0).targetFlow.getFloatValue()));
  }  
}

class SinOperator extends UnaryOp{
  SinOperator(){super();name = "sin";label =  "sin";}
  public float apply(float x) { 
    return sin(x); 
  }
}

class CosOperator extends UnaryOp{
  CosOperator(){super();name = "cos";label =  "cos";}
  public float apply(float x) { 
    return cos(x); 
  }
}

class TanOperator extends UnaryOp{
  TanOperator(){super();name = "tan";label =  "tan";}
  public float apply(float x) { 
    return tan(x); 
  }
}

class AsinOperator extends UnaryOp{
  AsinOperator(){super();name = "asin";label =  "asin";}
  public float apply(float x) { 
    return asin(x); 
  }
}

class AcosOperator extends UnaryOp{
  AcosOperator(){super();name = "acos";label =  "acos";}
  public float apply(float x) { 
    return acos(x); 
  }
}

class AtanOperator extends UnaryOp{
  AtanOperator(){super();name = "atan";label =  "atan";}
  public float apply(float x) { 
    return atan(x); 
  }
}

class AbsOperator extends UnaryOp{
  AbsOperator(){super();name = "abs";label =  "abs";}
  public float apply(float x) { 
    return abs(x); 
  }
}

class SqrtOperator extends UnaryOp{
  SqrtOperator(){super();name = "sqrt";label =  "sqrt";}
  public float apply(float x) { 
    return sqrt(x); 
  }
}

class FloorOperator extends UnaryOp{
  FloorOperator(){super();name = "floor";label =  "floor";}
  public float apply(float x) { 
    return floor(x); 
  }
}

class RoundOperator extends UnaryOp{
  RoundOperator(){super();name = "round";label =  "round";}
  public float apply(float x) { 
    return round(x); 
  }
}

class RandomOperator extends UnaryOp{
  RandomOperator(){super();name = "random";label =  "random";}
  public float apply(float x) { 
    return random(x); 
  }
}
