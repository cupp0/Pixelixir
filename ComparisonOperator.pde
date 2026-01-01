abstract class ComparisonOperator extends PrimeOperator{
  void initialize(){
    addInPork(DataCategory.NUMERIC); addInPork(DataCategory.NUMERIC); addOutPork(DataCategory.BOOL).setTargetFlow(new Flow(DataCategory.BOOL));
  }
}
