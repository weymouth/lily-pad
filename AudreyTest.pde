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
  int resolution = 64, xLengths=5, yLengths=3, zoom = 2;
  float xStart = 1.7, yDist = 0.06;
  test = new AudreyTest(resolution, xLengths, yLengths, xStart , yDist, zoom);
  mm = new MovieMaker(this, width, height, "foil_QUICK_1000_ eps2_o2.mov", 30);
  dat = new SaveData("pressure_QUICK_1000_eps2_o2.txt",test.body.a.coords,resolution,xLengths,yLengths,zoom);
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
  final int n,m, resolution, NT=1;
  float dt = 2.5, t, t0, Re=1000, cDiameter = 0.5;
  boolean QUICK = true, order2 = true;
  BodyUnion body; BDIM flow; FloodPlot flood, flood2; Window window, window2; NACA foil;
  
  AudreyTest( int resolution, int xLengths, int yLengths, float xStart , float yDist, float zoom){
    n = xLengths*resolution+2;
    m = yLengths*resolution+2;
    this.resolution = resolution;
    float xFoil = 1.0/3.0;
    float yFoil = 1.0/2.0;
    float yStart = yLengths*yFoil-yDist-0.06-0.5*cDiameter;
    
    t0 = xStart-xFoil*xLengths;

    int w = int(zoom*(n-2)), h = int(zoom*(m-2));
    size(w,h);
    smooth();
//    window = new Window(n,m);
    window = new Window(n/6,m/5,n/2,m/2);
    window2 = new Window(n/6,m/5,n/2,m/2);

    foil =  new NACA(xFoil*n,yFoil*m,resolution,0.12,window);
    body = new BodyUnion( new NACA(xFoil*n,yFoil*m,resolution,0.12,window), new EllipseBody(xStart*resolution,yStart*resolution,cDiameter*resolution,window));

    flow = new BDIM(n,m,dt,body,(float) resolution/Re,QUICK);

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
     body.b.translate(dt,0);
     flow.update(body);
     if (order2) {flow.update2(body);}
    print("t="+nfs(t,2,2)+";  ");
    t += dt/resolution;
    }
  }
  
  void display(){
    flood.display(flow.u.vorticity());
    body.display();
    flood.displayTime(t);
//    flood2.display(flow.p);
//    foil.display(window2);
//    flood2.displayTime(t);
  }
}
