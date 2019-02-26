
boolean KINECT_ON = false;
boolean LOADING = false;

import java.util.ArrayList;

int delayTest = 0;
int currentX = 0, currentY = 0, currentZ = 0;
Line currentLine;

int lightX = 500, lightY = 500, lightZ = -100;
///////////////////////////////////////
int strokeVizWeight = 3;

// MODES
int VISUALIZE = 0;
//int ADD_NODES = 1;
//int ADD_EDGES = 2;
//int MOVE_NODES = 3;
int MOVE_LINES = 4;
//int SET_LINEZ = 5;
//int SET_CONST = 6;
//int SET_NODES_Z = 7;
//int DELETE_NODES = 8;
int MOVEABLE_LINES = 9;
int CALIBRATION = 10;
int SHOW_PERFECT = 11;
int mode = MOVE_LINES;

int currentScene = -1;
int visualMode = -1;
int kinectMode = -1; 
long sendTime = 0;
///////////////////////////////////////

long stringChecked = 0;
ArrayList<Line> lines;
PVector offset;
PVector nodeOffset;
float sc = 1.0;
int lineIndex = 0;
int triggered = -1;
int triggeredTime = 0;
int currentString;

// grid and balls
int zSpacing, rectW, rectH, numLinesY, numLinesX, numRectZ;
ArrayList<Ball> balls;
ArrayList<Shape> shapes;
int TOP_S = 0;
int BOTTOM_S = 1;
int LEFT_S = 2;
int RIGHT_S = 3;
int BACK_S = 4;
int X_ORIENT = 0;
int Y_ORIENT = 1;
int Z_ORIENT = 2;

long lastChecked = 0;
int visualIndex = 0;
int lastCheckedMode = 0;
color c1, c2;
color [] zColors;
float huePosition = 0;
int counter = 0;

void setup() {
  fullScreen(P3D);
  //size(800, 600, P3D);

  lines = new ArrayList<Line>();
  shapes = new ArrayList<Shape>();
  //nodes = new ArrayList<Node>();

  initScreens();
  initModes();
  initGrid(screen);
  setRects();



  colorMode(HSB, 255);

  zColors = new color[6];
  setRandomColors();
  //setColors();

  if (LOADING) {
    loadKeystone();
    loadLines();
  }
}


//--------------------------------------------------------------
void draw() {
  background(0);
  //translate(width/2, height/2);

  if (mode == VISUALIZE) {
    displayLines(strokeVizWeight, 0);
    visualize(screen);
    
  }
  else {
    visualizeSetting(screen);
    settingFunctions();
  }
  
}

void drawAllLines() {
  for (int j = 0; j < 6; j++) {
    for (int i = 0; i < 4; i++) {
      drawLineTopX(i, j, color(255));
      drawLineTopZ(i, j, color(255));

      drawLineBottomX(i, j, color(255));
      drawLineBottomZ(i, j, color(255));

      drawLineLeftY(i, j, color(255));
      drawLineLeftZ(i, j, color(255));

      drawLineRightY(i, j, color(255));
      drawLineRightZ(i, j, color(255));

      drawLineBackX(i, j, color(255));
      drawLineBackY(i, j, color(255));
    }
  }
}


void visualizeSetting(PGraphics g) {
  screen.beginDraw();
  screen.background(0);
  screen.pointLight(205, 205, 205, screen.width/2, screen.height/2, -100);
  screen.pushMatrix();
  screen.translate(screen.width/2, screen.height/2, 170);
  setGradientZs();
  if (mode != SHOW_PERFECT) {
    displayShapes(screen);
    //displayLines(strokeVizWeight, 255);
  } 
  //else displayPerfectLines(5, screen);

  screen.popMatrix();

  screen.stroke(255);
  screen.fill(255);
  screen.strokeWeight(strokeVizWeight);

  screen.endDraw();

  renderScreens();
}

void visualize(PGraphics g) {

  noCursor();
  screen.beginDraw();
  screen.background(0);
  screen.pointLight(205, 205, 205, lightX, lightY, lightZ); //-100);
  screen.pushMatrix();
  screen.translate(g.width/2, g.height/2, 170);
  //setRainbowPulse(20);
  setGradientZs();
  displayShapes(screen);
  screen.popMatrix();

  screen.stroke(255);
  screen.fill(255);
  screen.strokeWeight(strokeVizWeight);
  strokeWeight(strokeVizWeight);
  changeMode();
  playMode();
  screen.endDraw();

  renderScreens();
}
void changeMode() {
  if (millis() - lastCheckedMode > 8000) {
    if (int(random(2)) == 0) visualMode = V_DISPLAY;
    else visualMode = int(random(15));
    lastCheckedMode = millis();
  }
}

