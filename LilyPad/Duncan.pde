/*********************************************************
 Simulation of the Duncan experiment
 
 A foil at angle of attack below a recirculating channel with free surface. 
 
 Example code:
 
 Duncan test;
 
 void settings() {
 size(1200, 600);
 }
 
 void setup() {
 int n = 128, m=64;
 float xstart = 2, ystart=0.5, AoA=15, Re=500, Fr=0.5; 
 test = new Duncan( n,  m,  xstart,  ystart,  AoA,  Re,  Fr);
 }
 
 void draw() {
 test.update();
 test.display();
 }
 ***********************/

class Duncan {
  float t=0, U=1, ratio=0.001, fill=.4;
  NACA wing;
  TwoPhase flow;
  PVector state;
  float L;

  Duncan( int n, int m, float xstart, float ystart, float AoA, float Re, float Fr) {
    // set up wing
    L = n/8; 
    state = new PVector(xstart*L, fill*m + ystart*L, radians(AoA));
    wing = new NACA(0, 0, L, 0.16, new Window(n, m));
    wing.follow(state, new PVector());
    wing.bodyColor=color(255);

    // set up two phase fluid
    float g = pow(U, 2)/pow(Fr, 2)/L;
    float nu = U*L/Re;
    flow = new TwoPhase(n, m, 0, wing, nu, true, g, ratio); // define fluid
    flow.f.eq(0, 0, n+2, 0, int(fill*m));                   // define initial water region
  }

  void update() {
    t += flow.dt;   // update the time
    flow.update();  // 2-step fluid update
    flow.update2();
  }

  void display() {
    flow.f.display();      // free surface
    flow.u.display(2, 2);  // velocity vectors
    wing.display();        // geometry
  }

  void pressForce(PrintWriter w) {
    PVector forces = wing.pressForce(flow.p);
    float drag = 2.*forces.x/L, lift = 2.*forces.y/L, ts = t*U/L;
    w.println(""+ts+","+drag+","+lift+"");
  }

  void height(PrintWriter w) {
    for ( int i=1; i<flow.f.n-1; i++) {
      float h = 0;
      for ( int j=1; j<flow.f.m-1; j++) {
        h+=flow.f.a[i][j];
      }
      float x = (i-state.x)/L, y = (h-int((1-fill)*flow.m+0.5))/L, ts = t*U/L;
      w.println(""+ts+","+x+","+y);
    }
  }
}