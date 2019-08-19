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
  float density=0.001, fill=.5; // air/water density and domain fill ratios
  NACA wing;
  TwoPhase flow;
  PVector state;
  float t=0, U=1, L, y0, g;

  Duncan( int n, int m, float xstart, float ystart, float AoA, float Re, float Fr) {
    // set up wing
    L = m/4; 
    state = new PVector(xstart*L, fill*m + ystart*L, radians(AoA));
    wing = new NACA(0, 0, L, 0.16, new Window(n, m));
    wing.follow(state, new PVector());
    wing.bodyColor=color(255);

    // set up two phase fluid
    float nu = U*L/Re;
    g = pow(U, 2)/pow(Fr, 2)/L;
    flow = new TwoPhase(n, m, 0, wing, nu, true, g, density); // define two phase fluid
    flow.f.eq(0, 0, n+2, 0, int(fill*m));                     // define initial water region
    y0 = int((1-fill)*flow.m+0.5);
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
    // measure pressure forces on wing and print to writer
    PVector forces = wing.pressForce(flow.p);
    float drag = 2.*forces.x/L, lift = 2.*forces.y/L, ts = t*U/L;
    w.println(""+ts+","+drag+","+lift+"");
  }

  void height(PrintWriter w) {
    // measure fluid height for each x and print to writer
    for ( int i=1; i<flow.f.n-1; i++) {
      float h = 0;
      for ( int j=1; j<flow.f.m-1; j++) {
        h+=flow.f.a[i][j];
      }
      float x = (i-state.x)/L, y = (h-y0)/L, ts = t*U/L;
      w.println(""+ts+","+x+","+y);
    }
  }
}

class WaveyDuncan extends Duncan {
  float k, a, omega, omega_e;
  WaveyDuncan( int n, int m, float xstart, float ystart, float AoA, float Re, float Fr, float kL, float ak) {
    super(n, m, xstart, ystart, AoA, Re, Fr);
    //U=0; // no forward speed test !!
    flow.u = new VectorField(n+2, m+2, U, 0.); // initial velocity field
    flow.u.x.waveInlet = true;                 // wave inlet
    flow.u.y.waveTop = true;                   // volume correcting top boundary
    k = kL/L;
    a = ak/k;
    omega = sqrt(g*k);                         // wave frequency
    omega_e = omega+U*k;                       // encounter frequency
  }

  void update() {
    t += flow.dt;   // update the time
    set_BC();       // set inlet wave BCs
    flow.update();  // 2-step fluid update
    flow.update2();
  }

  void set_BC() {
    float eta = a*cos(-omega_e*flow.t);  // inlet interface height
    float s = 0; // volume flux
    
    // apply wavemaker at inlet
    for (int j=1; j<flow.m-1; j++ ) {
      float y=flow.m-j-0.5-y0;          // vertical position

      if (y<eta-0.5) {       // under the wave
        float u = -omega*eta*exp(y*k);
        flow.u.x.a[1][j] = U+u;
        s+= u;
      } else if (y<=eta+0.5) { // at the interface
        float f = eta-y+0.5;
        float u = -f*omega*eta*exp(y*k);
        flow.u.x.a[1][j] = U+u;
        s+= u;
      } else {                // above the wave
        flow.u.x.a[1][j] = U;
      }
    }
    
    // apply uniform volume flux correction to upper boundary
    flow.u.y.bval_top = -s/float(flow.n-2);
  }
}