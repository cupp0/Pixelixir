//these operators listen for raw input (mouse, key events) no matter what window they are in
abstract class RawInputOperator extends PrimeOperator implements GlobalEventListener{
  
  RawInputOperator(){
    super();
    globalInputMan.registerGlobalListener(this);
  }
  
  abstract void onGlobalInputEvent(GlobalInputEvent e);
  
  abstract void execute();
}
