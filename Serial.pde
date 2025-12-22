//~Serial

class ModuleData {
  String name;
  String id;
  int ins, outs;
  PVector position;
  ArrayList<UIState> uiElements = new ArrayList<UIState>(); //should only serialize when the state is different from default (or if composite)  
  WindowData subwindow;                                       //for composites
}

class ConnectionData {
  String fromModule;
  int fromPortIndex;
  String toModule;
  int toPortIndex;
}

class WindowData {
  ArrayList<ModuleData> modules = new ArrayList<ModuleData>();
  ArrayList<ConnectionData> connections = new ArrayList<ConnectionData>();
}

class ViewState {
  float zoom = 1.0f;
  float panX = 0;
  float panY = 0;
}
