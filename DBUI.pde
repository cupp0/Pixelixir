//~DBUI
//base class for any UI whose state is a databender (affects/affected by
//data the program generates
abstract class DBUI extends ModuleUI<DBUIState> {
    
  UIPayload getUIPayload(){
    return ((DBUIState)state).getData();
  }
  
  void displayIdentity(){
    HoverTarget h = parent.getWindow().windowMan.stateMan.hoverMan.getCurrent();
    //if (h.ui == this){
    //  if (state.identityToken != null){
    //    PVector p = getAbsolutePosition().copy();
    //    fill(255);
    //    text(state.identityToken, p.x, p.y+5);
    //  }
    //}
  }
  
  //ui subclasses define this
  abstract StateChange interaction(HumanEvent e);
  
  StateChange onInteraction(HumanEvent e){     
    StateMan sm = getWindow().windowMan.stateMan;
    
    //shift interaction handled by parent class for now
    if (sm.inputMan.state.isDown(SHIFT) || sm.interactionMan.state == InteractionState.DRAGGING_UI){
      return super.onInteraction(e);
    }
    
    //if already doing something (sliding, typing, etc.. continue that interaction
    if (!sm.isInteractionState(InteractionState.NONE)){return interaction(e);}
    
    //otherwise initiate ui interaction
    if (sm.isMouseDoing(Action.MOUSE_PRESSED, LEFT)){return interaction(e);}
    
    //right click for menu
    if (sm.isMouseDoing(Action.MOUSE_PRESSED, RIGHT)){
      getWindow().windowMan.addModuleUIMenu(this, new PVector(e.input.xMouse, e.input.yMouse));
      return new StateChange(StateAction.ADD, InteractionState.MENU_OPEN, this);
    }
    
    return new StateChange(StateAction.DO_NOTHING);
  }
  

}
