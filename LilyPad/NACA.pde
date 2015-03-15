/********************************
NACA airfoil class

example code:

NACA foil;
void setup(){
  size(400,400);
  foil = new NACA(1,1,0.5,0.20,new Window(3,3));
}
void draw(){
  background(0);
  foil.display();
  foil.rotate(0.01);
}
********************************/
class NACA extends Body{
  int m = 100;
  float c, FoilArea;
  float pivot;
  
  NACA( float x, float y, float c, float t, float pivot, Window window ){
    super(x,y,window);
    add(xc.x-c*pivot,xc.y);
    for( int i=1; i<m; i++ ){
      float xx = pow(i/(float)m,2);
      add(xc.x+c*(xx-pivot),xc.y+t*c*offset(xx));      
    }
    add(xc.x+c*(1-pivot),xc.y);
    for( int i=m-1; i>0; i-- ){
      float xx = pow(i/(float)m,2);
      add(xc.x+c*(xx-pivot),xc.y-t*c*offset(xx));
    }
    end(); // finalizes shape
    this.c = c;
     FoilArea = t*c*0.685084;    //crossectional area of NACA foil
  }
  
  NACA( float x, float y, float c, float t, Window window ){
    this(x,y,c,t,.25,window);
  }
  
  float[][] interp( Field a ){
    float[][] b = new float[2][m+1];

    PVector x = coords.get(0);
    b[0][0] = a.interp(x.x,x.y); b[1][0] = b[0][0];
    for ( int i = 1; i<m; i++ ){
      x = coords.get(i);
      b[0][i] = a.interp(x.x,x.y);
      x = coords.get(n-i);
      b[1][i] = a.interp(x.x,x.y);
    }
    x = coords.get(m);
    b[0][m] = a.interp(x.x,x.y); b[1][m] = b[0][m];
    return b;
  }

  float offset( float x ){
    return 5*(0.2969*sqrt(x)-0.1260*x-0.3516*pow(x,2)+0.2843*pow(x,3)-0.1015*pow(x,4));
  }

//  PVector pressForce ( Field p ){
//    PVector pv = super.pressForce(p);
//    return PVector.div(pv,c);
//  }
}
