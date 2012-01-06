/*************************
Foil Test Class

Example code:

FoilTest test;
void setup(){
  int resolution = 16, xLengths=6, yLengths=4, xStart = 2, zoom = 6;
  float heaveAmp = 0.5, pitchAmp = 0.61;
  test = new FoilTest(resolution, xLengths, yLengths, xStart , zoom, heaveAmp, pitchAmp );
}
void draw(){
  test.update();
  test.display();
}
***********************/

class FoilTest{
  final int n,m;
  float dt = 2.5, t = 0, heaveAmp, pitchAmp, omega = 1;
  NACA foil; BDIM flow; FloodPlot flood, flood2; Window window, window2;
  
  FoilTest( int resolution, int xLengths, int yLengths, int xStart , float zoom, float heaveAmp, float pitchAmp){
    n = xLengths*resolution+2;
    m = yLengths*resolution+2;

    int w = int(zoom*(n-2)), h = int(zoom*(m-2));
    size(w,h);
    window = new Window(n,m);
    window2 = new Window(n,m);

    foil = new NACA(xStart*resolution,m/2,resolution,0.2,window);
    foil.rotate(pitchAmp); foil.dphi = 0;
    this.pitchAmp = pitchAmp; 
    this.heaveAmp = heaveAmp*resolution;
    omega = omega/resolution;

    flow = new BDIM(n,m,dt,foil);

    flood = new FloodPlot(window);
    flood.range = new Scale(-0.5,0.5);
    flood.setLegend("vorticity");

    flood2 = new FloodPlot(window2);
    flood.range = new Scale(-0.5,0.5);
    flood2.setLegend("pressure");
  }
  
  void update(){
    float velo = -heaveAmp*omega*cos(omega*t);
    float spin = -pitchAmp*omega*sin(omega*t);
    foil.translate(0,velo*dt);
    foil.rotate(spin*dt);
    flow.update(foil);
//    flow.update();
    print(t+" ");
    t += dt;
  }
  void display(){
    flood.display(flow.u.vorticity());
    foil.display();
//    flood2.display(flow.p);
//    foil.display(window2);
  }
}
