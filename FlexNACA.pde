/*******************************************

NACA foil with superimposed traveling wave motions

********************************/
class FlexNACA extends NACA{
  float k,omega,T,x0,time=0;
  float[] a;

  FlexNACA( float x, float y, float c, float t, float St, float vp, float _k, float[] _a, Window window ){
    super( x, y, c, t, window );
    x0 = x-0.25*c;
    k = _k*TWO_PI/c;
    omega = vp*k;
    T = TWO_PI/omega;
    
    a = _a;
    float s = 0; 
    for(float ai: a) s += ai;
    if(s==0) {s=1; a[0]=1;}
    for(int i=0; i<a.length; i++) a[i] *= St*T/s;
  }

// amplitude envelope
  float Ax( float x){
    float amp = 0;
    for (int i=0; i<a.length; i++) amp += a[i]*pow((x-x0)/c,i);
    return amp;
  }
// displacement
  float h( float x ) { return Ax(x)*sin(k*x-omega*time); }
// velocity
  float hdot( float x ) { return -Ax(x)*omega*cos(k*x-omega*time); }

  void display( color C, Window window ){
    fill(C); noStroke();
    beginShape();
    for ( PVector x: coords ) {
      float y = x.y + h(x.x);
      vertex(window.px(x.x),window.py(y));
    }
    endShape(CLOSE);
  }

  float distance( float x, float y ){ 
    return super.distance( x, y-h(x) ); 
  }
    
  float velocity( int d, float dt, float x, float y ) {
    float v = super.velocity(d,dt,x,y);
    return (d==1)?v:v+hdot(x); 
  }
  
  void update(float dt) {
    super.update();
    time += dt;
    unsteady = true;
  }
}
