class HumanEvent {
  final GlobalInputEvent input;                  //raw input layer
  final float xMouse, yMouse, pxMouse, pyMouse;  //mouse info translated to world coords
  final HoverTarget hover;                       //currentWindow level info about what's hovered
  
  HumanEvent(GlobalInputEvent input_, float xMouse_, float yMouse_, float pxMouse_, float pyMouse_, HoverTarget hover_) {
    this.input = input_;
    this.xMouse = xMouse_;
    this.yMouse = yMouse_;
    this.pxMouse = pxMouse_;
    this.pyMouse = pyMouse_;
    this.hover = hover_;
  }
}
