//~Menu
abstract class Menu<T>{
  
  final MenuListener listener;             //window Man that needs menu info
  T target;
  PVector pos;
  PVector optionSize = new PVector(100, 20);
  ArrayList<MenuOption> options = new ArrayList<MenuOption>();
  Menu activeSubmenu;                        //only display one menu at a time

  Menu(MenuListener ml, T target_, PVector pos_) {
    listener = ml; target = target_; setPosition(pos_);
  }

  // Subclasses populate options here
  abstract void build();

  abstract Window getWindow();
  
  void display() {
    fill(0);
    stroke(0);
    strokeWeight(2);
    textAlign(LEFT);
    rect(pos.x, pos.y, optionSize.x, options.size()*optionSize.y, 4);

    // Options
    for (MenuOption mo : options){
      mo.display();
    }
  }
  
  void addRetreatOption(Menu source, Menu destination){
    options.add(new MenuOption(source, "<", 0) {
      void execute() {
        listener.switchMenu(destination, parent.pos);
      }
    });
  }
  
  ArrayList<MenuOption> getOptions(){
    return options;
  }
  
  void setPosition(PVector pos_){
    pos = pos_.copy(); 
  }
 
}
