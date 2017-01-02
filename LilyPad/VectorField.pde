/**********************************
VectorField class

Holds the values and operators for a
vector field

Example code:
void setup(){
  size(400,400);
  noStroke();
  int N = 130;
  VectorField u = new VectorField(N,N,1,-0.5);
  u.x.eq(0.,40,50,40,75);
  VectorField c = new VectorField(N,N,0,0);
  c.x.eq(1); c.y.eq(1); c.setBC();
  Field p = new Field(N,N);
//  u.project(c,p);  // uncomment to see the effect of projection on the divergence.
  u.divergence().display(-.1,.1);
}
***********************************/

class VectorField{
  Field x,y;
  int n, m;
  float CF=1./6., S=10.;  // QUICK parameters

  VectorField( int n, int m, float xval, float yval ){
    this.n = n;
    this.m = m;
    x = new Field( n, m, 1, xval );
    y = new Field( n, m, 2, yval );
  }
  VectorField( Field x, Field y ){
    n = x.n;
    m = x.m;
    this.x = new Field(x);
    this.y = new Field(y);
  }
  VectorField( VectorField b ){this( b.x, b.y );}
  
  void setBC(){
    x.setBC(); 
    y.setBC(); 
  }

  VectorField normalGrad(VectorField wnx, VectorField wny){
    VectorField g = new VectorField(n,m,0,0);
    for ( int i=1 ; i<n-1 ; i++ ) {
    for ( int j=1 ; j<m-1 ; j++ ) {
      g.x.a[i][j] = 0.5*(wnx.x.a[i][j]*(x.a[i+1][j]-x.a[i-1][j])+wny.x.a[i][j]*(x.a[i][j+1]-x.a[i][j-1]));
      g.y.a[i][j] = 0.5*(wnx.y.a[i][j]*(y.a[i+1][j]-y.a[i-1][j])+wny.y.a[i][j]*(y.a[i][j+1]-y.a[i][j-1]));
    }}
    return g; 
  }

  Field divergence (){
    // returns div{this} for unit cells
    Field d = new Field( n, m );
    for ( int i=1 ; i<n-1 ; i++ ) {
    for ( int j=1 ; j<m-1 ; j++ ) {
      d.a[i][j] = x.a[i+1][j]-x.a[i][j]+
                  y.a[i][j+1]-y.a[i][j];
    }}
    return d;
  }

  Field ke (){
    // returns 0.5*{this-bval}^2 for unit cells
    Field d = new Field( n, m );
    for ( int i=1 ; i<n-1 ; i++ ) {
    for ( int j=1 ; j<m-1 ; j++ ) {
      d.a[i][j] = (sq(x.a[i+1][j]+x.a[i][j]-2.*x.bval)+
                   sq(y.a[i][j+1]+y.a[i][j]-2.*y.bval))*0.125;
    }}
    return d;
  }

  Field curl (){
    // returns curl{this} located at cell corner (btype=3)
    Field d = new Field( n, m, 3, 0 );
    for ( int i=1 ; i<n-1 ; i++ ) {
    for ( int j=1 ; j<m-1 ; j++ ) {
      d.a[i][j] = x.a[i][j-1]-x.a[i][j]+
                  y.a[i][j]-y.a[i-1][j];
    }}
    return d;
  }

  Field Qcrit (){
    Field q = new Field( n, m );
    for ( int i=1 ; i<n-1 ; i++ ) {
    for ( int j=1 ; j<m-1 ; j++ ) {
    float dudx = 0.5*(x.a[i+1][j]-x.a[i-1][j]);
    float dudy = 0.5*(x.a[i][j+1]-x.a[i][j-1]);
    float dvdx = 0.5*(y.a[i+1][j]-y.a[i-1][j]);
    float dvdy = 0.5*(y.a[i][j+1]-y.a[i][j-1]);
    q.a[i][j] = dudx*dvdy-dvdx*dudy;
    }}
    return q;
  }
  Field streamFunc() {
    //Integrates the flow field to get a stream function
    Field psi = new Field( n, m );
    float[][] s1 = new float[n][m];
    float[][] s2 = new float[n][m];

    //Integrate from top left corner
    for (int i=0 ; i<n ; i++ )
      s1[i][0] = 0;
    for (int i=0 ; i<n ; i++ )
      for (int j=1 ; j<m ; j++ )
        s1[i][j] = s1[i][j-1]+0.5*(x.a[i][j-1]+x.a[i][j]);

    //Integrate from lower right corner
    s2[n-1][m-1]=0;
    for (int i=n-2; i>=0; i--)
      s2[i][m-1] = 0;
    for (int i=0 ; i<n ; i++ )
      for (int j=m-2 ; j>=0; j-- )
        s2[i][j] = s2[i][j+1]-0.5*(x.a[i][j+1]+x.a[i][j]);

    //Average both solutions
    float basepsi = s2[0][0];
    for (int i=0 ; i<n ; i++ )
      for (int j=0 ; j<m ; j++ )
        psi.a[i][j] = 0.5*(s1[i][j] + s2[i][j]-basepsi);    
    return psi;
  }

  Field project ( VectorField coeffs, Field p, Field s ){
    /* projects u,v onto a divergence-free field using
         div{coeffs*grad{p}} = div{u}  (1)
         u -= coeffs*grad{p}           (2)
       and returns the field p. all FDs are on unit cells */
    p = MGsolver( 20, new PoissonMatrix(coeffs), p , s );
    p.plusEq(-1*p.sum()/(float)((n-2)*(m-2)));
    VectorField dp = p.gradient();
    x.plusEq(coeffs.x.times(dp.x.times(-1)));
    y.plusEq(coeffs.y.times(dp.y.times(-1)));
    setBC();
    return p;
  }
  Field project ( VectorField coeffs, Field p ){ return project(  coeffs, p, this.divergence() ); }

