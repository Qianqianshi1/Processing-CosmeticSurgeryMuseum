ParticleSystem ps;
Particle p;
import java.util.Iterator;

String systemState;
int keyIndex = 0;
PVector currentPoint;
PImage img;

color originalPointColor = #000000;
color brushPointColor = #000000;
float originalPointSize = 2;
float brushPointSize = 1.2;

void setup() {
  size(700,900, P3D);
  ps = new ParticleSystem();
  img = loadImage("face4.jpg");
  img.resize(700, 900);
  float tiles = 200;
  float tileSize = width/tiles;
  for (int x = 0; x < tiles; x++) {
    for (int y = 0; y < tiles; y++) {
      color c = img.get(int(x*tileSize),int(y*tileSize));
      float b = map(brightness(c),0,255,1,0);
      float z = map(b,0,1,150,-150);
      ps.addParticle(new PVector(x*tileSize - width/2, y*tileSize - height/2, z), originalPointColor, tileSize*(b*0.65));
    }
  }
}
 
void draw() {
  background(#f1f1f1);
  translate(width/2,height/2);
  ps.run();
}

class Particle {
//A “Particle” object is just another name for our “Mover.” It has location, velocity, and acceleration.
  PVector location;
  PVector velocity;
  PVector acceleration;
  float size;
  color pointColor;
  String state;
  float lifespan;
 
  Particle(PVector l, color c, float s) {
    location = l;
    acceleration = new PVector(0, 15, 0);
    velocity = new PVector(0, random(-20,0), 0);
    pointColor = c;
    size = s;
    lifespan = 255.0;
  }
 
  void updateDrop() {
    velocity.add(acceleration);
    location.add(velocity);
    lifespan -= 4.0;
  }
  
  void runDrop(){
    updateDrop();
    display();
  }
 
  void display() {
    noStroke();
    sphereDetail(3);
    fill(pointColor, lifespan);
    translate(location.x, location.y, location.z);
    sphere(size);
  }
  
  void run(){
    if (state == "drop"){
      runDrop();
    }else {
      display();
    }
  }
  
  void setSize(float s){
    size = s;
  }
  
  void setState(String s){
    state = s;
  }
  
  PVector getLocation(){
    return location;
  }
  
  PVector get2DPosition(float deg){
    PVector PlaneVector = new PVector();
    if (location.x >= 0){
      PlaneVector = new PVector(location.x * cos(radians(deg)), location.y);
    }else if (location.x < 0){
      PlaneVector =  new PVector(location.x * cos(radians(deg + 180)), location.y);
    }
    return PlaneVector;
  }
  
  boolean isDead(){
    if (lifespan < 0.0) {
      return true;
    } else {
      return false;
    }
  }
}


class ParticleSystem {
  ArrayList<Particle> particles;
  String systemState;
  int keepFrameCount;
  int currentFrameCount;
  int brushPointNum;
  int maxLength;
  
  //System state: init keep rotate boom 

  ParticleSystem() {
    particles = new ArrayList<Particle>();
    systemState = "init";
    brushPointNum = 0;
    maxLength = int(random(500, 5000));
  }
  
  void setSystemState(String s){
    systemState = s;
  }

  void addParticle(PVector l, color c, float s) {
    particles.add(new Particle(l, c, s));
  }
  
  void addBrushParticle(PVector l, color c, float s){
    particles.add(new Particle(l, c, s));
    brushPointNum++;
  }
  
  
  void setKeepFrameCount(int f){
    keepFrameCount = f;
  }
  
  int getKeepFrameCount(){
    return keepFrameCount;
  }

  void run() {
    if (systemState == "keep"){
      currentFrameCount = keepFrameCount;
      rotateY(radians(keepFrameCount));
    }else if (systemState == "boom" || (brushPointNum > maxLength)){
      currentFrameCount = keepFrameCount;
      rotateY(radians(keepFrameCount));
    }else {
      currentFrameCount = frameCount;
      rotateY(radians(frameCount));
    }
    
    Iterator<Particle> it = particles.iterator();
    while (it.hasNext()) {
      Particle p = it.next();
      if (systemState == "boom" || (brushPointNum > maxLength)){
        p.setState("drop");
      }
      push();
      p.run();
      pop();
      if (p.isDead()) {
       it.remove();
      }
    }
  }
}

void mousePressed(){
  ps.setSystemState("keep");
  ps.setKeepFrameCount(0);
}

void mouseReleased(){
  ps.setSystemState("rotate");
  frameCount = 0;
  keyIndex = 2;
}

void mouseDragged(){
  color current = img.get(int(mouseX), int(mouseY));
  float z = random(mapZ(current)-2, mapZ(current)+2);
  
  PVector mouseVector = new PVector((mouseX - width/2), mouseY - height/2, z);
  ps.addBrushParticle(mouseVector, brushPointColor, brushPointSize);
}

void keyPressed(){
  if (key == 'i'){
    ps = new ParticleSystem();
    float tiles = 200;
    float tileSize = width/tiles;
    for (int x = 0; x < tiles; x++) {
      for (int y = 0; y < tiles; y++) {
        color c = img.get(int(x*tileSize),int(y*tileSize));
        float b = map(brightness(c),0,255,1,0);
        float z = map(b,0,1,150,-150);
        ps.addParticle(new PVector(x*tileSize - width/2, y*tileSize - height/2, z), originalPointColor, tileSize*(b*0.65));
      }
    }
    frameCount = 0;
    keyIndex= 0;
  }else if (key == 'k' && keyIndex != 1){
    ps.setSystemState("keep");
    ps.setKeepFrameCount(frameCount);
    keyIndex = 1;
  }else if (key == 'r' && keyIndex != 0){
    ps.setSystemState("rotate");
    if (keyIndex != 2){
      frameCount = ps.getKeepFrameCount();
    }
    keyIndex = 2;
  }else if (key == 'b'){
    ps.setSystemState("boom");
    ps.setKeepFrameCount(frameCount);
    
  }
}

float mapZ(color c){
  float b = map(brightness(c),0,255,1,0);
  float z = map(b,0,1,150,-150);
  return z;
}
