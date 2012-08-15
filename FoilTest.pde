/*************************
 Foil Test Class
 
 Example code:
 
FoilTest test;
void setup(){
  int resolution = 32, xLengths=4, yLengths=3, xStart = 1, zoom = 3;
  float heaveAmp = 0.5, pitchAmp = PI/12.;
  test = new FoilTest(resolution, xLengths, yLengths, xStart , zoom, heaveAmp, pitchAmp );
}
void draw(){
  test.update();
  test.display();
}
***********************/

class FoilTest{
  final int n,m;
  float t = 0, heaveAmp, pitchAmp, omega = .25;
  NACA foil; 
  BDIM flow; 
  FloodPlot flood, flood2; 
  Window window;

  FoilTest( int resolution, int xLengths, int yLengths, int xStart, float zoom, float heaveAmp, float pitchAmp) {
    n = xLengths*resolution+2;
    m = yLengths*resolution+2;

    int w = int(zoom*(n-2)), h = int(zoom*(m-2));
    size(w,h);
    window = new Window(n,m);

    foil = new NACA(xStart*resolution,m/2,resolution,0.2,window);
    this.pitchAmp = pitchAmp; 
    this.heaveAmp = heaveAmp*resolution;
    foil.translate(0,this.heaveAmp);
    omega = TWO_PI*omega/resolution;

    flow = new BDIM(n,m,0,foil,0.01,true); // QUICK with adaptive time step
    
    flood = new FloodPlot(window);
    flood.range = new Scale(-1,1);
    flood.setLegend("vorticity");

    flood2 = new FloodPlot(window);
    flood.range = new Scale(-0.5,0.5);
    flood2.setLegend("pressure");
  }
  void update() {
    float velo = heaveAmp*omega*sin(omega*t);
    float spin = atan2(velo,1.)-foil.phi-pitchAmp*sin(omega*t);
    foil.translate(0,-velo*flow.dt);
    foil.rotate(spin);
    foil.update();
    flow.update(foil);
    flow.update2(foil);
    t += flow.dt;
  }
  void display() {
    flood.display(flow.u.vorticity());
    foil.display();
    flood.displayTime(t);
  }
}

