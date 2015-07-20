/*********************************************************
CounterRotatingCylinders extends BodyUnion to create counter-rotating
cylinders.  The position and size are defined with respect to a main 
cylinder, D, located at (xc, yc).

Example Code:

BDIM flow;
CircleBody mainCylinder;
CounterRotatingCylinders controlCylinders;
BodyUnion body;
FloodPlot flood;
float xi;

void setup(){

  // --input parameters-------
  int n=(int)pow(2,7)+2;  // number of grid points along a side of domain
  float Re = 100;  // Reynolds number by main cylinder diameter
  float dR = 0.15;  // (Control cylinder diameter)/(Main cylinder diameter)
  float theta = 60*PI/180;  // Angular location of control cylinders from downstream stream stagnation point
  float gR = 0.1;  // (Gap between control and main cylinders)/(Main cylinder diameter)
  float xi = 3;  // (Control cylinder surface speed)/(Free stream speed)
  float D = n/5;  // Main cylinder diameter
  float xc = n/2.5, yc = n/2; // Position of Main cylinder
  // -------------------------

  this.xi = xi;
  size(400,400);  // display window size
  Window view = new Window(n,n);
  
  // Create union of main cylinder and counter-rotating cylinders
  mainCylinder = new CircleBody(xc,yc,D,view);
  controlCylinders = new CounterRotatingCylinders(xc, yc, dR, theta, gR, xi, D, view);
  body = new BodyUnion(mainCylinder, controlCylinders);
  flow = new BDIM(n, n, 0, body, D/Re, true);

  flood = new FloodPlot(view);
  flood.range = new Scale(-.75,.75);
  flood.setLegend("vorticity");
}

void draw(){
  body.update();
  controlCylinders.update(flow.dt);
  flow.update(body);
  flow.update2();
  flood.display(flow.u.vorticity());
  body.display();
}

*********************************************************/

class CounterRotatingCylinders extends BodyUnion{
  float xi, dR, D;

CounterRotatingCylinders(float xc, float yc, float dR, float theta, float gR, float xi, float D, Window window) {
  // Create the rotating control cylinders
  super(new CircleBody(xc+(D/2+gR*D+dR*D/2)*cos(theta), yc+(D/2+gR*D+dR*D/2)*sin(theta), dR*D, window),
    new CircleBody(xc+(D/2+gR*D+dR*D/2)*cos(theta), yc-(D/2+gR*D+dR*D/2)*sin(theta), dR*D, window));

  this.xi = xi;
  this.dR = dR;
  this.D = D;
}

void update(float dt){
  unsteady = true;

  // Rotate the control cylinders
  this.a.rotate(-xi*dt*2/(dR*D));
  this.b.rotate(xi*dt*2/(dR*D));
}

}

