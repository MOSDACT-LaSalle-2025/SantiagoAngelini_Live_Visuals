import java.util.ArrayList;
import ddf.minim.*;


Minim minim;
AudioPlayer player;

// ===================================
// VARIABLES AND CLASSES FOR SKETCH A (RECTANGLE TRAIL)
// ===================================

class RectanguloPunto {
  float x, y, z, w, h;
  int creationFrame;
  color puntoColor;
  
  RectanguloPunto(float _x, float _y, float _z, float _w, float _h, int _creationFrame, color _puntoColor) {
    x = _x;
    y = _y;
    z = _z;
    w = _w;
    h = _h;
    creationFrame = _creationFrame;
    puntoColor = _puntoColor;
  }
  
  void dibujar() {
    stroke(puntoColor);
    strokeWeight(3);
    noFill();
    pushMatrix();
    translate(x, y, z);
    rectMode(CENTER);
    rect(0, 0, w, h);
    popMatrix();
  }
}

ArrayList<ArrayList<RectanguloPunto>> estelasCompletadas = new ArrayList<ArrayList<RectanguloPunto>>();
ArrayList<RectanguloPunto> estelaActual = new ArrayList<RectanguloPunto>();

int zpos, incrementoZ;
float x, y, scalex, scaley; 
float x2, y2, scalex2, scaley2;
int duracionEstela = 40;
boolean dibujarDos = false;
color colorActual;

// ===================================
// VARIABLES AND CLASSES FOR SKETCH B (TUNNELS)
// ===================================

PGraphics tunnel1, tunnel2, tunnel3;
float panelWidth, panelHeight;
float panelSpacing = 15;

boolean moveX_active = false;
boolean moveY_active = false;
boolean rotZ_active = false;
boolean drawCircle = false;
boolean drawBox = false;

// Las variables de color de Sketch B se reemplazan por la variable global 'colorActual'
float moveX_offset = 0;
float moveY_offset = 0;
float rotationAmount = 0;

float beatFlash = 0;
float beatDecayRate = 0.99;
float lightWavePos = 0;

int bpm = 120;
float interval;
float lastBeatTime = 0;

// ===================================
// GLOBAL STATE AND SETUP
// ===================================

int sketchState = 2; // 1 = Sketch A, 2 = Sketch B

void setup() {
  fullScreen(P3D);
  noCursor();
  // Setup for Sketch A
  incrementoZ = 20;
  colorActual = color(255);
  resetearCuadrado();
  
  // Setup for Sketch B
  interval = 60000.0 / bpm;
  panelWidth = (width - panelSpacing * 4) / 3;
  panelHeight = height * 0.85;
  tunnel1 = createGraphics((int)panelWidth, (int)panelHeight, P3D);
  tunnel2 = createGraphics((int)panelWidth, (int)(panelHeight * 1.05), P3D);
  tunnel3 = createGraphics((int)panelWidth, (int)panelHeight, P3D);
  minim = new Minim(this);
  player = minim.loadFile("La_Roulette.mp3");
  player.play();
}

// ===================================
// DRAW FUNCTION (SWITCHING BETWEEN SKETCHES)
// ===================================

void draw() {
  background(0);
  
  if (sketchState == 1) {
    drawSketchA();
  } else if (sketchState == 2) {
    drawSketchB();
  }
}

// ===================================
// DRAW FUNCTIONS FOR EACH SKETCH
// ===================================

void drawSketchA() {
  for (int i = estelasCompletadas.size() - 1; i >= 0; i--) {
    ArrayList<RectanguloPunto> estela = estelasCompletadas.get(i);
    for (int j = estela.size() - 1; j >= 0; j--) {
      RectanguloPunto p = estela.get(j);
      if (frameCount - p.creationFrame > duracionEstela) {
        estela.remove(j);
      } else {
        p.dibujar();
      }
    }
    if (estela.isEmpty()) {
      estelasCompletadas.remove(i);
    }
  }

  if (dibujarDos) {
    estelaActual.add(new RectanguloPunto(x, y, zpos, scalex, scaley, frameCount, colorActual));
    estelaActual.add(new RectanguloPunto(x2, y2, zpos, scalex2, scaley2, frameCount, colorActual));
  } else {
    estelaActual.add(new RectanguloPunto(x, y, zpos, scalex, scaley, frameCount, colorActual));
  }
  
  for (RectanguloPunto p : estelaActual) {
    p.dibujar();
  }

  zpos += incrementoZ;
  
  if (zpos >= 750) {
    if (estelasCompletadas.size() > 5) {
      estelasCompletadas.remove(0);
    }
    estelasCompletadas.add(estelaActual);
    estelaActual = new ArrayList<RectanguloPunto>();
    resetearCuadrado();
    dibujarDos = !dibujarDos;
  }
}

