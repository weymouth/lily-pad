/*************************
 FreeCylinder class
 
 This is an example class for simulating the interaction between the flow and a free
 circular cylinder.
 
 Example code:
 
 FreeCylinder test;

//INPUT PARAMETERS_______________________________________________________________________
int resolution = 8;               // number of grid points spanning radius of vortex
int xLengths = 10;                // (streamwise length of computational domain)/(resolution)
int yLengths = 6;                 // (transverse length of computational domain)/(resolution)
int area = 300000;                // window view area
int Re = 100;                     // Reynolds number
float mr = 1.2;                     // mass ratio = (body mass)/(mass of displaced fluid)
//_______________________________________________________________________________________

void setup() {
  // set window view area 
  float s = sqrt(area*xLengths/yLengths);
  size((int)s, (int)s*yLengths/xLengths);
  
  // create FreeCylinder object
  test = new FreeCylinder(resolution, Re, xLengths, yLengths, mr);
}

void draw() {
  test.update(); 
  test.display();
}

void keyPressed(){exit();}
 
 
 ***********************/


class FreeCylinder {
  BDIM flow;
  boolean QUICK = true, order2 = true;
  int n, m, resolution;
  CircleBody body;
  FloodPlot flood;
  float dt=1, dto=1, D, mr;
  PVector force;

  FreeCylinder(int resolution, int Re, int xLengths, int yLengths, float mr) {
    this.resolution = resolution;
    this.mr = mr;
    n=xLengths*resolution;
    m=yLengths*resolution;
    Window view = new Window(0, 0, n, m);
    D = resolution;
    
    body = new CircleBody(.2*n, .5*m, D, view);
    
    flow = new BDIM(n, m, 0, body, (float)D/Re, QUICK);

    flood = new FloodPlot(view); 
    flood.range = new Scale(-.5, .5);
    flood.setLegend("vorticity");
  }

  void update() {
    // save previous time step duration
    dto = dt;
    // calculate next time step duration
    if (QUICK) {
      dt = flow.checkCFL();
      flow.dt = dt;
    }
    
    // translate body according to pressure force, previous dt, current dt, and mass ratio
    PVector forceP = body.pressForce(flow.p);
    body.react(forceP, dto, dt, mr);
    
    body.update();
    flow.update(body);
    if (order2) {
      flow.update2();
    }
  }

  void display() {
    flood.display(flow.u.vorticity());
    body.display();
  }
}


