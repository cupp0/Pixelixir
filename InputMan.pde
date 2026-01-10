//~InputMan
class InputMan {

    private InputState state = new InputState();

    public InputState getState() {
      return state;
    }
    
    void update(GlobalInputEvent e){
      switch(e.action){
        case MOUSE_PRESSED:
        addMousePress(e.mouseButt);
        break;
        
        case MOUSE_RELEASED:
        removeMousePress(e.mouseButt);
        break;
        
        case KEY_PRESSED:
        addKey(e.theKeyCode);
        break;
        
        case KEY_RELEASED:
        removeKey(e.theKeyCode);
        break;
      }
      //state.printState();
    }

    // ---- KEYBOARD ----

    public void addKey(int keyCode) {
      if (!state.downKeys.contains(keyCode)) {
        state.downKeys.add(keyCode);
        state.justPressedKeys.add(keyCode);
      }
    }

    public void removeKey(int keyCode) {
      if (state.downKeys.contains(keyCode)) {
        state.downKeys.remove(keyCode);
        state.justReleasedKeys.add(keyCode);
      }
    }

    public void addKeyTyped(char c) {
      state.typedCharacters.add(c);
    }

    // ---- MOUSE ----

    public void addMousePress(int button) {
      if (!state.downMouseButtons.contains(button)) {
        state.downMouseButtons.add(button);
        state.justPressedMouseButtons.add(button);
      }
    }

    public void removeMousePress(int button) {
      if (state.downMouseButtons.contains(button)) {
        state.downMouseButtons.remove(button);
        state.justReleasedMouseButtons.add(button);
      }
    }

    // ---- END OF FRAME ----

    public void endFrame() {
      state.clearTransient();
    }
}
