abstract class ComparisonOperator extends PrimeOperator{
  void initialize(){
    addInPork(DataType.NUMERIC); addInPork(DataType.NUMERIC); addOutPork(DataType.BOOL).setTargetFlow(new Flow(DataType.BOOL));
  }
}