//--------------------------------------------------------------
void keyPressed() {
  if (key == 's') {
    saveShapes();
    saveKeystone();
    saveLines();
  } else if (key == 'r') {
    loadLines();
    loadKeystone();
  }
  //else if (key == 'a') mode = ADD_NODES;
  else if (key == 'e') {
    //mode = ADD_EDGES;
    automateLinesGeneration();
  } else if (key == 'm') mode = MOVE_LINES;
  else if (key == 't') mode = MOVEABLE_LINES;
  //else if (key == 'n') mode = MOVE_NODES;
  //else if (key == 'd') mode = DELETE_NODES;
  //else if (key == 'z') mode = SET_LINEZ;
  else if (key == 'p') mode = SHOW_PERFECT;
  else if (key == 'c') {
    mode = CALIBRATION;
    toggleCalibration();
  } 
  //else if (key == 'g') mode = SET_CONST;
  else if (key == 'v') mode = VISUALIZE;
  else if (key == 'x') printLineLength();
  else if (mode == MOVE_LINES) {
    if (currentLine != null) {
      if (keyCode == UP) currentLine.moveP1(0, -1);
      else if (keyCode == DOWN) currentLine.moveP1(0, 1);
      else if (keyCode == RIGHT) currentLine.moveP1(1, 0);
      else if (keyCode == LEFT) currentLine.moveP1(-1, 0);
      else if (key == 'i') currentLine.moveP2(0, -1);     
      else if (key == 'k') currentLine.moveP2(0, 1);     
      else if (key == 'l') currentLine.moveP2(1, 0);
      else if (key == 'j') currentLine.moveP2(-1, 0);
    }
  }


  return;
}

// get a string
// up, down, left, right -> p1
// i, k, j, l -> p2
boolean hasCurrentStringPoint() {
  return true;
}

//--------------------------------------------------------------
void keyReleased() {
}

//--------------------------------------------------------------
void mousePressed() {
}

//--------------------------------------------------------------
void mouseReleased() {
  if (mode == CALIBRATION) {
    updateLinePositions();
  }
}

void setLines() {
  for (int i = 0; i < lines.size(); i++) {
    Line l = lines.get(i);
    if (l.mouseOver()) {
      stroke(255);
      fill(255);
    } else if (i == lineIndex) {
      colorMode(RGB);
      stroke(0, 255, 255);
      fill(0, 255, 255);
    } else {
      colorMode(HSB);
      stroke(map(l.zs, 0, 9, 0, 255), 255, 255);
      fill(map(l.zs, 0, 9, 0, 255), 255, 255);
    }
    l.display();
  }
}



void setConst() {
  background(50);
  for (int i = 0; i < lines.size(); i++) {
    Line l = lines.get(i);
    if (l.mouseOver()) {
      stroke(255);
      fill(255);
    } else if (i == lineIndex) {
      colorMode(RGB);
      stroke(0, 255, 255);
      fill(0, 255, 255);
    } 
    l.display();
  }
}

//void updateLineZs() {
//  for (int i = 0; i < lines.size(); i++) {
//    lines.get(i).updateZ();
//  }
//}

void displayLineZDepth() {
  for (Line line : lines) {
    line.displayZDepth();
  }
}

void deleteLines(int index) {
  for (int i = lines.size() - 1; i >=0; i--) {
    //if (lines.get(i).findByID(index)) {
    //  lines.remove(i);
    //}
  }
}

void displayBox(int hue, String title) {
  if (mouseY < height - 60) {
    colorMode(HSB, 255);
    fill(hue, 255, 255);
    noStroke();
    rect(0, height-50, width, 50);
    fill(255);
    stroke(255);
    textSize(30);
    text(title, 30, height-15);
    colorMode(RGB, 255);
  }
}

void settingFunctions() {
  //displayNodes();
  //displayNodeLabels();



  if (mode == MOVE_LINES) {
    //displayCurrentNode();
    displayBox(70, "MOVE");
    displayLines(strokeVizWeight, 255);
    for (Line l : lines) {
      if (l.mouseOver()) {
        l.display(color(0, 0, 255));
        if (mousePressed) {
          currentLine = l;
        }
      }
    }
    if (currentLine != null) {
      currentLine.display(color(255, 0, 0));
    }
  } else if (mode == CALIBRATION) {
    displayBox(130, "CALIBRATING MAP");
    displayLines(strokeVizWeight, 255);
  } else if (mode == SHOW_PERFECT) {
    displayBox(140, "PERFECT LINES");
  }
}

