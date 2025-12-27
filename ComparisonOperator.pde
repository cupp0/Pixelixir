abstract class ComparisonOperator extends PrimeOperator{
  void initialize(){
    addInPork(DataCategory.FLOAT); addInPork(DataCategory.FLOAT); addOutPork(DataCategory.BOOL).setTargetFlow(new Flow(DataCategory.BOOL));
  }
}
