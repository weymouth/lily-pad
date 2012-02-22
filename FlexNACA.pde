/*******************************************

FlexNACA: NACA foil with superimposed traveling wave motions

Adding the wave to the body makes it non-convex and adds divergence to the body velocity.
Therefore a second geom "orig" is used to hold the original NACA coords.
Transformations are applied to the distance and normal calculations on the convex original geom.
The divergence free wave velocity is use for the body velocity field.

********************************/
class FlexNACA extends NACA{
  float k,omega,T,x0,time=0;
  float[] a;
  NACA orig;

  FlexNACA( float x, float y, float c, float t, float St, float vp, float _k, float[] _a, Window window ){

// set the NACA coords and save as orig
    super( x, y, c, t, window );
    orig = new NACA( x, y, c, t, window );

// set the wave parameters
    x0 = x-0.25*c;
    k = _k*TWO_PI/c;
    omega = vp*k;
    T = TWO_PI/omega;

// set the amplitude envelope    
    a = _a;
    float s = 0; 
    for(float ai: a) s += ai;
    if(s==0) {s=1; a[0]=1;}
    for(int i=0; i<a.length; i++) a[i] *= St*T/s;

// add wave to the coords
    for ( PVector xx: coords ) xx.y += h(xx.x);
  }
  
  float distance( float x, float y ){ // shift y and use orig distance
    return orig.distance( x, y-h(x) ); 
  }
  PVector WallNormal(float x, float y  ){ // shift y and adjust orig normal
    PVector n = orig.WallNormal(x,y-h(x));
    n.x -= dhdx(x)*n.y;
    return PVector.div(n,n.mag());
  }
  float velocity( int d, float dt, float x, float y ){ // use wave velocity
    float v = super.velocity(d,dt,x,y);
    if(d==1) return v;
    else return v+hdot(x); 
  }
  
  void translate( float dx, float dy ){ // translate both geoms and wave
    super.translate(dx,dy);
    orig.translate(dx,dy);
    x0+=dx;
  }
  void rotate( float dphi ){} // no rotation

  void update(float dt) { // update time and coords
    for ( PVector x: coords ) x.y -= h(x.x);
    time += dt;
    for ( PVector x: coords ) x.y += h(x.x);
    getOrth();
    unsteady = true;
  }

/* The wave is given by h = A(x)*sin(k*x-omega*t)
   The amplitude envelope is polynomial. 
   The time and space derivatives are needed for the transforms above. */
  float Ax( float x){
    float amp = a[0];
    for (int i=1; i<a.length; i++) amp += a[i]*pow((x-x0)/c,i);
    return amp;
  }
  float arg( float x)   { return k*(x-x0)-omega*time; }
  float h( float x )    { return Ax(x)*sin(arg(x)); }
  float hdot( float x ) { return -Ax(x)*omega*cos(arg(x)); }
  float dhdx( float x ) { // = A k cos + dA/dx sin
    float amp = a[1]/c; // dAdx
    for (int i=2; i<a.length; i++) amp += a[i]*(float)i/c*pow((x-x0)/c,i-1);
    return Ax(x)*k*cos(arg(x))+amp*sin(arg(x)); 
  }  
}
