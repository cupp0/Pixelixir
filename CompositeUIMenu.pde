//CompositeUIMenu
class CompositeUIMenu extends Menu<Module>{
  
  CompositeUIMenu(MenuListener ml, Module m){
    super(ml, m);
    addOptions();
  }

  void addOptions() {
    addRetreatOption(this, new WindowMenu(listener, ((WindowMan)listener).scope));
    for (int i = 1; i < UI.length-1; i++){ //exclude Eye. We only want one eye per module
      options.add(new MenuOption(this, UI[i], i) {
        void execute() {
          ((Module)target).addUI(partsFactory.createUI(label));
          ((Module)target).organizeUI();
        }
      });
    }
  }
  
  Window getWindow(){
    return ((Module)target).getWindow();
  }
}
