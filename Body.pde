/********************************
Body class

this is the parent of all the body classes

it defines the position and motion of a body
centriod and the basic operations on a body.

example code:
Body body;
void setup(){
  size(400,400);
  body = new Body(10,50,new Window(100,100));
}
void draw(){
  background(0);
  body.update();
  body.display();
}
void mousePressed(){body.mousePressed();}
void mouseReleased(){body.mouseReleased();}
********************************/

class Body{
  Window window;
  final color bodyColor = #993333;
  float phi=0,dphi=0;
  int hx,hy;
  boolean unsteady,pressed;
  PVector xc,dxc;

  Body( float x, float y, Window window ){
    this.window = window;
    xc = new PVector(x,y);
    dxc = new PVector(0,0);
  }
  
  void display(){display(bodyColor,window);}
  void display(Window window){display(bodyColor,window);}
  void display( color C){ display(C,window);}
  void display( color C, Window window ){
    stroke(C);noFill();
    ellipse(window.px(xc.x),window.py(xc.y),4,4);
  }
  
  float distance( float x, float y){ // in cells
    return mag(x-xc.x,y-xc.y);
  }
  int distance( int px, int py){     // in pixels
    float x = window.ix(px);
    float y = window.iy(py);
    return window.pdx(distance( x, y ));
  }
  
  void translate( float dx, float dy ){
    unsteady = true; // in case of external call
    dxc = new PVector(dx,dy);
    xc.add(dxc); 
  }
  void rotate( float dphi ){
    unsteady = true; // in case of external call
    this.dphi = dphi;
    phi = phi+dphi;
  }
  
  float velocity( int d, float dt, float x, float y ){
    // add the rotational velocity to the translational
    PVector r = new PVector(x,y);
    r.sub(xc);
    if(d==1) return (dxc.x-r.y*dphi)/dt;
    else     return (dxc.y+r.x*dphi)/dt;
  }

  void update(){
    unsteady = false; // reset
    if(pressed){
      this.translate( window.idx(mouseX-hx), window.idy(mouseY-hy) );
      hx = mouseX;
      hy = mouseY;
    }else{
      this.translate( 0, 0 );
    }
  }
  void mousePressed(){
    if(distance( mouseX, mouseY )<1){
      pressed = true;
      hx = mouseX;
      hy = mouseY;
    }
  }
  void mouseReleased(){
    pressed = false;
  }
}
/********************************
EllipseBody class

simple elliptical body extension
********************************/
class EllipseBody extends Body{
  float h,a; // height and aspect ratio of ellipse

  EllipseBody( float x, float y, float d, Window window ){ this(x,y,d,1.0,window);}
  EllipseBody( float x, float y, float _h, float _a, Window window){
    super(x,y,window);
    h = _h; a = _a;
  }
  
  void display( color C, Window window ){
    fill(C);noStroke();
    ellipse(window.px(xc.x),window.py(xc.y),window.pdx(h*a),window.pdy(h));
  }
  
  void rotate( float _dphi ){ return;} // no rotation!

  float distance( float x, float y){
    return (mag((x-xc.x)/a,y-xc.y)-h*0.5);
  }
}

