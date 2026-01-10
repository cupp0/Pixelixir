enum StateAction {ADD, REMOVE, DO_NOTHING}

class StateChange {
  
  StateAction stateAction;
  InteractionState interactionState;
  Interactable ui;
  
  StateChange(StateAction  s, InteractionState i, Interactable ui_){
    stateAction = s; interactionState = i; ui = ui_;
  }
  
  StateChange(StateAction  s){
    stateAction = s;
  }
   
}
