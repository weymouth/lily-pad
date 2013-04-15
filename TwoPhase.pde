/**********************************
TwoPhase class

Extends BDIM by adding two-phase modeling

This means we need to track the free interface and apply the 
variable density to the pressure gradient

example code:

TwoPhase flow;
void setup(){
  int n=(int)pow(2,7)+2, m=(int)pow(2,6)+2; size(800,400);
  flow = new TwoPhase(n,m,2,0.01);
  flow.f.eq(0,m,n,0,m);
  flow.u = new VectorField(n,m,0,0);
}
void draw(){
  flow.update();
  flow.update2();
  flow.f.display();
}
***************************************/

class TwoPhase extends BDIM{
  FreeInterface f,f0;

  TwoPhase( int n, int m, float dt, Body body, float nu, boolean QUICK, float g, float gamma ){
    super( n, m, dt, body, nu, QUICK);
    f  = new FreeInterface( n, m, gamma );
    f0 = new FreeInterface( n, m, gamma );
    this.g.y = g;
  }
  TwoPhase( int n, int m, float dt, float g ){
    this( n, m, dt, new CircleBody(-10.,-10.,0.,new Window()), 1, false, g, 0.1);
  }

  void update(){
    f.strang = (f.strang+1)%2; // strang operator splitting
    getRhoCoeffs();
    f0.eq(f);
    f.advect( dt, u0 );
    super.update();
  }
  void update2(){
    getRhoCoeffs();
    f.eq(f0);
    f.advect( dt, u0, u );
    super.update2();
  }
  void getRhoCoeffs(){
    rhoi.eq(f.rho().inv());
    c.eq(del.times(rhoi.times(dt)));    
  }
}
