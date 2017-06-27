/**********************************
MG (MultiGrid) class

Sets up a PossionMatrix problem and solves with MG

Example code:

MG solver;
void setup(){
  size(512,512);
  noStroke();
  frameRate(.5);
  int N = 128+2;                               // <-Try changing the number of points
  VectorField u = new VectorField(N,N,1,-0.5);
  u.x.eq(0.,40,50,40,75);                      // Create divergent velocity field
  VectorField c = new VectorField(N,N,0,0);
  c.x.eq(1); c.y.eq(1); c.setBC();
  solver = new MG( new PoissonMatrix(c), new Field(N,N), u.divergence() );
  println(solver.tol);                          //  <- note dependance on N
}
void draw(){
  solver.update();                             // Do one solver iteration
  solver.r.display(-1e-5,1e-5);                // Visualize the residual
  println("ratio:"+solver.r.inner(solver.r)/solver.tol+", inf:"+solver.r.L_inf());
  if(solver.r.L_inf()<1e-5) noLoop();
}

 ***********************************/

Field MGsolver( float itmx, PoissonMatrix A, Field x, Field b ) {
  MG solver = new MG( A, x, b);
  while (solver.iter<itmx) {
    solver.update();
    if (solver.r.inner(solver.r)<solver.tol) break;
  }
  println("residual: "+solver.r.L_inf()+", iter: "+solver.iter);
  return solver.x;
}

class MG {
  PoissonMatrix A;
  Field r, x, d;
  int iter=0, level=0, its=4;
  float tol=1e-4;

  MG( PoissonMatrix A, Field x, Field b ) {
    this.A = A;
    this.x = x;
    r = new Field(x.n, x.m, 0, tol);
    tol = r.inner(r);
    r = A.residual(b, x);
  }
  MG( PoissonMatrix A, Field r, int level, int iter ) {
    this.A = A;
    this.r = r;
    x = new Field(r.n, r.m);
    this.level = level;
    this.iter = iter;
  }

  void update() {
    iter++;
    //println("  iter:"+iter);
    vCycle();
    smooth(its);
  }

  void vCycle() { // recursive MG V-cycle
    smooth(0);
    MG coarse = new MG(restrict(A), restrict(r), level+1, iter);
    //println("  level:"+level+"->"+coarse.level);
    if (coarse.divisible()) coarse.vCycle();
    coarse.smooth(its);
    //println("  level:"+coarse.level+"->"+level);
    d = prolongate(coarse.x);
    increment();
  }

  void smooth( int itmx ){
    d = r.times(A.inv);
    for( int it=0 ; it<itmx ; it++ ){
    for( int i=1 ; i<r.n-1 ; i++ )  {
    for( int j=1 ; j<r.m-1 ; j++ )  {
      d.a[i][j] = -(d.a[i-1][j]*A.lower.x.a[i][j]
                   +d.a[i+1][j]*A.lower.x.a[i+1][j]
                   +d.a[i][j-1]*A.lower.y.a[i][j]
                   +d.a[i][j+1]*A.lower.y.a[i][j+1]
                   -r.a[i][j])*A.inv.a[i][j];
    }}}
    d.setBC();
    increment();
  }

  void increment() {
    x.plusEq(d);
    r.minusEq(A.times(d));
  }

  boolean divisible() {
    boolean flag = (x.n-2)%2==0 && (x.m-2)%2==0 && x.n>4 && x.m>4;
    if ( !flag && x.n>9 && x.m>9 ) {
      println("MultiGrid requires the size in each direction be a large factor of two (2^p) times a small number (N=1..9).");
      exit();
    }
    return flag;
  }

  PoissonMatrix restrict( PoissonMatrix A ) {
    int n = (A.lower.n-2)/2+2;
    int m = (A.lower.m-2)/2+2;
    VectorField lower = new VectorField(n, m, 0, 0);
    for ( int i=1; i<n-1; i++ ) {
      for ( int j=1; j<m-1; j++ ) {
        int ii = (i-1)*2+1;
        int jj = (j-1)*2+1;
        lower.x.a[i][j] = (A.lower.x.a[ii][jj]+A.lower.x.a[ii][jj+1])*0.5;
        lower.y.a[i][j] = (A.lower.y.a[ii][jj]+A.lower.y.a[ii+1][jj])*0.5;
      }
    }
    lower.setBC();
    return new PoissonMatrix(lower);
  }

  Field restrict( Field a ) {
    int n = (a.n-2)/2+2;
    int m = (a.m-2)/2+2;
    Field b = new Field(n, m);
    for ( int i=1; i<n-1; i++ ) {
      for ( int j=1; j<m-1; j++ ) {
        int ii = (i-1)*2+1;
        int jj = (j-1)*2+1;
        b.a[i][j] = a.a[ii][jj]+a.a[ii][jj+1]+a.a[ii+1][jj]+a.a[ii+1][jj+1];
      }
    }
    b.setBC();
    return b;
  }

  Field prolongate( Field a ) {
    int n = (a.n-2)*2+2;
    int m = (a.m-2)*2+2;
    Field b = new Field(n, m);
    for ( int i=0; i<n; i++ ) {
      for ( int j=0; j<m; j++ ) {
        int ii = (i-1)/2+1;
        int jj = (j-1)/2+1;
        b.a[i][j] = a.a[ii][jj];
      }
    }
    b.setBC();
    return b;
  }
}