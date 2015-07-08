/*************************
 Trajectory Follower Class
 
Example code: WILL ONLY WORK IF YOU USE A TRAJECTORY FILE WRITTEN IN MATLAB, PARSED INTO READDATA 

TrajectoryTest test;
int trialnum;
String inputfile = "FileToRead.txt";

void setup() {
  int Re = 6000;
  int resolution = 64, xLengths=7, yLengths=9, xStart = 4, ystart = 5, zoom = 1;
  test = new TrajectoryTest(resolution, xLengths, yLengths, xStart, ystart, zoom, Re, inputfile, true);
}

void draw() {
  test.update();
  test.display();
  test.incrementTime();
}
 
 ***********************/

class TrajectoryTest {
  final int n, m;
  float xpos, ypos, thpos, xStart, yStart, chord=1;
  float dt = 0, t = 0, maxT = 0;
  int resolution, trialID;
  String filepath;

  NACA foil; 
  BDIM flow; 
  FloodPlot flood, flood2; 
  Window window;
  ReadData reader;

  TrajectoryTest( int resolution, int xLengths, int yLengths, int xStart, int yStart, float zoom, int Re, String filepath, boolean QUICK) {
    this.resolution = resolution;
    this.xStart = xStart;
    this.yStart = yStart;
    n = xLengths*resolution+2;
    m = yLengths*resolution+2;

    int w = int(zoom*(n-2)), h = int(zoom*(m-2));
    size(w, h);
    window = new Window(n, m);
    
    reader = new ReadData(filepath);
    maxT = reader.rows*reader.dt*resolution;
    trialID = int(float(reader.header[3]));

    foil = new NACA(xStart*resolution, m/2, resolution*chord, .12, window);
    foil.setColor(#CCCCCC);
    moveBody();
    foil.rotate(0);
    foil.translate(0,0);
    
    flow = new BDIM(n, m, dt, foil, (float)resolution/Re, QUICK, -1);
    flood = new FloodPlot(window);
    flood.range = new Scale(-1, 1);
    flood.setLegend("vorticity");
    flood.setColorMode(1); 

    flood2 = new FloodPlot(window);
    flood2.range = new Scale(-0.5, 0.5);
    flood2.setLegend("pressure");
  }
  void update() {
    moveBody();
    foil.update();
    foil.unsteady = true;
    flow.update(foil);
    flow.update2(foil);
  }
  void incrementTime(){
    dt = flow.dt;
    t += dt;
    println("dt: " + dt);
  }
  void moveBody(){
    xpos = reader.interpolate(t/resolution,0)*resolution;
    ypos = reader.interpolate(t/resolution,1)*resolution;
    thpos = reader.interpolate(t/resolution,2);
//    xpos = xStart*resolution;
//    ypos = yStart*resolution;
//    thpos = PI/36.0;
    foil.rotate(-foil.phi-thpos+PI);
    foil.translate(-foil.xc.x+xpos + xStart*resolution,-foil.xc.y-ypos+yStart*resolution);
    
    println("xpos: " + xpos + "  ypos: " + ypos + "  thpos: " + thpos);
  }
  void display() {
    flood.display(flow.u.vorticity());
    //flood2.display(flow.p);
    foil.display();
    foil.displayVector(foil.pressForce(flow.p));
  }
}