import java.util.*;
import java.lang.reflect.*;
import java.util.function.BinaryOperator;
import java.io.*;
import javax.swing.JOptionPane;
import com.google.gson.*;

//~Modules
//these are available default modules. Unless you want to make a custom UI element, making a new Operator
//involves adding its label somewhere here and making a corresonding Operator class. For instance,
//add "filter" here and some class FilterOperator extends PrimeOperator and it will show up in add module
//options

String[] UI = {"UI", "slider",  "button", "switch", "textfield", "display", "composite"};
String[] binary = {"BINARY", "add", "subtract", "multiply", "divide", "power", "modulus"};
String[] unary = {"UNARY", "sin", "cos", "tan", "abs"};
String[] logic = {"LOGIC", "and", "or", "xOr", "not", "lessThan", "greaterThan", "equals"};
String[] utility = {"UTILITY", "print", "toFloat", "list", "read", "write", "set", "get", "copy", "valve", "concat", "split", "send", "receive"};
String[] meta = {"META", "mouseX", "mouseY", "leftMouse", "rightMouse", "mouseWheel", "key", "toModule", "drag", "moduleX", "moduleY"};

String[][] UIText = {UI, binary, unary, logic, utility, meta};

color UICol = color(125, 100, 175);
color binaryCol = color(175, 100, 125);
color unaryCol = color(175, 100, 255);
color logicCol = color(175);
color comparisonCol = color(125, 175, 125);
color utlityCol = color(75);

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
  Module m = partsFactory.createModule("composite");
  bigbang = new Window(m);
  windows.put(m, bigbang);
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
  println(graph.allOps.size()+" operators, " + graph.edges.size() + " edges");
  graph.primerContinousUpdaters();         // locate and create notifications at any continuous port
  graph.generateEvaluationSequence();      // generate a global evaluation sequence based on who has new data
  currentWindow.display();                 // display UI before evaluating cause we use info about who is evaluating
  graph.evaluate();                        // evaluate the graph
  
}
