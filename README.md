# Pixelixir
An Image Processor with a PureData-esque presentation. Build your own image processing tools using a variety of fundamental modules.
<br/>
1. Install [Processing](https://processing.org/download/).
2. Install ControlP5, The Midibus, and Intel RealSense for Processing. Processing makes this easy. Sketch > Import Library > Add Library. Find the 3 libraries in the list. 
3. open and run Pixelixir.pde!
<br/>
I'll publish instructional content soon. If you'd like to take a swing in the mean time, here is a very brief rundown of the workflow:
<br/>
<br/>
- The menu on the left hand side contains all available modules you can use to build a patch. At the top left are controls that hide the menu, activate help mode (You will want to click that every time you run the program while you're learning), change the output resolution of your patch, and controls to save/load a patch.
<br/>
- Click on the buttons next to the labels to add modules to the patch. Some modules (D435 and Midi) require additional hardware and configuration to use. 
<br/>
- To connect modules, click an output node (bottom of the module) followed by another module's input node (top of the module). Start with a module from the GENERATOR section. To view the output of your patch, create a display module and connect either a generator to it or some module that has a generator upstream.
<br/> 
- To learn how a module works, hover its drag node (black node, top center) while help mode is active. A help box will appear and hopefully give you enough info to go off! There are certainly documentation gaps that I plan to address. In addition, there are a number of bugs, some of which can crash the sketch. I'm in the process of addressing those scenarios.
<br/>
<br/>
Many thanks to all of the wonderful people who make and maintain Processing and all the tools built thereon!
<br/>

