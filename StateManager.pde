enum InteractionState {
  NONE,
  HOVERING_UI,
  HOVERING_CONNECTION,
  DRAGGING_MODULES,
  DRAGGING_UI,
  DRAGGING_OPEN_CONNECTION,
  RESIZING_UI,
  DRAGGING_SLIDER,
  PANNING,
  ZOOMING,
  RIGHT_MOUSE_DOWN,
  SELECTING_MODULES,
  SELECTING_UI,
  HOLDING_BUTTON,
  TYPING, 
  MENU_OPEN, 
}

//~StateManager
class StateManager{
  
  ArrayList<InteractionState> currentStates = new ArrayList<InteractionState>();
  
  StateManager(){}
  
  boolean containsAll(InteractionState ... states){
    for (InteractionState s : states){
      if (!currentStates.contains(s)){
        return false;
      }
    }    
    return true;
  }
  
  void addState(InteractionState s){
    currentStates.add(s);
  }
  
  void removeState(InteractionState s){
    for (int i = currentStates.size() - 1; i >=0; i--){
      if (currentStates.get(i) == s){
        currentStates.remove(i);
      }
    }
    println("removed nothing from state");
  }
  
}