void drawSketchB() {
  if (millis() - lastBeatTime > interval) {
    beatFlash = 255;
    lightWavePos = 0;
    lastBeatTime = millis();
  }

  beatFlash *= beatDecayRate;
  lightWavePos += 0.5;

  if (moveX_active) {
    moveX_offset = sin(frameCount * 0.0135) * 200;
  } else {
    moveX_offset = 0;
  }

  if (moveY_active) {
    moveY_offset = sin(frameCount * 0.015) * 160;
  } else {
    moveY_offset = 0;
  }

  if (rotZ_active) {
    rotationAmount = sin(frameCount * 0.02) * PI/6;
  } else {
    rotationAmount = 0;
  }

  drawTunnel(tunnel1, beatFlash, moveX_offset, moveY_offset, rotationAmount);
  drawTunnel(tunnel2, beatFlash, moveX_offset, moveY_offset, rotationAmount);
  drawTunnel(tunnel3, beatFlash, moveX_offset, moveY_offset, rotationAmount);

  float standardY = height / 2 - panelHeight / 2;
  float middleY = height / 2 - tunnel2.height / 2;

  image(tunnel1, panelSpacing, standardY);
  image(tunnel2, panelSpacing * 2 + panelWidth, middleY);
  image(tunnel3, panelSpacing * 3 + panelWidth * 2, standardY);
}

void resetearCuadrado() {
  zpos = 0;
  x = random(600, width - 600);
  y = random(600, height - 600);
  scalex = random(20, width / 2);
  scaley = random(height / 2, 20);

  x2 = random(600, width - 600);
  y2 = random(600, height - 600);
  scalex2 = random(20, width / 4);
  scaley2 = random(height / 3, 20);
  
  while (dist(x, y, x2, y2) < 100 && dibujarDos) {
    x2 = random(300, width - 300);
    y2 = random(300, height - 300);
  }
}

// ===================================
// HELPER FUNCTIONS FOR SKETCH B
// ===================================

void drawTunnel(PGraphics pg, float brightness, float baseOffsetX, float baseOffsetY, float totalRotation) {
  pg.beginDraw();
  pg.background(0);
  pg.strokeWeight(5);
  pg.strokeCap(SQUARE);

  pg.camera(pg.width/2, pg.height/2, 750, pg.width/2, pg.height/2, 0, 0, 1, 0);
  pg.translate(pg.width/2, pg.height/2, -100);

  for (int i = 0; i < 25; i++) {
    float rectWidth = map(i, 0, 25, pg.width, 0);
    float rectHeight = map(i, 0, 25, pg.height, 0);

    float waveBrightness = 0;
    float distFromWave = abs(i - lightWavePos);

    if (distFromWave < 7) {
      waveBrightness = map(distFromWave, 0, 7, brightness * 2, 0);
    }
    
    // Aplicamos el color de la variable global 'colorActual'
    pg.stroke(red(colorActual), green(colorActual), blue(colorActual), waveBrightness);

    pg.noFill();
    pg.rectMode(CENTER);

    float displacementX = 0;
    float displacementY = 0;

    if (moveX_active) {
      displacementX = map(i, 0, 25, 0, baseOffsetX * 2);
    }
    if (moveY_active) {
      displacementY = map(i, 0, 25, 0, baseOffsetY * 2);
    }

    float currentRotation = map(i, 0, 25, 0, totalRotation);
    pg.pushMatrix();
    pg.translate(displacementX, displacementY);
    pg.rotate(currentRotation);
    pg.rect(0, 0, rectWidth, rectHeight);
    if (drawCircle) {
      pg.circle(0, 0, rectWidth/2);
    }
    if (drawBox) {
      pg.rect(0, 0, rectWidth/1.5, rectWidth/1.2);
    }
    pg.popMatrix();
  }
  pg.endDraw();
}

// ===================================
// KEYBOARD CONTROL (MERGED LOGIC)
// ===================================

void keyPressed() {
  if (key == '7') {
    sketchState = (sketchState == 1) ? 2 : 1;
    // No se borran los estados de movimiento para que se mantengan
    // al cambiar de sketch.
  } else {
    // La lógica de las teclas de color (4, 5, 6) ahora es global
    if (key == '4') {
      if (colorActual == color(255, 0, 0)) {
        colorActual = color(255);
      } else {
        colorActual = color(255, 0, 0);
      }
    } else if (key == '5') {
      if (colorActual == color(0, 255, 0)) {
        colorActual = color(255);
      } else {
        colorActual = color(0, 255, 0);
      }
    } else if (key == '6') {
      if (colorActual == color(0, 0, 255)) {
        colorActual = color(255);
      } else {
        colorActual = color(0, 0, 255);
      }
    }

    // Lógica para las teclas de Sketch B (1, 2, 3, etc.)
    if (key == '1') {
      moveX_active = !moveX_active;
    } else if (key == '2') {
      moveY_active = !moveY_active;
    } else if (key == '3') {
      rotZ_active = !rotZ_active;
    } else if (key == '8') {
      drawBox = !drawBox;
    } else if (key == '9') {
      drawCircle = !drawCircle;
    } else if (key == '0') {
      moveX_active = false;
      moveY_active = false;
      rotZ_active = false;
    }
  }
}