  void display( float unit, int skip){
    stroke(#993333);
    float DX = width/(float)n;
    float DY = height/(float)m;
    for ( int i=0 ; i<n ; i+=skip ) {
    for ( int j=0 ; j<m ; j+=skip ) {
      float px = i*DX;
      float py = j*DY;
      arrow(px,py,px+DX*unit*x.a[i][j],py+DY*unit*y.a[i][j]);
    }}
    noStroke();
  }  
  private void arrow(float x1, float y1, float x2, float y2) {
    float a = atan2(x1-x2, y2-y1);
    float b = 0.1*mag(x1-x2, y2-y1);
//    if(b<.1) return;
    line(x1, y1, x2, y2);
    pushMatrix();
      translate(x2, y2);
      rotate(a);
      line(0, 0, -b, -b);
      line(0, 0,  b, -b);
    popMatrix();
  } 
  
   void AdvDif(VectorField u0, float dt, float nu) {
     VectorField v = new VectorField(this);
     for ( int j=1; j<m-1; j++) {
      for ( int i=1; i<n-1; i++) {
        v.x.a[i][j] = (advection(x, i, j) + nu*diffusion(x, i, j))*dt+u0.x.a[i][j];
        v.y.a[i][j] = (advection(y, i, j) + nu*diffusion(y, i, j))*dt+u0.y.a[i][j];
      }
    }
    this.eq(v);   
  }

  float advection (Field b, int i, int j) {  
    float uo, ue, vs, vn;
    if (b.btype == 1) {
      uo = 0.5*(x.a[i-1][j]+x.a[i][j]);
      ue = 0.5*(x.a[i+1][j]+x.a[i][j]);
      vs = 0.5*(y.a[i][j]+y.a[i-1][j]);
      vn = 0.5*(y.a[i][j+1]+y.a[i-1][j+1]);
    }
    else {
      uo = 0.5*(x.a[i][j-1]+x.a[i][j]);
      ue = 0.5*(x.a[i+1][j-1]+x.a[i+1][j]);
      vs = 0.5*(y.a[i][j-1]+y.a[i][j]);
      vn = 0.5*(y.a[i][j]+y.a[i][j+1]);
    }
    return ((uo*bho(b, i, j, -1, 0, uo) - ue*bho(b, i, j, 1, 0, ue)) + (vs*bho(b, i, j, 0, -1, vs) - vn*bho(b, i, j, 0, 1, vn)));
  }

  float diffusion (Field b, int i, int j) {
    return b.a[i+1][j] + b.a[i][j+1] - 4*b.a[i][j] + b.a[i-1][j] + b.a[i][j-1];
  }

  float bho(Field b, int i, int j, int d1, int d2, float uf) {
    float bf =  0.5*(b.a[i+d1][j+d2]+b.a[i][j]); 
    if (d1*uf<0){
     i += d1; 
     d1 = -d1;
    }
    if (d2*uf<0){
     j += d2;
     d2 = -d2;
    } 
    if ( i>n-2 || i<2 || j>m-2 || j<2 ) return bf;
    float bc = b.a[i][j];
    float bd = b.a[i+d1][j+d2];
    float bu = b.a[i-d1][j-d2];
    bf -= CF*(bd-2*bc+bu);
    float b1 = bu+S*(bc-bu);
    return med(bf, bc, med(bc, bd, b1));
  }

  float med(float a, float b, float c) {
    return(max(min(a, b), min(max(a, b), c)));
  }

  float CFL(float nu) {
    float b = abs(x.a[0][0])+abs(y.a[0][0]);
    float c;
    for ( int i=1; i<n-1; i++) {
      for ( int j=1; j<m-1; j++) { 
        c = abs(x.a[i][j])+abs(y.a[i][j]);
        if (c>b) b=c;
      }
    }
    return 1./(b+3.*nu);
  }
  
  VectorField times( VectorField b){
    VectorField g = new VectorField(this);
    g.timesEq(b);
    return g;
  }
  
  VectorField times( float b){
    VectorField g = new VectorField(this);
    g.timesEq(b);
    return g;
  }
  
  VectorField plus( VectorField b){
    VectorField g = new VectorField(this);
    g.plusEq(b);
    return g;
  }
  
  VectorField minus( VectorField b){
    VectorField g = new VectorField(this);
    g.minusEq(b);
    return g;
  }
  
  VectorField plus( float b){
    VectorField g = new VectorField(this);
    g.plusEq(b);
    return g;
  }  

  VectorField inv(){ 
    VectorField g = new VectorField(this);
    g.invEq();
    return g;
  }

  VectorField laplacian(){
    return new VectorField(x.laplacian(),y.laplacian());
  }
  
  void eq( VectorField b ){ x.eq(b.x); y.eq(b.y);}
  void eq( float b ){ x.eq(b); y.eq(b);}
  void timesEq( VectorField b ){ x.timesEq(b.x); y.timesEq(b.y);}
  void timesEq( float b ){ x.timesEq(b); y.timesEq(b);}
  void plusEq( VectorField b ){ x.plusEq(b.x); y.plusEq(b.y);}
  void plusEq( float b ){ x.plusEq(b); y.plusEq(b);}  
  void plusEq( PVector b ){ x.plusEq(b.x); y.plusEq(b.y);}  
  void minusEq( VectorField b ){ x.minusEq(b.x); y.minusEq(b.y);}  
  void advect( float dt, VectorField b ){ x.advect(dt,b); y.advect(dt,b);}
  void advect( float dt, VectorField b, VectorField b0 ){ x.advect(dt,b,b0); y.advect(dt,b,b0);}
  void invEq(){ x.invEq(); y.invEq();}  
}