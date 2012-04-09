/*********************************************************
solve the BDIM equation for velocity and pressure
  assuming a stationary body and single phase uniform flow

   u = del*[u0-dt*(u0.grad{u0}+f_grav)]+(1-del)*U

*********************************************************/
class BDIM{
  int n,m; // number of cells in uniform grid
  float dt, nu, eps=2.0; // time resolution
  VectorField u,del,del1,c,u0,u1,c2,ub,wnx,wny,distance;
  Field p;
  boolean QUICK;

  BDIM( int n, int m, float dt, Body body, float nu, boolean QUICK ){
    this.n = n; this.m = m;
    this.dt = dt;
    this.nu=nu;
    this.QUICK=QUICK;
    u = new VectorField(n,m,1,0);
    u0 = new VectorField(n,m,0,0);
    u1 = new VectorField(n,m,0,0);
    p = new Field(n,m);
    ub  = new VectorField(n,m,0,0);
    distance =  new VectorField(n, m, 10, 10);    
    del = new VectorField(n,m,1,1);
    del1 = new VectorField(n,m,0,0);
    c = new VectorField(del);
    c2 = new VectorField(c);
    wnx = new VectorField(n,m,0,0);
    wny = new VectorField(n,m,0,0);
    
    u.x.gradientExit = true;

    get_coeffs(body);    
  }
  
  BDIM( int n, int m, float dt, Body body){this(n,m,dt,body,1,false);}
  
  void update(){
    /* O(dt,dx^2) BDIM update
          x0 = x-dt*u0
          u = del*(u0(x0)-dt*grad(p))+ub  */
    u0.eq(u);
    if(QUICK) u0.AdvDif(u,dt,nu);
    else u.advect(dt,u0);
    u1.eq(u.minus(ub));
    u.timesEq(del);
    u.minusEq(ub.times(del.plus(-1)));
    u.plusEq(del1.times(u1.normalGrad(wnx,wny)));  // first order correction
    u.setBC();
    p = u.project(c,p);
  }
  
  void update2(){
    /* O(dt^2,dt^2) BDIM update
          u* from O(dt) update()
          x0 = x-0.5*dt*(u*+u0(x-dt*u*))
          u = del*(u0(x0)-0.5*dt*(grad(p*(x0))+grad(p)))+ub  */
    VectorField us = new VectorField(u); // set u*=u from O(dt) update()
    if(QUICK){
      us.AdvDif(u, dt, nu);
      u1.eq(u.minus(ub));
      u.timesEq(del);
      u.minusEq(ub.times(del.plus(-1)));
      u.plusEq(del1.times(u1.normalGrad(wnx,wny)));   // first order correction
      u.setBC();
      p = u.project(c,p);
      u.plusEq(u0);
      u.timesEq(0.5); 
    }
    else{
      u.eq(u0);                            // reset u
      VectorField dp = p.gradient();
      dp.setBC();
      u.advect(dt,us,u0);  // O(dt^2) advect for both u0
      u1.eq(u.minus(ub));
      dp.advect(dt,us,u0); // ... and grad(p)
      dp.timesEq(-0.5*dt);
      u.plusEq(dp);
      u.timesEq(del);
      u.minusEq(ub.times(del.plus(-1)));
      u.plusEq(del1.times(u1.normalGrad(wnx,wny)));
      u.setBC();
      p = u.project(c2,p);
    }
  }

  void update( Body body ){
    if(body.unsteady||QUICK){get_coeffs(body);}else{ub.eq(0.);}
    update();
  }

  void update2( Body body ){
    if(body.unsteady||QUICK){get_coeffs(body);}else{ub.eq(0.);}
    update2();
  }

  void get_coeffs( Body body ){
    get_dist(body);
    get_del();
    get_del1();
    get_ub(body);
    get_wn(body);
    c.eq(del);
    c.timesEq(dt);
    c2.eq(c);
    c2.timesEq(0.5);
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
      return 0.5*(1.+d/eps*(2.-abs(d/eps)));
    } 
  }
  
  float delta1( float d ){
    if( abs(d) >= eps){
      return 0;
    } else{
        return 1./3.*(1.-sq(d/eps)*(3-2*abs(d/eps)));
    } 
  }
  
  float checkCFL() { 
    return min(u.CFL(nu), 1);
  }
}
