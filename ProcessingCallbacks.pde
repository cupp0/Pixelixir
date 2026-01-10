
//~ProcessingCallbacks
void mouseMoved()      { globalInputMan.handleMouseEvent(Action.MOUSE_MOVED); }
void mouseDragged()    { globalInputMan.handleMouseEvent(Action.MOUSE_DRAGGED); }
void mousePressed()    { globalInputMan.handleMouseEvent(Action.MOUSE_PRESSED); }
void mouseReleased()   { globalInputMan.handleMouseEvent(Action.MOUSE_RELEASED); }
void mouseClicked()    { globalInputMan.handleMouseEvent(Action.MOUSE_CLICKED); }
void mouseWheel(processing.event.MouseEvent e) { globalInputMan.handleMouseWheel(e.getCount()); }

void keyPressed()      { globalInputMan.handleKeyEvent(Action.KEY_PRESSED, key, keyCode); }
void keyReleased()     { globalInputMan.handleKeyEvent(Action.KEY_RELEASED, key, keyCode); }
void keyTyped()        { globalInputMan.handleKeyEvent(Action.KEY_TYPED, key, keyCode); }
