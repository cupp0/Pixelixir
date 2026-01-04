import java.util.*;
import java.lang.reflect.*;
import java.util.function.BinaryOperator;
import java.io.*;
import javax.swing.JPanel;
import javax.swing.JFileChooser;

import com.google.gson.*;

//~Modules
//these are available default modules. Saved modules go in the sketch /data/patches folder. Unless you 
//want to make a custom UI element, making a new Operator only involves adding its label here and 
//making a corresonding Operator class. For instance, add "filter" here and some class FilterOperator 
//extends PrimeOperator and it will show up in add module options

String[] UI = {"UI", "slider",  "button", "switch", "textfield", "display", "composite"};
String[] binary = {"BINARY", "add", "subtract", "multiply", "divide", "power", "modulus"};
String[] unary = {"UNARY", "sin", "cos", "tan", "acos", "asin", "atan", "abs", "sqrt"};
String[] logic = {"LOGIC", "and", "or", "xOr", "not", "lessThan", "greaterThan", "equals"};
String[] list = {"LIST", "list", "append", "remove", "set", "get", "concat", "split"};
String[] utility = {"UTILITY", "print", "iterator", "toFloat", "read", "write", "copy", "valve", "send", "receive", "delay"};
String[] meta = {"META", "time", "mouseX", "mouseY", "leftMouse", "rightMouse", "mouseWheel", "key", "drag", "moduleX", "moduleY", "window", "moduleList", "getModule", "inList", "outList", "connect", "addModule"};

String[][] UIText = {UI, binary, unary, logic, list, utility, meta};

color UICol = color(125, 100, 175);
color binaryCol = color(175, 100, 125);
color unaryCol = color(175, 100, 255);
color logicCol = color(175);
color comparisonCol = color(125, 175, 125);
color utlityCol = color(75);

Module mama;
Window bigbang;
Window currentWindow;
Graph graph = new Graph();
GlobalInputManager globalInputManager = new GlobalInputManager();
SelectionManager selectionManager = new SelectionManager();
IdentityManager identityManager = new IdentityManager();
PartsFactory partsFactory = new PartsFactory();        
FlowRegistry flowRegistry = new FlowRegistry(); 
NoiseGenerator noiseGen = new NoiseGenerator();
Gson gson; 

HashMap<Module, Window> windows = new HashMap<Module, Window>(); //composite module, window that ops kids display in
HashMap<String, Window> windowByBoundaryID = new HashMap<String, Window>(); //t ops kids display in

int portSize = 8;
int portGap = 12;
int roundOver = 10;

public void settings(){
  size(800, 800, P3D);
}  

void setup() {
  frameRate(24);
  hint(DISABLE_OPTIMIZED_STROKE);
  rectMode(CORNER);
  
  //initialize module space
  mama = partsFactory.createModule("composite");
  bigbang = new Window(mama);
  windows.put(mama, bigbang);
  windowByBoundaryID.put(mama.id, bigbang);
  currentWindow = bigbang;

  //make type adapters for UIState extensions (so we can serialize abstract UIState)
  RuntimeTypeAdapterFactory<UIState> uiStateAdapter =
    RuntimeTypeAdapterFactory.of(UIState.class, "type")
      .registerSubtype(ButtonUIState.class, "button")
      .registerSubtype(SwitchUIState.class, "switch")
      .registerSubtype(SliderUIState.class, "slider")
      .registerSubtype(TextfieldUIState.class, "textfield")
      .registerSubtype(InPortUIState.class, "inPort")
      .registerSubtype(OutPortUIState.class, "outPort")
      .registerSubtype(BodyUIState.class, "body")
      .registerSubtype(CompositeUIState.class, "eye")
      .registerSubtype(DisplayUIState.class, "display");

  gson = new GsonBuilder()
    .registerTypeAdapterFactory(uiStateAdapter)
    .setPrettyPrinting()
    .create();

}
  
void draw(){
  //println(graph.allOps.size()+" operators, " + graph.edges.size() + " edges");
  graph.primerContinousUpdaters();         // locate and create notifications at any continuous port
  graph.generateEvaluationSequence();      // generate a global evaluation sequence based on who has new data
  currentWindow.display();                 // display UI before evaluating cause we use info about who is evaluating
  graph.evaluate();                        // evaluate the graph
  
}
