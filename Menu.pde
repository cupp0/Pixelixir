//~Menu
abstract class Menu<T>{
  
  final MenuListener listener;             //window Man that needs menu info
  T target;
  PVector targetPos, actualPos;
  PVector optionSize = new PVector(100, 20);
  ArrayList<MenuOption> options = new ArrayList<MenuOption>();
  Menu activeSubmenu;                        //only display one menu at a time

  Menu(MenuListener ml, T target_) {
    listener = ml; target = target_;;
  }

  //subclasses populate
  abstract void addOptions();
  
  //ensure menu stays on screen
  void determineActualPosition(){
    actualPos = targetPos.copy();
    if (actualPos.x+optionSize.x > width){
      drag(new PVector(-((actualPos.x+optionSize.x)%width), 0));
    }
    if (actualPos.y+(options.size()*optionSize.y) > height){
      drag(new PVector(0, (-(actualPos.y+(options.size()*optionSize.y))%height)));
    }
  }

  abstract Window getWindow();
  
  void display() {
    fill(0);
    stroke(0);
    strokeWeight(2);
    textAlign(LEFT);
    rect(actualPos.x, actualPos.y, optionSize.x, options.size()*optionSize.y, 4);

    // Options
    for (MenuOption mo : options){
      mo.display();
    }
  }
  
  void drag(PVector amount){
    actualPos.add(amount); 
  }
  
  void addRetreatOption(Menu source, Menu destination){
    options.add(new MenuOption(source, "<", 0) {
      void execute() {
        listener.switchMenu(destination, parent.targetPos);
      }
    });
  }
  
  ArrayList<MenuOption> getOptions(){
    return options;
  }
  
  void setTargetPosition(PVector pos_){
    targetPos = pos_.copy(); 
    determineActualPosition();
  }
 
}
