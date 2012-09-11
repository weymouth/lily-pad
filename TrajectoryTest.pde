/*************************
 Trajectory Follower Class
 
 Example code:
 
 ***********************/

class TrajectoryTest {
  final int n, m;
  float xpos, ypos, thpos, xStart, yStart, chord=1;
  float dt = 5, t = 0, maxT = 0;
  int resolution, trialID;
  String filepath;

  NACA foil; 
  BDIM flow; 
  FloodPlot flood, flood2; 
  Window window;
  ReadData reader;

  TrajectoryTest( int resolution, int xLengths, int yLengths, int xStart, float zoom, int Re, String filepath, boolean QUICK) {
    this.resolution = resolution;
    this.xStart = xStart;
    this.yStart = yLengths/2.0;
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
    
    flow = new BDIM(n, m, dt, foil, (float)resolution/Re, QUICK);
    flood = new FloodPlot(window);
    flood.range = new Scale(-1, 1);
    flood.setLegend("vorticity");
    flood.setColorMode(1); 

    flood2 = new FloodPlot(window);
    flood.range = new Scale(-0.5, 0.5);
    flood2.setLegend("pressure");
  }
  void update() {
    if (flow.QUICK) {
      dt = flow.checkCFL();
      flow.dt = dt;
    }
    
    moveBody();
    foil.update();
    flow.update(foil);
    flow.update2(foil);
    t += dt;
  }
  void moveBody(){
    xpos = -reader.interpolate(t/resolution,0)*resolution + xStart*resolution;
    ypos = -reader.interpolate(t/resolution,1)*resolution + yStart*resolution;
    thpos = reader.interpolate(t/resolution,2);
    foil.rotate(-foil.phi+thpos);
    foil.translate(-foil.xc.x+xpos,-foil.xc.y+ypos);
    
    println("xpos: " + xpos + "  ypos: " + ypos + "  thpos: " + thpos);
  }
  void display() {
    flood.display(flow.u.vorticity());
    foil.display();
    foil.displayVector(foil.pressForce(flow.p));
  }
}

