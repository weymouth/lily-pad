/**********************************
MG (MultiGrid) class

Sets up a PossionMatrix problem and solves
with MG

Example code:

MG solver;
void setup(){
  size(400,400);
  noStroke();
  frameRate(1);
  colorMode(RGB,1.0);
  int N = 130;
  VectorField u = new VectorField(N,N,1,-0.5);
  u.x.eq(0.,40,50,40,75);
  VectorField c = new VectorField(N,N,0,0);
  c.x.eq(1); c.y.eq(1); c.setBC();
  solver = new MG( new PoissonMatrix(c), new Field(N,N), u.divergence() );
}
void draw(){
  solver.update();
  solver.r.display(-0.1,0.1);
  println(solver.r.inner(solver.r));
}
***********************************/

Field MGsolver( float itmx, PoissonMatrix A, Field x, Field b ){
  MG solver = new MG( A, x, b);
  solver.update(itmx);
  println("residual: "+solver.r.inner(solver.r)+", iter: "+solver.iter);
  return solver.x;
}

class MG{
  PoissonMatrix A;
  Field r,x;
  int iter=0;

  MG( PoissonMatrix A, Field x, Field b ){
    this.A = A;
    this.x = x;
    r = A.residual(b,x);
  }

  void update( float itmx ){
    x.plusEq(smooth( 1, A, r ));
    if(divisible(x)){
      for( int i=0 ; i<itmx ; i++ ){
        x.plusEq(vCycle( A, r ));
        iter++;
        if(r.inner(r)<1e-5) break;
      }
    }
  }
  void update(){ update( 1 );}
 
  Field vCycle( PoissonMatrix A, Field r){
    PoissonMatrix B = restrict(A);
    Field psi = restrict(r), phi = smooth( 1, B, psi );
    if(divisible(phi)) phi.plusEq(vCycle( B, psi ));
    Field del = prolongate(phi);
    r.plusEq(A.times(del).times(-1));
    return del.plus(smooth(4,A,r));
  }

  boolean divisible( Field x ){
    return( (x.n-2)%2==0 && (x.m-2)%2==0 );
  }

  PoissonMatrix restrict( PoissonMatrix A ){
    int n = (A.lower.n-2)/2+2;
    int m = (A.lower.m-2)/2+2;
    VectorField lower = new VectorField(n,m,0,0);
    for( int i=1; i<n-1; i++ ){
    for( int j=1; j<m-1; j++ ){
      int ii = (i-1)*2+1;
      int jj = (j-1)*2+1;
      lower.x.a[i][j] = (A.lower.x.a[ii][jj]+A.lower.x.a[ii][jj+1])*0.5;
      lower.y.a[i][j] = (A.lower.y.a[ii][jj]+A.lower.y.a[ii+1][jj])*0.5;
    }}
    lower.setBC();
    return new PoissonMatrix(lower);
  }

  Field restrict( Field a ){
    int n = (a.n-2)/2+2;
    int m = (a.m-2)/2+2;
    Field b = new Field(n,m);
    for( int i=1; i<n-1; i++ ){
    for( int j=1; j<m-1; j++ ){
      int ii = (i-1)*2+1;
      int jj = (j-1)*2+1;
      b.a[i][j] = a.a[ii][jj]+a.a[ii][jj+1]+a.a[ii+1][jj]+a.a[ii+1][jj+1];
    }}
    b.setBC();
    return b;
  }

  Field prolongate( Field a ){
    int n = (a.n-2)*2+2;
    int m = (a.m-2)*2+2;
    Field b = new Field(n,m);
    for( int i=0; i<n; i++ ){
    for( int j=0; j<m; j++ ){
      int ii = (i-1)/2+1;
      int jj = (j-1)/2+1;
      b.a[i][j] = a.a[ii][jj];
    }}
    return b;
  }

  Field smooth( int itmx, PoissonMatrix A, Field r){
    Field del = new Field(r.n,r.m);
    for( int it=0 ; it<itmx ; it++ ){
    for( int i=1 ; i<r.n-1 ; i++ )  {
    for( int j=1 ; j<r.m-1 ; j++ )  {
      del.a[i][j] = -(del.a[i-1][j]*A.lower.x.a[i][j]
                     +del.a[i+1][j]*A.lower.x.a[i+1][j]
                     +del.a[i][j-1]*A.lower.y.a[i][j]
                     +del.a[i][j+1]*A.lower.y.a[i][j+1]
                     -r.a[i][j])*A.inv.a[i][j];
    }}}
    del.setBC();
    r.plusEq(A.times(del).times(-1));
    return del;
  }
}

