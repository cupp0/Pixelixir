class InputState {
  
    Set<Integer> downKeys = new HashSet<>();
    Set<Integer> justPressedKeys = new HashSet<>();
    Set<Integer> justReleasedKeys = new HashSet<>();

    ArrayList<Character> typedCharacters = new ArrayList<>();

    Set<Integer> downMouseButtons = new HashSet<>();
    Set<Integer> justPressedMouseButtons = new HashSet<>();
    Set<Integer> justReleasedMouseButtons = new HashSet<>();

    // Call at end of frame
    void clearTransient() {
        justPressedKeys.clear();
        justReleasedKeys.clear();
        justPressedMouseButtons.clear();
        justReleasedMouseButtons.clear();
        typedCharacters.clear();
    }
    
    public void printState(){
      println("~~~");
      for (Integer i : downKeys){
        print(i);
      }
    }
    
    public boolean isDown(int keyCode) {
      return downKeys.contains(keyCode);
    }

    public boolean justPressed(int keyCode) {
      return justPressedKeys.contains(keyCode);
    }

    public boolean justReleased(int keyCode) {
      return justReleasedKeys.contains(keyCode);
    }

    public boolean combo(int... keyCodes) {
      for (int key : keyCodes) {
        if (!downKeys.contains(key)) return false;
      }
      return true;
    }

}
