/*

  Reverse Polish Notation calculator. Wants a String to evaluate. Elligible inputs:
  
  x - variable 1
  y - variable 2
  p - 3.141..
  e - 2.718..
  * - multiply
  / - divide
  + - plus
  - - minus
  ^ - power
  % - modulus
  r - sqrt
  s - sine
  c - cosine
  a - absolute value  
  single digit values
  
  examples:
  
  "|x-y|" would be written "xy-a"
  "sin(x)+cos(y)" would be written "xsyc+"  
  "9x - y^2" would be written "9x*y2^-"  
  
*/

class Expression{  

  boolean first;
  ArrayList<Float> expStack = new ArrayList<Float>();
  String text;
  float[] data;
  
  Expression(String text_){
    text = text_;
  }
  
  void evaluateOverField(int minX, int minY, int maxX, int maxY){
    first = true;
    data  = new float[globalWidth*globalHeight];
    for (int i = 0; i < globalWidth; i++){
      for (int j = 0; j < globalHeight; j++){
       float x = map(i, 0, globalWidth, minX, maxX);
       float y = map(j, 0, globalHeight, minY, maxY);
       data[i+j*globalWidth] =  evaluate(x, y);
      }
    }
  }
  
  void evaluateModule(int in1, int in2, int out){
    for (int i = 0; i < globalWidth; i++){
      for (int j = 0; j < globalHeight; j++){
        int loc = i+j*globalWidth;
        stack.get(out).data[loc] = evaluate(stack.get(in1).data[loc], stack.get(in2).data[loc]);
      }
    }
  }
  
  float evaluate(float x, float y){
    float temp = 0;
    for (int i = 0; i < text.length(); i++){
      switch(text.charAt(i)){
      case 'x' :
        expStack.add(x);
        break;
      case 'y' :
        expStack.add(y);  
        break;
      case 'p' :
        expStack.add(3.14159);
        break;
      case 'e' :
        expStack.add(2.71828);
        break;
      case '*' :
        temp = expStack.get(expStack.size()-2)*expStack.get(expStack.size()-1);
        expStack.remove(expStack.size()-2);
        expStack.remove(expStack.size()-1);
        expStack.add(temp);
        break;
      case '/' :
        temp = expStack.get(expStack.size()-2)/expStack.get(expStack.size()-1);
        expStack.remove(expStack.size()-2);
        expStack.remove(expStack.size()-1);
        expStack.add(temp);
        break;
      case '+' :
        temp = expStack.get(expStack.size()-2)+expStack.get(expStack.size()-1);
        expStack.remove(expStack.size()-2);
        expStack.remove(expStack.size()-1);
        expStack.add(temp);
        break;
      case '-' :
        temp = expStack.get(expStack.size()-2)-expStack.get(expStack.size()-1);
        expStack.remove(expStack.size()-2);
        expStack.remove(expStack.size()-1);
        expStack.add(temp);
        break;
      case '^' :
        temp = pow(expStack.get(expStack.size()-2), expStack.get(expStack.size()-1));
        expStack.remove(expStack.size()-2);
        expStack.remove(expStack.size()-1);
        expStack.add(temp);
        break;
      case '%' :
        temp = expStack.get(expStack.size()-2)%expStack.get(expStack.size()-1);
        expStack.remove(expStack.size()-2);
        expStack.remove(expStack.size()-1);
        expStack.add(temp);  
      case 'r' :
        temp = sqrt(expStack.get(expStack.size()-1));
        expStack.remove(expStack.size()-1);
        expStack.add(temp);
        break;
      case 's' :
        temp = sin(expStack.get(expStack.size()-1));
        expStack.remove(expStack.size()-1);
        expStack.add(temp);
        break;
      case 'c' :
        temp = cos(expStack.get(expStack.size()-1));
        expStack.remove(expStack.size()-1);
        expStack.add(temp);
        break; 
      case 'a' :
        temp = abs(expStack.get(expStack.size()-1));
        expStack.remove(expStack.size()-1);
        expStack.add(temp);
        break; 
      default :
        expStack.add(float(str(text.charAt(i))));
        break;  
      }
    }
    
    float finalAnswer = expStack.get(0);
    expStack.remove(0);
    if (Float.isNaN(finalAnswer) || !Float.isFinite(finalAnswer)){
      return 0;
    } else {
      return finalAnswer;
    }
  }
}
