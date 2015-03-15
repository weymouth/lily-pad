/**********************************
SharpField class

Holds the values and operators for a
field which represents a sharp interface

example code:

VectorField u;
SharpField p;
void setup(){
  size(800,800);
  int n=100,m=100;
  p = new SharpField(n,m);
  p.eq(1.0,10,40,60,90);
  u = new VectorField(n,m,0,0);
  for( int i=0; i<m; i++){
    for( int j=0; j<n; j++){
      u.x.a[i][j] = float(i-1)/50.0;
      u.y.a[i][j] = -float(j-1)/50.0;
    }
  }
}
void draw(){
  p.advect( 0.25, u);
  p.display(0,0.001);
  println(p.sum());
}
***********************************/

class SharpField extends Field{
  int strang = 0;
  SharpField( int n, int m, int btype, float bval ){
    super(n, m, btype, min(max(bval,0),1) );
  }
  SharpField( int n, int m){super(n, m);}
  SharpField( SharpField p){super(p);}

  void advect( float step, Field u, Field v ){
    // determine max advection velocity
    float mx = 0;
    for( int j=1; j<m-1; j++){
    for( int i=1; i<n-1; i++){
      mx = max(abs(u.a[i][j])+abs(v.a[i][j]),mx);
    }}
    // determine CFL substep
    int it = ceil(2*mx*step);
    float substep = step/float(it);
    // iterate split-advection method
    for (int itr = 0; itr<it; itr++){
      SharpField c = new SharpField(this);
      if(strang==0){ left( substep, u, c ); bottom( substep, v, c ); strang=1;}
      else         { bottom( substep, v, c ); left( substep, u, c ); strang=0;}
    }
  }
  void advect( float step, Field u, Field v, Field u0, Field v0 ){
    Field us = new Field(u), vs = new Field(v);
    us.plusEq(u0); us.timesEq(0.5);
    vs.plusEq(v0); vs.timesEq(0.5);
    advect( step, us, vs );
  }
  
  void left(float substep, Field u, SharpField c ){
    // flux on left face
    float[][] fx = new float[n][m];
    for( int j=1; j<m-1; j++){
      for( int i=1; i<n; i++){
        float ul = substep*u.a[i][j];
        int    s = (ul>0)?i-1:i;
        float fl = a[s][j];
        s = min(max(1,s),n-2);
        float n1 = a[s+1][j]-a[s-1][j];
        float n2 = a[s][j+1]-a[s][j-1];
        fx[i][j] = flux(ul,fl,n1,n2);
      }
    }
    // x update
    for( int j=1; j<m-1; j++){
      for( int i=1; i<n-1; i++){
        float g = (c.a[i][j]>0.5)?1:0;
        a[i][j] -= fx[i+1][j]-fx[i][j]-g*substep*(u.a[i+1][j]-u.a[i][j]);
      }
    }
    setBC();
  }
  void bottom( float substep, Field v, SharpField c ){
    // flux on bottom face
    float[][] fx = new float[n][m];
    for( int i=1; i<n-1; i++){
      for( int j=1; j<m; j++){
        float vb = substep*v.a[i][j];
        int    s = (vb>0)?j-1:j;
        float fb = a[i][s];
        s = min(max(1,s),m-2);
        float n1 = a[i+1][s]-a[i-1][s];
        float n2 = a[i][s+1]-a[i][s-1];
        fx[i][j] = flux(vb,fb,n2,n1);
      }
    }
    // y update
    for( int j=1; j<m-1; j++){
      for( int i=1; i<n-1; i++){
        float g = (c.a[i][j]>0.5)?1:0;
        a[i][j] -= fx[i][j+1]-fx[i][j]-g*substep*(v.a[i][j+1]-v.a[i][j]);
      }
    }
    setBC();
  }

  float flux( float u, float f, float n1, float n2 ){
    int sgn = (u>0)?1:-1;
    float fx;
    if(abs(n2)>abs(n1)) {
      fx = abs(u*f);
    } else if(u*n1<0){
      fx = abs(u)-(1-f);
    } else {
      fx = abs(u);
    }
    return sgn*min(f,max(0,fx));
  }
  
  void setBC(){
    super.setBC();
    for( int i=0; i<n; i++){
      for( int j=0; j<m; j++){
        a[i][j] = min(max(a[i][j],0),1);
      }
    }
  }
  
  SharpField smooth(){
    SharpField b = new SharpField(n,m);
    for( int j=1; j<m-1; j++ ){
    for( int i=1; i<n-1; i++ ){
        b.a[i][j] = 0.125*(4.*a[i][j]
        +a[i-1][j]+a[i+1][j]+a[i][j-1]+a[i][j+1]);
    }}
    b.setBC();
    return b;
  }

  void display(){ super.display( 0, 1 ); }

}
