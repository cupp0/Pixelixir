//~PartsFactory

//relies on reflection, meaning Operator class names, as well as UI and UIState names, must
//comply with the naming convention thoroughly demonstrated. Doing this so adding new stuff
//requires minimal code

class PartsFactory{
    
  //~createModule
  Module createModule(String name){
    //create Module
    Module newMod = new Module(name);
    
    //create the operator that will own this module
    Operator newOp = (Operator)createPart(name, "Operator"); 
    if (newOp instanceof CompositeOperator){
      ((CompositeOperator)newOp).initializeWindow();
    }
    
    //establish module/op relationship
    newOp.setListener(newMod);
    newMod.setOwner(newOp);
    
    //add default UI element, if needed. This just checks the module names in our button menu. 
    //Anything in the UI sublist has default UI we need to add
    ModuleUI defaultUI = createDefaultUI(name);
       
    if (defaultUI != null){
      newMod.addUI(defaultUI);
      
      if (newMod.owner instanceof DisplayOperator){
        ((DisplayOperator)newMod.owner).setDataListener((DisplayUIState)defaultUI.state);
      }
    }    
    
    //set body (and eye) color
    newMod.uiBits.get(0).setColor(newMod.getColor());
    if (newMod.owner instanceof CompositeOperator){
      newMod.uiBits.get(0).setColor(windows.get(newMod.owner).getColor());
      newMod.uiBits.get(1).setColor(windows.get(newMod.owner).getColor());
    }

    return newMod;    
  }
  
  //~createUI
  ModuleUI createUI(String name){
    //create and return ui/state pair
    ModuleUI newUI = (ModuleUI)createPart(name, "UI");
    UIState newUIState = (UIState)createPart(name, "UIState");
    newUI.setState(newUIState);        
    return newUI;
  }
  
  //scans menu buttons and returns corresponding UI if we have a hit
  //~createDefaultUI
  ModuleUI createDefaultUI(String name){

    for (String s : UI){
      if (s.equals(name)){        
        return createUI(name);
      }
    }
    
    return null;
  }
  
  //uses reflection to create the correct object, assumes String name needs capitalized
  //and that partType is already formatted correctly, options are "Operator", "UI", "UIState"
  
  //~createPart
  private Object createPart(String name, String partType){
    String capitalizedName = name.substring(0, 1).toUpperCase() + name.substring(1);
    String className = capitalizedName + partType;
    try {
      String outer = sketchRef().getClass().getName();
      String candidateInner = outer + "$" + className; // inner class form
      String candidateTop = className;                 // top-level fallback
  
      Class<?> cls;
      try {
        cls = Class.forName(candidateInner);
      } catch (ClassNotFoundException e) {
        cls = Class.forName(candidateTop);
      }
      
      
      Object obj;
  
      try {
        // Try inner-class constructor that takes the outer instance
        Constructor<?> ctor = cls.getDeclaredConstructor(sketchRef().getClass());
        obj = ctor.newInstance(sketchRef());
      } catch (NoSuchMethodException e) {
        // Fallback: zero-argument constructor
        obj = cls.getDeclaredConstructor().newInstance();
      }
      //here's our part!
      return obj;
      
    } catch (Exception e) {
      e.printStackTrace();
    }
    return null;
  }
}
