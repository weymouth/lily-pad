/*********************************************************
solve the BDIM equation for velocity and pressure

  u = del*F+[1-del]*u_b+del_1*ddn(F-u_b)
  
  where 
    del is the zeroth moment of the smoothing kernel integral
    del_1 is the first moment (zero if mu1=false)
    u_b is the body velocity
    F is the fluid equation of motion:
    if(QUICK):
      F(u) = u(t)+\int_t^{t+dt} grad(u*u)+\mu*laplace(u)+g-grad(p)/rho \d t
    else(SEMI-LAGRANGIAN)
      F(u) = u(t,x(t))+\int_t^{t+dt} g-grad(p)/rho \d t
      
    where x(t) is the back-casted location of the grid points
      x(t) = x-\int_t^{t+dt} u \d t

Example code:

BDIM flow;
CircleBody body;
void setup(){
  size(400,400); 
  int n=(int)pow(2,6)+2; // multigrid solver needs n = power of 2 
  Window view = new Window(n,n);
  body = new CircleBody(n/3,n/2,n/8,view);
  flow = new BDIM(n,n,1.5,body);
}
void draw(){
  flow.update();  // project
  flow.update2(); // correct
  flow.u.vorticity().display(-0.75,0.75);
  body.display();
}
*********************************************************/
class BDIM{
  int n,m; // number of cells in uniform grid
  float dt, nu, eps=2.0;
  PVector g= new PVector(0,0);
  VectorField u,del,del1,c,u0,ub,wnx,wny,distance,rhoi;
  Field p;
  boolean QUICK, mu1=true, adaptive=false;

  BDIM( int n, int m, float dt, Body body, VectorField uinit, float nu, boolean QUICK ){
    this.n = n; this.m = m;
    this.dt = dt;
    this.nu=nu;
    this.QUICK=QUICK;

    u = uinit;
    if(u.x.bval!=0) u.x.gradientExit = true;
    u0 = new VectorField(n,m,0,0);
    p = new Field(n,m);
    if(dt==0) setDt(); // adaptive time stepping for O(2) QUICK

    ub  = new VectorField(n,m,0,0);
    distance =  new VectorField(n, m, 10, 10);    
    del = new VectorField(n,m,1,1);
    del1 = new VectorField(n,m,0,0);
    rhoi = new VectorField(del);
    c = new VectorField(del);
    wnx = new VectorField(n,m,0,0);
    wny = new VectorField(n,m,0,0);
    get_coeffs(body);
  }
  
  BDIM( int n, int m, float dt, Body body, float nu, boolean QUICK, int u_inf){
    this(n,m,dt,body,new VectorField(n,m,u_inf,0),nu,QUICK);}
  BDIM( int n, int m, float dt, Body body, float nu, boolean QUICK ){
    this(n,m,dt,body,new VectorField(n,m,1,0),nu,QUICK);}
  
  // If no body is supplied, create a body outside the domain
  BDIM( int n, int m, float dt, VectorField uinit, float nu, boolean QUICK ){
    this(n,m,dt,new CircleBody(-n/2,-m/2,n/10,new Window(0,0,n,m)),uinit,nu,QUICK);}
  
  BDIM( int n, int m, float dt, Body body){this(n,m,dt,body,new VectorField(n,m,1,0),1,false);}
  
  void update(){
    // O(dt,dx^2) BDIM projection step:
    c.eq(del.times(rhoi.times(dt))); 
    u0.eq(u);
    VectorField F = new VectorField(u);
    if(QUICK) F.AdvDif( u0, dt, nu );
    else F.advect( dt, u0 );
    updateUP( F, c );
  }
  
  void update2(){
    // O(dt^2,dt^2) BDIM correction step:
    VectorField us = new VectorField(u), F = new VectorField(u);
    if(QUICK){
      F.AdvDif( u0, dt, nu );
      updateUP( F, c );
      u.plusEq(us); 
      u.timesEq(0.5);
      if(adaptive) dt = checkCFL();
    }
    else{
      F.eq(u0.minus(p.gradient().times(rhoi.times(0.5*dt))));
      F.advect(dt,us,u0); 
      updateUP( F, c.times(0.5) );
    }
  }
  
