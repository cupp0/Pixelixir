//~Menu
abstract class Menu<T>{
  
  final MenuListener listener;             //window manager that needs menu info
  T target;
  PVector pos;
  PVector optionSize = new PVector(100, 20);
  ArrayList<MenuOption> options = new ArrayList<MenuOption>();
  Menu activeSubmenu;

  Menu(MenuListener ml, T target_) {
    listener = ml; target = target_;
  }

  // Subclasses populate options here
  abstract void build();

  abstract Window getWindow();
  
  void display() {

    fill(0);
    stroke(0);
    strokeWeight(2);
    rect(pos.x, pos.y, optionSize.x, options.size()*optionSize.y, 4);

    // Options
    for (MenuOption mo : options){
      mo.display();
    }
  }
  
  //index used to position submenu
  void addSubmenu(Menu newMenu, int index){
    
    //if a submenu is already open, close it and reassign activeSubmenu
    if (activeSubmenu != null){
      listener.onMenuExecution(activeSubmenu);
    }
    activeSubmenu = newMenu;
    
    PVector p = PVector.add(this.pos, new PVector(optionSize.x, index*optionSize.y));
    listener.addMenu(newMenu, p);    
    
  }
  
  ArrayList<MenuOption> getOptions(){
    return options;
  }
  
  void setPosition(PVector pos_){
    pos = pos_.copy(); 
    for (int i = 0; i < options.size(); i++){
      options.get(i).setPosition(new PVector(0, i*optionSize.y));
    }
  }
  
  Menu getRootMenu(){
    return ((WindowManager)listener).activeMenus.get(0); 
  }

}
