//~DBUI
//base class for any UI whose state is a databender (affects/affected by
//data the program generates
abstract class DBUI extends ModuleUI<DBUIState> implements Interactable{
  
  abstract void onInteraction(HumanEvent e);
  
  UIPayload getUIPayload(){
    return ((DBUIState)state).getData();
  }
  
  void displayIdentity(){
    HoverTarget h = parent.getWindow().windowManager.hoverManager.getCurrent();
    if (h.modUI == this){
      if (state.identityToken != null){
        PVector p = getAbsolutePosition().copy();
        fill(255);
        text(state.identityToken, p.x, p.y+5);
      }
    }
  }

}
