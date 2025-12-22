//~BaseUI
public abstract class BaseUI{
  
  String name;
  String label = ""; 
  Style style;
   
  BaseUI() {
  }

  public Style getStyle(){
    return style;
  }
  
  String getAddress(){
    return this.toString().substring(this.toString().indexOf('@'));
  }

}