void displayPerfectLines(int sw, PGraphics g) {
  for (Shape s : shapes) {
    ((MoveableShape)s).displayPerfect(sw, g);
  }
}

void displayZIndexes() {
  for (Line l : lines) {
    l.displayZIndex();
  }
}
boolean blackBackground() {
  if (kinectMode == K_PAINT) return false;
  return true;
}

void saveShapes() {
  processing.data.JSONObject json;
  json = new processing.data.JSONObject();
  json.setInt("num", shapes.size());
  saveJSONObject(json, "data/shapes/numShapes.json");
  for (Shape s : shapes) {
    s.saveShape();
  }
}

void loadShapes() {
  processing.data.JSONObject graphJson;
  graphJson = loadJSONObject("data/shapes/numShapes.json");
  int numShapes = graphJson.getInt("numShapes");

  shapes = new ArrayList<Shape>();
  for (int i = 0; i < numShapes; i++) {
    processing.data.JSONObject shape = loadJSONObject("data/shapes/shape_" + i + ".json");
    int num = shape.getInt("num");
    shapes.add(new Shape(num));
    processing.data.JSONArray ptsArray = shape.getJSONArray("ptsArray");
    for (int j = 0; j < ptsArray.size(); j+=3) {
      float x = ptsArray.getFloat(j);
      float y = ptsArray.getFloat(j+1);
      float z = ptsArray.getFloat(j+2);
      shapes.get(shapes.size() -1).addPoint(new PVector(x, y, z));
    }
  }
}

void displayShapes(PGraphics g) {
  for (int i = 0; i < shapes.size(); i++) {
    shapes.get(i).display(g);
  }
}

void rainbowStrip() {
  colorMode(HSB, 255);
  if (millis() - lastChecked > 500) {
    lastChecked = millis();
    visualIndex++;
    visualIndex %= 7;
    for (Shape s : shapes) {
      if (((MoveableShape) s).zSide == visualIndex) {
        s.c = color(map(((MoveableShape) s).zSide, 0, 7, 0, 255), 255, 255);
      } else s.c = color(map(((MoveableShape) s).zSide, 0, 7, 0, 255), 55, 55);
    }
  }
}

void setColors() {
  colorMode(HSB, 255);

  float hueJump = .1;

  // happens every second?
  if (millis() - lastChecked > 500) {
    huePosition += hueJump;
    if (huePosition > 1) {
      huePosition = 0;
      setNextRandomColor();
    }
    zColors[0] = lerpColor(c1, c2, huePosition);
    for (int i = zColors.length-1; i > 0; i--) {
      zColors[i] = zColors[i-1];
    }
    lastChecked = millis();
  }

  // all the time
  for (Shape s : shapes) {
    s.c = zColors[5-((MoveableShape) s).zSide];
    //s.c = color((hue(c)+frameCount)%255, 255, 255);
  }
}

void setNextRandomColor() {
  colorMode(HSB, 255);
  c2 = c1;
  c1 = color(random(255), 255, 255);
  //if (abs(hue(c1) - hue(c2)) < 40) {
  //  c2 = color((hue(c2)+80)%255, 255, 255);
  //}
}

void setRandomColors() {
  colorMode(HSB, 255);

  c1 = color(getRandomNormalizedHue(), 255, 255);
  //c2 = color(getRandomNormalizedHue(), 255, 255);
  c2 = color((hue(c2)+80)%255, 255, 255);
  if (abs(hue(c1) - hue(c2)) < 40) {
    c2 = color((hue(c2)+80)%255, 255, 255);
  }
}

int getRandomNormalizedHue() {
  int randC = int(random(11));
  int h = 0;
  int [] colRanges = {0, 15, 30, 45, 60, 105, 125, 150, 185, 210, 235};
  if (randC == 0 || randC == 10) {
    return int(random(235, 255+15)-15);
  }
  return int(random(colRanges[randC], colRanges[randC+1]));
}

// returns true if hues are more different than diff
boolean areColorsDiff(color c1, color c2, int diff) {
  return abs(hue(c1)-hue(c2)) > diff;
}

void setGradientZs() {
  colorMode(HSB, 255);
  counter++;
  if (millis() - lastChecked > 15000) {
    //if (counter%255 == 127) {
    setRandomColors();
    //setNextRandomColor();
    lastChecked = millis();
  }
  for (Shape s : shapes) {
    ((MoveableShape) s).setGradientZ(c1, c2, 30);
  }
}

void setRainbowPulse(int jump) {
  for (Shape s : shapes) {
    ((MoveableShape) s).setRainbow(jump);
  }
}