  void updateUP( VectorField R, VectorField coeff ){
/*  Seperate out the pressure from the forcing
      del*F = del*R+coeff*gradient(p)
    Approximate update (dropping ddn(grad(p))) which doesn't affect the accuracy of the velocity
      u = del*R+coeff*gradient(p)+[1-del]*u_b+del_1*ddn(R-u_b)
    Take the divergence
      div(u) = div(coeff*gradient(p)+stuff) = 0
    u.project solves this equation for p and then projects onto u
*/
    R.plusEq(PVector.mult(g,dt));
    u.eq(del.times(R).minus(ub.times(del.plus(-1))));
    if(mu1) u.plusEq(del1.times((R.minus(ub)).normalGrad(wnx,wny)));
    u.setBC();
    p = u.project(coeff,p);    
  }

  void update( Body body ){
    if(body.unsteady){get_coeffs(body);}else{ub.eq(0.);}
    update();
  }
  void update2( Body body ){update2();} // don't need to get coeffs again

  void get_coeffs( Body body ){
    get_dist(body);
    get_del();
    get_del1();
    get_ub(body);
    get_wn(body);
  }
  
  void get_ub( Body body ){
    /* Immersed Velocity Field
          ub(x) = U(x)*(1-del(x))
    where U is the velocity of the body */
    for ( int i=1 ; i<n-1 ; i++ ) {
    for ( int j=1 ; j<m-1 ; j++ ) {
        ub.x.a[i][j] = body.velocity(1,dt,(float)(i-0.5),j);
        ub.y.a[i][j] = body.velocity(2,dt,i,(float)(j-0.5));
    }}
  }
  
  void get_wn(Body body){
   /* wall normal direction of the closest body point */
   PVector wn;
    for ( int i=1 ; i<n-1 ; i++ ) {
    for ( int j=1 ; j<m-1 ; j++ ) {
      wn = body.WallNormal((float)(i-0.5),j);
      wnx.x.a[i][j]=wn.x;
      wny.x.a[i][j]=wn.y;
      wn = body.WallNormal(i,(float)(j-0.5));
      wnx.y.a[i][j]=wn.x;
      wny.y.a[i][j]=wn.y;
    }}   
  }
  
  void get_dist( Body body ) {
    for ( int i=1 ; i<n-1 ; i++ ) {
      for ( int j=1 ; j<m-1 ; j++ ) {
        distance.x.a[i][j] = body.distance((float)(i-0.5), j);
        distance.y.a[i][j] = body.distance(i, (float)(j-0.5));
      }
    }
  }
  
  void get_del( ){
    /* BDIM zeroth order moment
          del(x) = delta0(d(x))
    where d is the distance to the interface from x */
    for ( int i=1 ; i<n-1 ; i++ ) {
    for ( int j=1 ; j<m-1 ; j++ ) {
        del.x.a[i][j] = delta0(distance.x.a[i][j]);
        del.y.a[i][j] = delta0(distance.y.a[i][j]);
    }}
    del.setBC();
  }
  
  void get_del1(){
    /* BDIM first order moment
          del(x) = delta1(d(x))
    where d is the distance to the interface from x */
    for ( int i=1 ; i<n-1 ; i++ ) {
    for ( int j=1 ; j<m-1 ; j++ ) {
        del1.x.a[i][j] = delta1(distance.x.a[i][j]);
        del1.y.a[i][j] = delta1(distance.y.a[i][j]);
    }}
    del1.setBC();
  }

  
  float delta0( float d ){
    if( d <= -eps ){
      return 0;
    } else if( d >= eps ){
      return 1;
    } else{
      return 0.5*(1.+d/eps+sin(PI*d/eps)/PI);
    } 
  }
  
  float delta1( float d ){
    if( abs(d) >= eps){
      return 0;
    } else{
        return 0.25*(eps-sq(d)/eps)-1/TWO_PI*(d*sin(d*PI/eps)+eps/PI*(1+cos(d*PI/eps)));
    } 
  }
  
  float checkCFL() { 
    return min(u.CFL(nu), 1);
  }
  
  void setDt(){
    dt = checkCFL();
    if(QUICK) adaptive = true;
  }
}
