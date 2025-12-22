//~InputManager
class InputManager {

    private InputState state = new InputState();

    public InputState getState() {
      return state;
    }
    
    void update(HumanEvent e){
      switch(e.input.action){
        case MOUSE_PRESSED:
        addMousePress(e.input.mouseButt);
        break;
        
        case MOUSE_RELEASED:
        removeMousePress(e.input.mouseButt);
        break;
        
        case KEY_PRESSED:
        addKey(e.input.theKeyCode);
        break;
        
        case KEY_RELEASED:
        removeKey(e.input.theKeyCode);
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
