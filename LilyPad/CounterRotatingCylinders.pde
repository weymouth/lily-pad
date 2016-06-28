/*********************************************************
CounterRotatingCylinders 

  Extends BodyUnion to create counter-rotating cylinders.  
  The position and size are defined with respect to a main 
  cylinder, D, located at (xc, yc).

  In the example you can adjust the spin rate with the up/down arrows keys.

Example Code:

BDIM flow;
CircleBody mainCylinder;
CounterRotatingCylinders controlCylinders;
BodyUnion body;
FloodPlot flood;

void setup(){

  // --input parameters-------
  int n=(int)pow(2,6);  // number of grid points along a side of domain
  float Re = 100;  // Reynolds number by main cylinder diameter
  float dR = 0.15;  // (Control cylinder diameter)/(Main cylinder diameter)
  float theta = 60*PI/180;  // Angular location of control cylinders from downstream stream stagnation point
  float gR = 0.1;  // (Gap between control and main cylinders)/(Main cylinder diameter)
  float D = n/2.5;  // Main cylinder diameter
  float xc = 2*D, yc = n; // Position of Main cylinder
  // -------------------------

  size(900,600);  // display window size
  Window view = new Window(3*n,2*n);
  
  // Create union of main cylinder and counter-rotating cylinders
  mainCylinder = new CircleBody(xc,yc,D,view);
  controlCylinders = new CounterRotatingCylinders(xc, yc, dR, theta, gR, 0, D, view);
  body = new BodyUnion(mainCylinder, controlCylinders);
  flow = new BDIM(3*n, 2*n, 0, body, D/Re, true);

  flood = new FloodPlot(view);
  flood.range = new Scale(-.25,.25);
  flood.setLegend("vorticity");
}

void draw(){
  controlCylinders.update(flow.dt);
  flow.update(body);
  flow.update2();
  flood.display(flow.u.curl());
  body.display();
  fill(0); text("Xi = " + controlCylinders.xi,width/2,height-30);
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      controlCylinders.xi += 1;
    } else if (keyCode == DOWN) {
      controlCylinders.xi -= 1;
    } 
  }
}
*********************************************************/

class CounterRotatingCylinders extends BodyUnion{
  float xi,d;

  CounterRotatingCylinders(float xc, float yc, float dR, float theta, float gR, float xi, float D, Window window) {
    super(xc,yc,window);                               // initiate BodyUnion
    d = dR*D;                                          // control cylinder diameter
    float l = D/2.+gR*D+d/2.;                          // center-to-center distance
    float dx = l*cos(theta), dy = l*sin(theta);        // x,y offset
    add(new CircleBody(xc+dx, yc+dy, d, window));      // add top cylinder
    add(new CircleBody(xc+dx, yc-dy, d, window));      // add bottom
    this.xi = xi;                                      // rotation rate
  }

// Rotate the control cylinders
  void update(float dt){
    float omega = xi*2./d;
    this.bodyList.get(0).rotate(-omega*dt);
    this.bodyList.get(1).rotate( omega*dt);
  }
}