//~TextfieldUI
class TextfieldUI extends DBUI{
  
  int cursorPos = 0;
  boolean isFocus = false;
  
  TextfieldUI() {
    super();
    name = "textfield"; setSize(new PVector(30, 18));
  }

  void display() {
    rect(getAbsolutePosition().x, getAbsolutePosition().y, size.x, size.y, roundOver);    
    stroke(255);
    fill(255);
    
    String currentText = getUIPayload().getTextValue();
    int index = max(currentText.length()-3, 0);
    text(currentText.substring(index), getAbsolutePosition().x+5, getAbsolutePosition().y+size.y/2);

    if (isFocus) {
      // Draw blinking cursor
      int blinkPeriod = 30; // frames
      if ((frameCount % blinkPeriod) < blinkPeriod/2) {
        float tw = textWidth(currentText.substring(0, min(3,cursorPos)));
        line(getAbsolutePosition().x+7+tw, getAbsolutePosition().y+3, getAbsolutePosition().x+7+tw, getAbsolutePosition().y+size.y-3);
      }
    }
    
    displayIdentity();
  }

  void onInteraction(HumanEvent e){
    
    String currentText = getUIPayload().getTextValue();   
    if (e.input.action == Action.MOUSE_PRESSED){
      // Move cursor to click position
      if (!isFocus){
        isFocus = true;
        float mx = e.xMouse - (state.pos.x+5);
        cursorPos = findCursorIndex(mx);
      } else { 
        isFocus = false; 
      }
    }
    if (e.input.action == Action.KEY_PRESSED){
      if (e.input.theKey == BACKSPACE) {
        if (cursorPos > 0) {
          currentText = currentText.substring(0, cursorPos-1) + currentText.substring(cursorPos);
          cursorPos--;
        }
      } else if (e.input.theKey == DELETE) {
        if (cursorPos < currentText.length()) {
          currentText = currentText.substring(0, cursorPos) + currentText.substring(cursorPos+1);
        }
      } else if (e.input.theKeyCode == LEFT) {
        cursorPos = max(0, cursorPos-1);
      } else if (e.input.theKeyCode == RIGHT) {
        cursorPos = min(currentText.length(), cursorPos+1);
      } else if (e.input.theKey >= 32 && e.input.theKey != CODED) { 
        // Printable characters only
        currentText = currentText.substring(0, cursorPos) + e.input.theKey + currentText.substring(cursorPos);
        cursorPos++;
      }
     
      //create UI event
      state.onLocalEvent(new UIPayload(currentText));
    }    
  }

  // Figure out which character index corresponds to a pixel position
  int findCursorIndex(float mx) {
    
    String currentText = getUIPayload().getTextValue();   
    for (int i = 0; i <= currentText.length(); i++) {
      if (textWidth(currentText.substring(0, i)) > mx) {
        return i;
      }
    }
    return currentText.length();
  }
}
