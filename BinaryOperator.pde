public abstract class BinaryOp extends PrimeOperator{
  
  final BinaryOperator<Float> expr;
  
  BinaryOp(BinaryOperator<Float> expr_){
    super();
    expr = expr_;
  }
  
  void initialize(){
    addInPork(DataCategory.FLOAT); addInPork(DataCategory.FLOAT); addOutPork(DataCategory.FLOAT);
  }
  
  void execute(){    
                          //gather input data
    
    //apply lambda expression
    outs.get(0).data.setFloatValue(expr.apply(inFlows.get(0).getFloatValue(), inFlows.get(1).getFloatValue()));
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