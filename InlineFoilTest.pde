/*************************
 Inline Flapping Foil Test Class
 
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

class InlineFoilTest {
  final int n, m;
  float dt = 1, t = 0, heaveAmp, dAoA, uAoA, inlineAmp, omega, chord = 1.0, period, dfrac;
  float veloy, velox, adv_angle, recovery_angle, AoF, dAoFdt, v2, pitch=0, p=0, integerr=0, yold=0;
  float Fd=0, Fd_dot=0, F, Fold;
  float tau = .1, a=3, b=25;
  int resolution;
  String pitchmethod;
  boolean upstroke = false;

  NACA foil; 
  BDIM flow; 
  FloodPlot flood, flood2; 
  Window window;

  InlineFoilTest( int resolution, int xLengths, int yLengths, int xStart, float zoom, int Re) {
    this.resolution = resolution;
    n = xLengths*resolution+2;
    m = yLengths*resolution+2;

    int w = int(zoom*(n-2)), h = int(zoom*(m-2));
    size(w, h);
    window = new Window(n, m);

    foil = new NACA(xStart*resolution, m/2, resolution*chord, .12, window);
    flow = new BDIM(n, m, dt, foil, (float)resolution/Re, true);

    flood = new FloodPlot(window);
    flood.range = new Scale(-1, 1);
    flood.setLegend("vorticity");
    flood.setColorMode(1); 

    flood2 = new FloodPlot(window);
    flood.range = new Scale(-0.5, 0.5);
    flood2.setLegend("pressure");
  }
  void setFlapParams(float stru, float stk, float dAoA, float uAoA, float hc, String pitchmethod) {
    this.dAoA = dAoA; 
    this.uAoA = uAoA; 
    this.heaveAmp = hc*chord*resolution;
    this.inlineAmp = hc*chord*resolution*1/tan(stk);
    this.omega = TWO_PI/resolution * stru/(2*hc*chord);
    this.period = TWO_PI/omega;
    this.dfrac = 0.5; //Functionality for changing the downstroke to period fraction not fully implemented
    foil.translate(-this.inlineAmp, -this.heaveAmp);

    tau = tau*((float)resolution);
    this.pitchmethod = pitchmethod;

    adv_angle = atan2(-heaveAmp*omega, 1.-inlineAmp*omega);
    recovery_angle = atan2(heaveAmp*omega, 1.+inlineAmp*omega);
  }

  void setControlParams(float a, float b, float tau) {
    this.a = a; 
    this.b = b;
    this.tau = tau*((float)resolution);
  }

  float controller(float y, float yd) {
    //Really bad observer
    y = y*.3+yold*.7; 
    yold = y;

    //Controller, in discrete
    float pnew = (yd/a+p/dt*b/a+AoF+1/(tau*a)*(integerr+.5*dt*(yd-y)))/(1+b/a*1/dt);
    integerr = integerr+dt*(yd-y);
    p = pnew;

    println("AoA "+ (p-AoF)*180/PI);
    println("Phi "+ p*180/PI);
    println("dt "+ dt);
    return p;
  }

  void computeState() {
    computeVelocity(t);
    AoF = atan2(-veloy, 1.-velox);
    v2 = (1-velox)*(1-velox)+veloy*veloy;

    PVector pforce = foil.pressForce(flow.p);
    //float ysign = ((pforce.y>0)?1:0)*2-1;
    F = pforce.y*cos(foil.phi)-pforce.x*sin(foil.phi);

    t = t-dt/2.0;
    dAoFdt = -heaveAmp*omega*omega*cos(omega*t)/(omega*omega*sin(omega*t)*sin(omega*t)*inlineAmp*inlineAmp-2*omega*sin(omega*t)*inlineAmp+heaveAmp*heaveAmp*omega*omega*sin(omega*t)*sin(omega*t)+1);
    t = t+dt/2.0;
  }

  void computeVelocity(float t) {
    float tnew = 0;
    if ((t%period)<(dfrac*period)) {
      tnew = t%period;
      veloy = heaveAmp*omega/(dfrac*2)*sin(omega/(dfrac*2)*tnew);
      velox = inlineAmp*omega/(dfrac*2)*sin(omega/(dfrac*2)*tnew);
      upstroke = false;
    }
    else {
      tnew = (t%period)-period*dfrac;
      veloy = -heaveAmp*omega/((1-dfrac)*2)*sin(omega/((1-dfrac)*2)*tnew);
      velox = -inlineAmp*omega/((1-dfrac)*2)*sin(omega/((1-dfrac)*2)*tnew);
      upstroke = true;
    }
  }

  float computePitch() {
    if (pitchmethod.equals("Cosine")){
      float pitchAmp = dAoA;
      if (upstroke) {
        pitchAmp = uAoA;
      }
      return pitchAmp/2-pitchAmp/2*cos(2*omega*t)+AoF;
    }

    if (pitchmethod.equals("Sine")){
      float pitchAmp = dAoA;
      if (upstroke) {
        pitchAmp = uAoA;
      }
      return pitchAmp*sin(omega*t)+AoF;
    }
    
    if (pitchmethod.equals("OpenLoop")){
      //Example: float stru = .5, stk = -120*PI/180, hc = 1.5, dAoA = 20*PI/180, uAoA = 20*PI/180, dfrac = .5;
      float pitchAmp = dAoA;
      if (upstroke) {
        pitchAmp = 0;
      }
      float vortcan = uAoA;
      return pitchAmp/2-pitchAmp/2*cos(2*omega*t)+vortcan/v2*cos(omega*t-1*PI/4.0)+AoF;
    }
    
    if (pitchmethod.equals("ClosedLoop")){
      float pitchAmp = dAoA;
      if (upstroke) {
        pitchAmp = -uAoA;
      }
      float AoAgain = a;
      Fd = a*v2*(pitchAmp/2-pitchAmp/2*cos(2*omega/(2*dfrac)*t));
      return controller(F/v2, Fd/v2);
    }

    if (pitchmethod.equals("Hummingbird")){
      //Taken from Tobalske profile: stru = .2, stk = -60*PI/180, hc = 1.5,
      return -25*PI/180*sin(omega*t)+(-5*PI/180*cos(omega*t)+5*PI/180)+10*PI/180;
    }
    
    if (pitchmethod.equals("Turtle")){
      //Taken from Davenport profile: stru = .5, stk = -120*PI/180, hc = 1.5,
      return -90*PI/180*sin(omega*t)*(0.5*cos(omega*t)+0.5)-10*PI/180;
    }
    
    if (pitchmethod.equals("NoPitch")){
      return 0;
    }
    throw new Error("Not a valid pitch method - check your spelling perhaps?");
  }
  void update() {
    if (flow.QUICK) {
      dt = flow.checkCFL();
      flow.dt = dt;
    }

    computeState();
    pitch = computePitch();
    foil.rotate(-foil.phi+pitch);

    computeVelocity(t-dt/2.0); //Recompute velocity for mid-timestep, fixes Euler drift
    foil.translate(velox*dt, veloy*dt);

    foil.update();
    flow.update(foil);
    flow.update2(foil);
    t += dt;
  }
  void display() {
    flood.display(flow.u.vorticity());
    foil.display();
    foil.displayVector(foil.pressForce(flow.p));
  }
}

