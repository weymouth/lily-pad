/********************************
CamBody class

CamBody extends an PixelBody from a camera capture source. 

Use `createCamBody(num,n,m)` to create a CamBody from camera(num)
with PixelBody size n,m. 

Method `update` grabs the newest capture and `background` uses 
that capture as the simulation background.

Example code:

CamBody body;
void setup() {
  println("Adjust the physical camera setup and the CamBody settings");
  println("to ensure the `solid` areas dark and within the box.");
  // CamBody settings
  size(600,400);                                 // size of camera capture image
  int num=0;                                     // camera number (read prompt after running)
  int n = 3*32, m=2*32;                          // simulation points (should match size aspect ratio)
  int x=width/4,y=height/3,w=width/3,h=height/3; // capture box dimensions
  float cut=0.5;                                 // brightness cutoff for `solids`
  body = createCamBody(num, n, m, x, y, w, h, cut);
}

void draw() {
  body.update();
  body.background();
  body.display();
}
********************************/

import processing.video.*; // need to install "Video Library for Processing" before running 

class CamBody extends PixelBody{
  Capture cam;
  PImage hold;
  int x,y,w,h;
  float cut;

  CamBody(int n, int m, PImage hold, Capture cam, int x, int y, int w, int h, float cut){
    super(n,m,hold);
    this.cam=cam; this.hold=hold;
    this.x=x; this.y=y; this.w=w; this.h=h; this.cut=cut;
  }

  void update(){
    if (cam.available() == true) {
      cam.read();
      solidify();
    }
  }
  
  void background(){
    image(cam,0,0);
    noFill();
    rect(x,y,w,h);
  }
  
  void solidify(){
    colorMode(ARGB, 1);
    hold = cam.get();
    hold.loadPixels();
    for (int i=0; i<width; i++) {
    for (int j=0; j<height; j++){
      float b = brightness(hold.pixels[i+width*j]);
      boolean c = b<cut && i>x && i<x+w && j>y && j<y+h;
      if(c){b=0;}else{b=1;}
      hold.pixels[i+width*j]=color(b,1-b);
    }}
    hold.updatePixels();
    update(hold);
  }
}

CamBody createCamBody(int num, int n, int m, int x, int y, int w, int h, float cut){
  String[] cameras = Capture.list();
  println("Available cameras:");
  for (int i = 0; i < cameras.length; i++) {
    println(i+": "+cameras[i]);
  }

  println("Using "+cameras[num]);
  Capture cam = new Capture(this, width, height, cameras[num]);
  cam.start();
  PImage hold = createImage(width,height,ARGB);
  CamBody body = new CamBody(n,m,hold,cam,x,y,w,h,cut);
  return body;
}

CamBody createCamBody(int num, int n, int m){ // Default capture box and cutoff
  return createCamBody(num,n,m,width/4,height/3,width/3,height/3,0.5);
}
