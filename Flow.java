//~Flow
import  java.util.*;

enum DataCategory {
  INT,
  FLOAT,
  BOOL,
  TEXT,
  LIST,
  IMAGE, 
  MODULE,
  UNKNOWN
}

public class Flow {
  
  private DataCategory type;

  // Value storage for each category
  private float floatValue;
  private boolean boolValue;
  private String textValue;
  private List<Flow> listValue;
  private String moduleValue;        //module id
  //private ImageBuffer imageValue;
 

  // ---------- Constructors are private: use factories ----------
  //private Flow(Category type) {
  //    this.type = type;
  //}
  
  public Flow(DataCategory type) {
    this.type = type;       // empty, uninitialized
    if (type == DataCategory.LIST){
      listValue = new ArrayList<Flow>();
    }
  }

  public static Flow ofFloat(float value) {
      Flow f = new Flow(DataCategory.FLOAT);
      f.floatValue = value;
      return f;
  }

  public static Flow ofBool(boolean value) {
      Flow f = new Flow(DataCategory.BOOL);
      f.boolValue = value;
      return f;
  }

  public static Flow ofText(String value) {
      Flow f = new Flow(DataCategory.TEXT);
      f.textValue = value;
      return f;
  }

  public static Flow ofList(java.util.List<Flow> value) {
      Flow f = new Flow(DataCategory.LIST);
      f.listValue = value;
      return f;
  }
  
  public static Flow ofModule(String value) {
      Flow f = new Flow(DataCategory.MODULE);
      f.moduleValue = value;
      return f;
  }

  // ---------- Type ----------
  public DataCategory getType() {
      return type;
  }

  // ---------- Getters ----------

  String getAddress(){
    return this.toString().substring(this.toString().indexOf('@'));
  }
  
  public float getFloatValue() {
    return floatValue;
  }

  public boolean getBoolValue() {
    return boolValue;
  }

  public String getTextValue() {
    return textValue;
  }

  public java.util.List<Flow> getListValue() {
    return listValue;
  }
  
  public String getModuleValue() {
    return moduleValue;
  }
  
  public String valueToString(){
    switch(type){

      case FLOAT:
      return Float.toString(getFloatValue());
      
      case BOOL:
      return Boolean.toString(getBoolValue());

      case TEXT:
      return getTextValue();
      
      case LIST:
      return "list";
      
      default:
      return ":)";
    }
  }


  // ---------- Setters ----------

  public void toFloat() {
    setType(DataCategory.FLOAT);
  }

  public void toBool() {
    setType(DataCategory.BOOL);
  }

  public void toText() {
    setType(DataCategory.TEXT);
  }

  public void toList() {
    setType(DataCategory.LIST);
  }

  public void setFloatValue(float v) {
    this.floatValue = v;
  }

  public void setBoolValue(boolean v) {
      this.boolValue = v;
  }

  public void setTextValue(String v) {
    this.textValue = v;
  }

  public void setListValue(java.util.List<Flow> v) {
    this.listValue = v;
  }
  
  public void setModuleValue(String v) {
      this.moduleValue = v;
  }
  
  public void setListAtIndex(int i, Flow f) {
    if (i >= 0 && i < this.listValue.size()){
      this.listValue.set(i, f);
    } else {
      System.out.println("setListAtIndex, out of bounds");
    }
  }

  public void addToList(Flow f){
    listValue.add(f);
  }
  
  //remove from list by index
  public void removeFromList(int i){
    listValue.remove(i);
  }
  
  public void clearList(){
    listValue.clear();
  }

  // ---------- type enforcement ----------
  
  public static boolean compatible(DataCategory a, DataCategory b) {
    // Unknown types always match
    if (a == DataCategory.UNKNOWN || b == DataCategory.UNKNOWN)
      return true;

    return a == b;
  }

  public void setType(DataCategory newType) {
    this.type = newType;
    if (newType == DataCategory.LIST){
      listValue = new ArrayList<Flow>();
    }
  }

  //ensures two flowlists are of equal dimension, where the size of 
  //b must change to match the size of a.
  static void matchListSizes(Flow a, Flow b){
    while (a.listValue.size() > b.listValue.size()){
      b.addToList(new Flow(a.listValue.get(b.listValue.size()).type));
    }
    
    while (a.listValue.size() < b.listValue.size()){
      b.removeFromList(b.listValue.size()-1);
    }
  }
  
  //static copy
  static void copyData(Flow source, Flow destination){
    if (source.type == destination.type){
      switch(source.type){
        case FLOAT:
        destination.setFloatValue(source.getFloatValue());
        break;
        
        case BOOL:
        destination.setBoolValue(source.getBoolValue());
        break;
  
        case TEXT:
        destination.setTextValue(source.getTextValue());
        break;
        
        case LIST:
        
        matchListSizes(source, destination);
        for (int i = 0; i < source.listValue.size(); i++){
          copyData(source.listValue.get(i), destination.listValue.get(i));
        }
        break;
        
        case MODULE:
        destination.setModuleValue(source.getModuleValue());
        break;
      }
    } else {
      System.out.println("attempted to copy " + source.getType() + " to " + destination.getType());
    }
  }
  
  Flow copyFlow(){
    Flow f = new Flow(type);
    switch(type){
      
      case FLOAT:
      f.setFloatValue(getFloatValue());
      break;
      
      case BOOL:
      f.setBoolValue(getBoolValue());
      break;

      case TEXT:
      f.setTextValue(getTextValue());
      break;
      
      case LIST:
      for (Flow flow : listValue){
        f.addToList(flow.copyFlow());
      }
      break;
      
      case MODULE:
      f.setModuleValue(getModuleValue());
      break;
    }
    
    return f;
  }
   
}
