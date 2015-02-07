/**********************************
FreeInterface class

Extends SharpField by adding the density
  ratio (gamma) to compute the density 
  (rho)

Example code:

void setup(){
  size(400,400);

  FreeInterface f;
  int m=100,n=100;

  f = new FreeInterface(n,m,0.1);
  for( int i=0; i<n; i++){
    for( int j=0; j<m/3; j++){
      f.a[i][j] = 0.0;
    }
  }
  for( int i=n/2; i<n; i++){
    for( int j=m/3; j<2*m/3; j++){
      f.a[i][j] = 0.0;
    }
  }
  f.display(0,1);
  f.rho().display(1,2);
} 
***************************************/

class FreeInterface extends SharpField{
  float gamma;

  FreeInterface( int n, int m, float gamma){
    super( n, m, 0, 1 );
    this.gamma = gamma;
  }
  
  VectorField rho(){
    VectorField b = new VectorField(n,m,1,1);
    for( int j=0; j<m; j++ ){
      for( int i=1; i<n; i++ ){
        b.x.a[i][j] = 0.5*(a[i][j]+a[i-1][j])*(1.-gamma)+gamma;
      }
      b.x.a[0][j] = b.x.a[1][j];
    }
    for( int i=0; i<n; i++ ){
      for( int j=1; j<m; j++ ){
        b.y.a[i][j] = 0.5*(a[i][j]+a[i][j-1])*(1.-gamma)+gamma;
      }
      b.y.a[i][0] = b.y.a[i][1];
    }
    return b;
  }
}
