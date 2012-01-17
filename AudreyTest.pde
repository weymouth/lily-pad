/*************************
Audrey Test Class

Example code:

import processing.video.*;
boolean recording=true;
int Time =10;
MovieMaker mm; 
SaveData dat;
AudreyTest test;

void setup(){
  int resolution = 64, xLengths=5, yLengths=3, xStart = 2, zoom = 2;
  test = new AudreyTest(resolution, xLengths, yLengths, xStart , zoom);
  mm = new MovieMaker(this, width, height, "foil_QUICK_1000_ eps2_o2.mov", 30);
  dat = new SaveData("pressure_QUICK_1000_eps2_o2.txt",test.foil.fcoords,resolution,xLengths,yLengths,zoom);
}

void draw(){
  if(test.t<Time){
  test.update();
  test.display();
    if(recording){
    mm.addFrame();
    dat.addData(test.t, test.flow.p);
    }
  }
  if(test.t>=Time){
    mm.finish();
    dat.finish();
    exit();
}
}

void keyPressed(){
    mm.finish();
    dat.finish();
    exit();
}

***********************/

class AudreyTest{
  final int n,m, resolution, NT=10;
  float dt = 2.5, t = 0, Re=1000;
  boolean QUICK = true, order2 = true;
  NACA foil; BDIM flow; FloodPlot flood, flood2; Window window, window2;
  
  AudreyTest( int resolution, int xLengths, int yLengths, int xStart , float zoom){
    n = xLengths*resolution+2;
    m = yLengths*resolution+2;
    this.resolution = resolution;

    int w = int(zoom*(n-2)), h = int(zoom*(m-2));
    size(w,h);
    smooth();
    window = new Window(n,m);
    window2 = new Window(n,m);

    foil = new NACA(xStart*resolution,m/2,resolution,0.15,window);

    flow = new BDIM(n,m,dt,foil,(float) resolution/Re,QUICK);

    flood = new FloodPlot(window);
    flood.range = new Scale(-0.75,0.75);
    flood.setLegend("vorticity");

    flood2 = new FloodPlot(window2);
    flood2.range = new Scale(-0.5,0.5);
    flood2.setLegend("pressure");
  }
  
  void update(){
    for ( int i=0 ; i<NT ; i++ ) {
    if (QUICK){
     dt = flow.checkCFL();
     flow.dt = dt;}
//     foil.translate(0,0);
     flow.update(foil);
     if (order2) {flow.update2(foil);}
    print("t="+nfs(t,2,2)+";  ");
    t += dt/resolution;
    }
  }
  
  void display(){
//    flood.display(flow.u.vorticity());
//    foil.display();
//    flood.displayTime(t);
    flood2.display(flow.p);
    foil.display(window2);
    flood2.displayTime(t);
  }
}
