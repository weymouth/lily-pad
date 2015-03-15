/********************************************
  Class to hold display window parameters
    and functions to convert from
    pixels to other units

Example code:
void setup(){
  size(300,450);
  Window mine = new Window(1,1,10,15,40,80,200,300);
  rect(40,80,200,300);
  stroke(255,0,0);fill(0,255,255);
  rect(mine.px(0.5),mine.py(0.5),mine.x.r,mine.y.r);
  rect(mine.px(9.5),mine.py(14.5),mine.x.r,mine.y.r);
  line(mine.px(1),mine.py(1),mine.px(10),mine.py(15));
  rect(mine.px(mine.ix(0)),mine.py(mine.iy(449)),50,-50);
  rect(mine.px(mine.ix(299)),mine.py(mine.iy(0)),-50,50);
}
*********************************************/

class Window{
  Scale x,y;
  int x0,y0,dx,dy;
  
  Window(){ this( 0., 0., 1., 1., 0, 0, width, height );}
  Window( int n, int m){ this( 1, 1, n-2, m-2, 0, 0, width, height );}
  Window( int n0, int m0, int dn, int dm){this( n0, m0, dn, dm, 0, 0, width, height );}
  Window( int n0, int m0, int dn, int dm, int x0, int y0, int dx, int dy){
    this(n0-0.5,m0-0.5,dn,dm,x0,y0,dx,dy);}
  Window( int n0, float m0, int dn, float dm, int x0, int y0, int dx, int dy){
    this(n0-0.5,m0,dn,dm,x0,y0,dx,dy);}
  Window( float n0, float m0, float dn, float dm, int x0, int y0, int dx, int dy){
    x = new Scale(n0,n0+dn,x0,x0+dx);
    y = new Scale(m0,m0+dm,y0,y0+dy);
    this.x0 = x0;
    this.y0 = y0;
    this.dx = dx;
    this.dy = dy;
  }
  float ix(int i){ return x.in((float)i);}
  float iy(int i){ return y.in((float)i);}
  float idx(int i){ return i/x.r;}
  float idy(int i){ return i/y.r;}
  int px(float i){ return (int)(x.out(i));}
  int py(float i){ return (int)(y.out(i));}
  int pdx(float i){ return (int)(x.r*i);}
  int pdy(float i){ return (int)(y.r*i);}
  boolean inside( int x, int y ){
    return( x>=x0 && x<=x0+dx && y>=y0 && y<=y0+dy );
  }
}

class Scale{
  float inS,inE,outS,outE,r;

  Scale( float outS, float outE ){ this(0,1,outS,outE);}
  Scale( float inS, float inE, float outS, float outE ){
    this.inS  = inS;
    this.inE  = inE;
    this.outS = outS;
    this.outE = outE;
    r = (outE-outS)/(inE-inS);
  }
  float outB( float in ){ return out(min(max(in,inS),inE));}
  float out( float in ){ return (in-inS)*r+outS;} 
  float in( float out ){ return (out-outS)/r+inS;}
}
