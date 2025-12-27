public abstract class BinaryOp extends PrimeOperator{
  
  final BinaryOperator<Float> expr;
  
  BinaryOp(BinaryOperator<Float> expr_){
    super();
    setExecutionSemantics(ExecutionSemantics.MUTATES); expr = expr_;
  }
  
  void initialize(){
    addInPork(DataCategory.FLOAT, false, true); 
    addInPork(DataCategory.FLOAT, false, false); 
    addOutPork(DataCategory.FLOAT, false, true);
  }
  
  void execute(){    
    Flow i1 = ins.get(0).targetFlow;
    Flow i2 = ins.get(1).targetFlow;
    Flow o = outs.get(0).targetFlow;
    if (i1 != null && i2 != null && o != null){
      o.setFloatValue(expr.apply(i1.getFloatValue(), i2.getFloatValue()));
    }
  }
  
}

class AddOperator extends BinaryOp{
  AddOperator(){super((x, y) -> x + y);name = "add";expSymbol =  "+";}
}

class SubtractOperator extends BinaryOp{
  SubtractOperator(){super((x, y) -> x - y);name = "subtract";expSymbol = "-";}
}

class MultiplyOperator extends BinaryOp{
  MultiplyOperator(){super((x, y) -> x * y); name = "multiply";expSymbol = "*";}
}

class DivideOperator extends BinaryOp{
  DivideOperator(){super((x, y) -> x / y); name = "divide";expSymbol = "/";}
}

class ModulusOperator extends BinaryOp{
  ModulusOperator(){super((x, y) -> x % y); name = "modulus";expSymbol = "%";}
}

class PowerOperator extends BinaryOp{
  PowerOperator(){super((x, y) -> (float)Math.pow(x.doubleValue(), y.doubleValue())); name = "power";expSymbol = "^";}
}
