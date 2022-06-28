/*********************************************************
ImageBody Class
                  
Use an image to define a BDIM body instead of a set of points.

Example code:

BDIM flow;
FloodPlot flood;
ImageBody img;

void setup(){
  size(700,700);                             // display window size
  int n=(int)pow(2,7);                       // number of grid points
  Window view = new Window(n,n);
  Body body = new CircleBody(n/3.,n/2.,n/6.,view);
  img = new ImageBody(n, n, body);
  flow = new BDIM(n,n,0.,img);               // solve for flow using BDIM
  //flow = new BDIM(n,n,0., body);             // for comparison
  flood = new FloodPlot(view);               // initialize a flood plot...
  flood.setLegend("vorticity",-.5,.5);       //    and its legend
}

void draw(){
  flow.update(); flow.update2();             // 2-step fluid update
  flood.display(flow.u.curl());              // compute and display vorticity
  img.display();                             // display the BodyImage
}
*********************************************************************************/
class ImageBody{
  PImage img;
  float[][] pix;
  float area,mass;

  // Makes an ImageBody from an image
  ImageBody(int n, int m, PImage src){
    img = createImage(n,m,ARGB);
    pix = new float[n][m];
    update(src);
  }
  
  void update(PImage src){
    src.resize(img.width,img.height);
    img.set(0,0,src);
    setAlpha();
    getArea();
  }
  
  // set pix to the pixel brightness and alpha to zero when pixel is dark
  void setAlpha(){
    colorMode(ARGB, 1);
    img.loadPixels();
    for ( int i=0 ; i<img.width ; i++ ) {
    for ( int j=0 ; j<img.height ; j++ ) {
        color c = img.pixels[i+img.width*j];
        pix[i][j] = brightness(c);
        img.pixels[i+img.width*j] = color(c,1-pix[i][j]);
    }}
    img.updatePixels();
  }

  // Makes an ImageBody from a body
  ImageBody(int n, int m, Body body){
    colorMode(ARGB, 1);                               // define 0->black & 1->white
    pix = new float[n][m];
    img = createImage(n,m,ARGB);                      // empty image
    img.loadPixels();                                 // load pixels
    for ( int i=0 ; i<n ; i++ ) {                     // loop through...
    for ( int j=0 ; j<m ; j++ ) {                     // ... the cells
        float dist = body.distance((float)i, (float)j);  // distance from cell to body
        float f = delta0(dist);                          // indicator function
        img.pixels[i+j*n] = color(f);                    // set pixel brightness
    }}
    img.updatePixels();
    setAlpha();
    getArea();
  }
  float delta0( float d ){
    float eps = 2;
    if( d <= -eps ){
      return 0;
    } else if( d >= eps ){
      return 1;
    } else{
      return 0.5*(1.+d/eps+sin(PI*d/eps)/PI);
    } 
  }

  void getArea() {    // get the body image area
    colorMode(ARGB, 1);                               // define 0->black & 1->white
    area=0;
    for ( int i=0 ; i<img.width ; i++ ) {
    for ( int j=0 ; j<img.height ; j++ ) {
      area += 1-pix[i][j];
    }}
    mass = area; // default unit density
  }
  
  // interpolate the local brightness value
  float b(float x, float y){
    float i = min(max(x,0),img.width-2), j = min(max(y,0),img.height-2);
    int ii = floor(i), jj = floor(j);
    float ri = i-ii, rj = j-jj;
    if(ri==0 & rj==0){
      return pix[ii][jj];
    }else{
      return (1-rj)*((1-ri)*pix[ii][jj]+ri*pix[ii+1][jj])
            +rj*((1-ri)*pix[ii][jj+1]+ri*pix[ii+1][jj+1]);
    }
  }
  
  // get the gradient of the local brightness
  PVector db(float i, float j){
    return new PVector(b(i+0.5,j)-b(i-0.5,j),b(i,j+0.5)-b(i,j-0.5));
  }

  // display the image
  void display(){
    int x0 = width/img.width/2, y0 = height/img.height/2;
    image(img,x0,y0,width,height);
  }

  // Compute the pressure force on an ImageBody
  PVector pressForce(Field p){
    PVector pv = new PVector(0, 0);
    for ( int i=1 ; i<p.n-1 ; i++ ) {                     // loop through...
    for ( int j=1 ; j<p.m-1 ; j++ ) {                     // ... the cells
        pv.add(db(i,j).mult(p.a[i][j]));
    }}
    return pv;
  }
}

import processing.video.*; // need to install "Video Library for Processing" before running 

class CamBody extends ImageBody{
  Capture cam;
  PImage hold;
  int x = width/4, y=height/3, w=width/3, h=height/3;
  float thresh=0.5;

  CamBody(int n, int m, PImage hold, Capture cam){
    super(n,m,hold);
    this.cam=cam; this.hold=hold;
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
      boolean c = b<thresh && i>x && i<x+w && j>y && j<y+h;
      if(c){b=0;}else{b=1;}
      hold.pixels[i+width*j]=color(b,1-b);
    }}
    hold.updatePixels();
    update(hold);
  }
}

CamBody createCamBody(int num, int n, int m){
  String[] cameras = Capture.list();
  println("Available cameras:");
  for (int i = 0; i < cameras.length; i++) {
    println(i+": "+cameras[i]);
  }

  println("Using "+cameras[num]);
  Capture cam = new Capture(this, width, height, cameras[num]);
  cam.start();
  PImage hold = createImage(width,height,ARGB);
  CamBody body = new CamBody(n,m,hold,cam);
  return body;
}
