
//~ProcessingCallbacks
void mouseMoved()      { globalInputManager.handleMouseEvent(Action.MOUSE_MOVED); }
void mouseDragged()    { globalInputManager.handleMouseEvent(Action.MOUSE_DRAGGED); }
void mousePressed()    { globalInputManager.handleMouseEvent(Action.MOUSE_PRESSED); }
void mouseReleased()   { globalInputManager.handleMouseEvent(Action.MOUSE_RELEASED); }
void mouseClicked()    { globalInputManager.handleMouseEvent(Action.MOUSE_CLICKED); }
void mouseWheel(processing.event.MouseEvent e) { globalInputManager.handleMouseWheel(e.getCount()); }

void keyPressed()      { globalInputManager.handleKeyEvent(Action.KEY_PRESSED, key, keyCode); }
void keyReleased()     { globalInputManager.handleKeyEvent(Action.KEY_RELEASED, key, keyCode); }
void keyTyped()        { globalInputManager.handleKeyEvent(Action.KEY_TYPED, key, keyCode); }
