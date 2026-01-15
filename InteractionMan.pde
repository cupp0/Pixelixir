enum InteractionState{
  NONE,
  DRAGGING_MODULES, 
  DRAGGING_UI,
  DRAGGING_OPEN_CONNECTION,
  RESIZING_UI,
  DRAGGING_SLIDER,
  HOLDING_BUTTON,
  PANNING,
  SELECTING_MODULES,
  SELECTING_UI,
  TYPING,
  MENU_OPEN,
  WINDOW_TRANSITION_IN,
  WINDOW_TRANSITION_OUT
}

class InteractionMan{

  Window scope;
  Interactable target;
  InteractionState state = InteractionState.NONE;
  
  InteractionMan(Window scope_){
    scope = scope_;
  }
  
  void update(HoverMan h, HumanEvent e){
    
    resolveTarget(h, e);
    
    if(target != null){
      StateChange newInfo = target.onInteraction(e);
      applyStateChange(newInfo);
    }
  }
  
  //in general, if we are in an interaction, don't change the interactable target
  //if we are not in an interaction, target should be what we are hovering
  //exceptions: MENU_OPEN (can interact with menu options or window
  //            MOUSE_WHEEL (interact with window no matter the hover)
  void resolveTarget(HoverMan h, HumanEvent e){
    
    if (state == InteractionState.MENU_OPEN){
      target = h.currentHover.ui; 
    }
    
    if (state == InteractionState.NONE && e.input.action == Action.MOUSE_WHEEL){
      target = scope;
      return;
    }
    
    if (!(state == InteractionState.NONE)) return;
    
    target = h.currentHover.ui;
  }
  
  void applyStateChange(StateChange newInfo){
    switch(newInfo.stateAction){
      case ADD : 
      state = newInfo.interactionState;
      target = newInfo.ui; 
      break;
      
      case REMOVE : 
      state = InteractionState.NONE; //reset target
      target = null;
      break;
      
      default: //DO_NOTHING
      break;
    }
  }
}
