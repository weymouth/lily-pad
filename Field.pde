/**********************************
Field class

Holds the values and operators for a
fluid dynamics field

example code:
Field p,u,v;

void setup(){
  size(400,400);
  background(1,0,0);
  p = new Field(100,150);
  p.eq(1.0,40,50,40,75);
  u = new Field(100,150,1,0.25);
  v = new Field(100,150,2,0.2);
}
void draw(){
  p.advect( 1., u, v );
  p.display(0,1);
}
***********************************/

class Field{
  float[][] a;  
  int n,m,btype=0;
  float bval=0;
  boolean gradientExit=false;
  
  Field( int n, int m, int btype, float bval ){
    this.n = n;
    this.m = m;
    this.a = new float[n][m];
    this.btype = btype;
    this.bval = bval;
    this.eq(bval);
  }
  Field( int n, int m){this(n,m,0,0);}

  Field( Field b, int is, int n, int js, int m ){
    this.n = n;
    this.m = m;
    a = new float[n][m];
    btype = b.btype;
    bval = b.bval;
    for( int i=0; i<n; i++){
    for( int j=0; j<m; j++){
      a[i][j] = b.a[i+is][j+js];
    }}
  }
  Field( Field b ){
    n = b.n;
    m = b.m;
    a = new float[n][m];
    btype = b.btype;
    bval = b.bval;
    this.eq(b);
  }

  Field laplacian (){
    Field d = new Field( n, m );
    for ( int i=1 ; i<n-1 ; i++ ) {
    for ( int j=1 ; j<m-1 ; j++ ) {
      d.a[i][j] = -4*a[i][j]+a[i+1][j]
        +a[i-1][j]+a[i][j+1]+a[i][j-1];
    }}
    return d;
  }

  VectorField gradient(){
    VectorField g = new VectorField(n,m,0,0);
    for ( int i=1 ; i<n-1 ; i++ ) {
    for ( int j=1 ; j<m-1 ; j++ ) {
      g.x.a[i][j] = a[i][j]-a[i-1][j];
      g.y.a[i][j] = a[i][j]-a[i][j-1];
    }}
    g.setBC(); // issues?
    return g;
  }

  void advect( float step, VectorField u, VectorField u0 ){
    advect( step, u.x, u.y, u0.x, u0.y );
  }
  void advect( float step, Field u, Field v, Field u0, Field v0 ){
    /* advect the field with the u,v velocity field
       here we use a first order lagrangian method
         Da/Dt = 0
         a(t=dt,x,y) = a(t=0,x-dt*u(x,y),y-dt*v(x,y))
       the example code shows how diffusive this is 
       EDIT: by using an RK2 step to find x0 and using
       a quadratic interpolation, this method is second
       order and nondiffuse.
       EDIT2: by treating the old and new velocities 
       seperately, the method is second order in time.*/
    Field a0 = new Field(this);
    for( int i=1; i<n-1; i++){
      for( int j=1; j<m-1; j++){
        float x = i;
        float y = j;
        if(btype==1) x -= 0.5;
        if(btype==2) y -= 0.5;
        float ax = -step*u.linear( x, y );
        float ay = -step*v.linear( x, y );
        float bx = -step*u0.linear( x+ax, y+ay );
        float by = -step*v0.linear( x+ax, y+ay );
        a[i][j] = a0.quadratic( x+0.5*(ax+bx), y+0.5*(ay+by) );
      }
    }
    setBC();
  }
  void advect( float step, VectorField u ){
    advect( step, u.x, u.y );
  }
  void advect( float step, Field u, Field v){
    /* advect the field with the u,v velocity field
       here we use a first order lagrangian method
         Da/Dt = 0
         a(t=dt,x,y) = a(t=0,x-dt*u(x,y),y-dt*v(x,y))
       the example code shows how diffusive this is 
       EDIT: by using an RK2 step to find x0 and using
       a quadratic interpolation, this method is second
       order and nondiffuse.
       EDIT2: RK2 step is not needed for first step
       in time accurate soln.*/
    Field a0 = new Field(this);
    for( int i=1; i<n-1; i++){
      for( int j=1; j<m-1; j++){
        float x = i;
        float y = j;
        if(btype==1) x -= 0.5;
        if(btype==2) y -= 0.5;
        float ax = -step*u.linear( x, y );
        float ay = -step*v.linear( x, y );
        a[i][j] = a0.quadratic( x+ax, y+ay );
      }
    }
    setBC();
  }

