class PrintOperator extends PrimeOperator{
   PrintOperator(){
    super();
    name = "print";
  }
  
  void initialize(){
    initializeTypeBinder(addInPork(DataType.UNDETERMINED));
  }

  void execute(){   
    println(ins.get(0).targetFlow.valueToString());
  } 

}
