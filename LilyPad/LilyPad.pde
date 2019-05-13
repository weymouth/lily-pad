
ImageBody body;
Window view;
BDIM flow;
ParticlePlot plot;
int n = int(pow(2, 5)), skip = 0;
import processing.video.*;
Capture cam;
PImage pic, bck;

void setup() {
  size(1280, 720);
  String[] cameras = Capture.list();
  cam = new Capture(this, width, height, cameras[13]);
  cam.start();
  bck = createImage(width, height, RGB); 
  pic = createImage(width, height, RGB); 
  pic.filter(INVERT);
  view = new Window(3*n, 2*n);
  body = new ImageBody(3*n, 2*n, pic);
  flow = new BDIM(3*n, 2*n, 0., body);
  plot = new ParticlePlot(view, 5000);
  plot.setLegend("Flow speed", -0.5, 1.5);
  plot.setColorMode(2);
}

void draw() {
  background(bck);
  noFill();
  rect(width/4, height/3, width/3, height/3);
  if (cam.available() == true) {
    cam.read();
    bck = cam.get();
    pic = createImage(width, height, RGB); 
    pic.filter(INVERT);
    pic.set(width/4, height/3, cam.get(width/4, height/3, width/3, height/3));
    pic.filter(THRESHOLD, 0.5 );
    pic.filter(BLUR, 2);
    body = new ImageBody(3*n, 2*n, pic);
    bck.blend(pic, 0, 0, width, height, 0, 0, width, height, BURN);
  }
  flow.update(body);
  plot.update(flow);
  plot.display(flow.u.x);
}