  float quadratic( float x0, float y0){
    float x = x0, y = y0;
    if(btype==1) x += 0.5;
    if(btype==2) y += 0.5;
    int i = round(x), j = round(y);
    if( i>n-2 || i<1 || j>m-2 || j<1 )
      return linear( x0, y0 );
    x -= i; y -= j;
    float e = quadratic1D(x,a[i-1][j-1],a[i][j-1],a[i+1][j-1]);
    float f = quadratic1D(x,a[i-1][j  ],a[i][j  ],a[i+1][j  ]);
    float g = quadratic1D(x,a[i-1][j+1],a[i][j+1],a[i+1][j+1]);
    return quadratic1D(y,e,f,g);
  }
  float quadratic1D(float x, float e, float f, float g){
    float x2 = x*x;
    float fx = f*(1.-x2);
    fx += (g*(x2+x)+e*(x2-x))*0.5;
    fx = min(fx,max(e,f,g));
    fx = max(fx,min(e,f,g));
    return fx;
  }  
  float linear( float x0, float y0 ){
    float x  = min(max(0.5,x0), n-1.5);
    if(btype==1) x += 0.5;
    int i = min( (int)x, n-2 ); 
    float s = x-i;
    float y  = min(max(0.5,y0), m-1.5);
    if(btype==2) y += 0.5;
    int j = min( (int)y, m-2 );
    float t = y-j;
    if(s==0 && t==0){
      return a[i][j];
    }else{
      return s*(t*a[i+1][j+1]+(1-t)*a[i+1][j])+
         (1-s)*(t*a[i  ][j+1]+(1-t)*a[i  ][j]);
    }
  }
  float interp( float x0, float y0 ){return linear(x0,y0);}
  
  void display( float low, float high ){
    PImage img = createImage(n,m,RGB);
    img.loadPixels();
    for ( int i=0 ; i<n ; i++ ) {
      for ( int j=0 ; j<m ; j++ ) {
        float f = a[i][j];
        int k = i+j*n;
        f = map(f,low,high,0,255);
        img.pixels[k] = color(f);
      }
    }
    img.updatePixels();
    image(img,0,0,width,height);
  }

  void setBC (){
    float s=0;
    for (int j=0 ; j<m ; j++ ) {  
      a[0][j]   = a[1][j];  
      a[n-1][j] = a[n-2][j];      
      if(btype==1){
        if(gradientExit){
          a[1][j]   = bval;  
          s += a[n-1][j];          
        } else {
          a[1][j]   = bval;  
          a[n-1][j] = bval;
    }}}
    for (int i=0 ; i<n ; i++ ) {  
      a[i][0]   = a[i][1];  
      a[i][m-1] = a[i][m-2];
      if(btype==2){
        a[i][1]   = bval;  
        a[i][m-1] = bval;
      }   
    }
    if(gradientExit){
      s /= (float)m;
      for( int j=0; j<m; j++ ) a[n-1][j] += bval-s;
    }
  }

  Field times( float b ){
    Field c = new Field(this);
    for( int i=0; i<n; i++){
    for( int j=0; j<m; j++){
        c.a[i][j] *= b;
    }}
    return c;
  }
  Field times( Field b ){
    Field c = new Field(this);
    for( int i=0; i<n; i++){
    for( int j=0; j<m; j++){
      c.a[i][j] *= b.a[i][j];
    }}
    return c;
  }
  void timesEq( float b ){ eq(times(b)); }
  void timesEq( Field b ){ eq(times(b)); }
  Field plus( float b ){
    Field c = new Field(this);
    for( int i=0; i<n; i++){
    for( int j=0; j<m; j++){
      c.a[i][j] += b;
    }}
    return c;
  }
  Field plus( Field b ){
    Field c = new Field(this);
    for( int i=0; i<n; i++){
    for( int j=0; j<m; j++){
      c.a[i][j] += b.a[i][j];
    }}
    return c;
  }
  void plusEq( Field b ){ eq(plus(b)); }
  void plusEq( float b ){ eq(plus(b)); }
  Field minus( Field b ){
    Field c = new Field(this);
    for( int i=0; i<n; i++){
    for( int j=0; j<m; j++){
      c.a[i][j] -= b.a[i][j];
    }}
    return c;
  }
  void minusEq( Field b ){ eq(minus(b)); }
  Field inv(){
    Field c = new Field(this);
    for( int i=0; i<n; i++){
    for( int j=0; j<m; j++){
      c.a[i][j] = 1./c.a[i][j];
    }}
    return c;
  }
  void invEq(){ eq(inv()); }
  float inner( Field b ){
    float s = 0;
    for ( int i=1 ; i<n-1 ; i++ ) {
    for ( int j=1 ; j<m-1 ; j++ ) {
      s += a[i][j]*b.a[i][j];
    }} 
    return s;
  }
  float sum(){
    float s = 0;
    for ( int i=1 ; i<n-1 ; i++ ) {
    for ( int j=1 ; j<m-1 ; j++ ) {
      s += a[i][j];
    }} 
    return s;
  }
  void eq( float b ,int is, int ie, int js, int je){
    for( int i=is; i<ie; i++){
    for( int j=js; j<je; j++){
      a[i][j] = b;
    }}
  }
  void eq( float b){eq(b,0,n,0,m);}
  void eq( Field b){
    for( int i=0; i<n; i++){
    for( int j=0; j<m; j++){
      a[i][j] = b.a[i][j];
    }}
  }
}
