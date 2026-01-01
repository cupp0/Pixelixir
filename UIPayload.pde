//~Payload
enum PayloadType {
  NUMERIC,
  BOOL,
  TEXT,
  IMG
}

class UIPayload {  
  
  PayloadType type;
  float floatValue;
  String textValue;
  boolean boolValue;
  transient PImage imgValue;
  
  UIPayload(float value_){
    type = PayloadType.NUMERIC; floatValue = value_;
  }
  
  UIPayload(String value_){
    type = PayloadType.TEXT; textValue = value_;
  }
  
  UIPayload(boolean value_){
    type = PayloadType.BOOL; boolValue = value_;
  }
  
  UIPayload(PImage value_){
    type = PayloadType.IMG; imgValue = value_;
  }
  
  float getFloatValue(){ return floatValue; }
  String getTextValue(){ return textValue; }
  boolean getBoolValue(){ return boolValue; }
  PImage getImgValue(){ return imgValue; }
  
  Object getValue(){
    switch (type){
      case NUMERIC: return floatValue;
      case TEXT: return textValue;
      case BOOL: return boolValue;
      case IMG: return imgValue;
    }
    return null;
  }
  
  PayloadType getType(){
    return type;
  }
}
