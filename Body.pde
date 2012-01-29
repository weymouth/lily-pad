/********************************
 Body class
 
 this is the parent of all the body classes

 it defines the position and motion of a convex body. 
 
 points added to the body shape must be added clockwise 
 so that the convexity can be tested.
 
 basic operations such as translations and rotations are
 applied to the centroid and the array of points. 
 
 the update function checks for mouse user interaction and
 updates the `unsteady' flag.
  
 example code:
 Body body;
 void setup(){
  size(400,400);
  body = new Body(0,0,new Window(0,0,4,4));
  body.add(0.5,2.5);
  body.add(2.75,0.25);
  body.add(0,0);
  body.end();
  body.display();
  println(body.distance(3.,1.)); // should be sqrt(1/2)
}
 
 void draw(){
 background(0);
 body.update();
 body.display();
 }
 void mousePressed(){body.mousePressed();}
 void mouseReleased(){body.mouseReleased();}
 ********************************/

class Body {
  Window window;
  final color bodyColor = #993333;
  float phi=0, dphi=0;
  int hx, hy;
  ArrayList<PVector> coords;
  int n;
  boolean unsteady, pressed;
  PVector xc, dxc;
  OrthoNormal orth[];
  Body box;

  Body( float x, float y, Window window ) {
    this.window = window;
    xc = new PVector(x, y);
    dxc = new PVector(0, 0);
    coords = new ArrayList();
  }
  
  void add( float x, float y ){
    coords.add( new PVector( x, y ) );
// remove concave points
    for ( int i = 0; i<coords.size() && coords.size()>3; i++ ){
      PVector x1 = coords.get(i);
      PVector x2 = coords.get((i+1)%coords.size());
      PVector x3 = coords.get((i+2)%coords.size());
      PVector t1 = PVector.sub(x1,x2);
      PVector t2 = PVector.sub(x2,x3);
      float a = atan2(t1.y,t1.x)-atan2(t2.y,t2.x);
      if(sin(a)<0){
       coords.remove((i+1)%coords.size());
       i=0;
      }
    }
  }
  
  void end(Boolean closed){
    n = coords.size();
    orth = new OrthoNormal[closed?n:n-1];
    getOrth(); // get orthogonal projection of line segments

    // make the bounding box
    if(n>4){
      PVector mn = xc.get();
      PVector mx = xc.get();
      for ( PVector x: coords ) {
        mn.x = min(mn.x,x.x);
        mn.y = min(mn.y,x.y);
        mx.x = max(mx.x,x.x);
        mx.y = max(mx.y,x.y);
      }
      box = new Body(xc.x,xc.y,window);
      box.add(mn.x,mn.y);
      box.add(mn.x,mx.y);
      box.add(mx.x,mx.y);
      box.add(mx.x,mn.y);
      box.end();
    }
  }
  void end(){end(true);}

  void getOrth(){    // get orthogonal projection to speed-up distance()
    for( int i = 0; i<orth.length ; i++ ) {
      PVector x1 = coords.get(i);
      PVector x2 = coords.get((i+1)%n);
      orth[i] = new OrthoNormal(x1,x2);
    }
  }

  void display() {
    display(bodyColor, window);
  }
  void display(Window window) {
    display(bodyColor, window);
  }
  void display( color C) { 
    display(C, window);
  }
  void display( color C, Window window ){ // note: can display while adding
//    if(n>4) box.display(#FFCC00);
    fill(C); noStroke();
    beginShape();
    for ( PVector x: coords ) vertex(window.px(x.x),window.py(x.y));
    endShape(CLOSE);
  }

  float distance( float x, float y ){ // in cells
    float dis = -1e10;
    if(n>4) { // check distance to bounding box
      dis = box.distance(x,y);
      if(dis>3) return dis;
    }
    // check distance to each line, choose max
    for ( OrthoNormal o : orth ) dis = max(dis,o.distance(x,y));
    return dis;
  }
  int distance( int px, int py) {     // in pixels
    float x = window.ix(px);
    float y = window.iy(py);
    return window.pdx(distance( x, y ));
  }
    
  PVector WallNormal(float x, float y  ){
    PVector wnormal = new PVector(0,0);
    float dis = -1e10;
    float dis2 = -1e10;
    if(n>4) { // check distance to bounding box
      if( box.distance(x,y)>3) return wnormal;
    }
    // check distance to each line, choose max
    for ( OrthoNormal o : orth ){
      dis2=o.distance(x,y);
     if (dis2>dis){
       dis=dis2;
       wnormal.x=o.nx;
       wnormal.y=o.ny;
     }
    }
    return wnormal;
  }


  float velocity( int d, float dt, float x, float y ) {
    // add the rotational velocity to the translational
    PVector r = new PVector(x, y);
    r.sub(xc);
    if (d==1) return (dxc.x-r.y*dphi)/dt;
    else     return (dxc.y+r.x*dphi)/dt;
  }
  
  void translate( float dx, float dy ){
    dxc = new PVector(dx, dy);
    xc.add(dxc);
    for ( PVector x: coords ) x.add(dxc);
    for ( OrthoNormal o: orth   ) o.translate(dx,dy);
    if(n>4) box.translate(dx,dy);
  }
  
  void rotate( float dphi ){
    this.dphi = dphi;
    phi = phi+dphi;
    float sa = sin(dphi), ca = cos(dphi);
    for ( PVector x: coords ) rotate( x, sa, ca ); 
    getOrth(); // get new orthogonal projection
    if(n>4) box.rotate(dphi);
  }
  void rotate( PVector x , float sa, float ca ){
    PVector z = PVector.sub(x,xc);
    x.x = ca*z.x-sa*z.y+xc.x;
    x.y = sa*z.x+ca*z.y+xc.y;
  }

  void update() {
    if (pressed) {
      this.translate( window.idx(mouseX-hx), window.idy(mouseY-hy) );
      hx = mouseX;
      hy = mouseY;
    }
    unsteady = (dxc.mag()!=0)|(dphi!=0);
  }

  void mousePressed() {
    if (distance( mouseX, mouseY )<1) {
      pressed = true;
      hx = mouseX;
      hy = mouseY;
    }
  }
  void mouseReleased() {
    pressed = false;
    dxc.set(0, 0, 0);
    dphi = 0;
  }
}
/********************************
 EllipseBody class
 
 simple elliptical body extension
 ********************************/
class EllipseBody extends Body {
  float h, a; // height and aspect ratio of ellipse
  int m = 40;

  EllipseBody( float x, float y, float d, Window window ) { 
    this(x, y, d, 1.0, window);
  }
  EllipseBody( float x, float y, float _h, float _a, Window window) {
    super(x, y, window);
    h = _h; 
    a = _a;
    float dx = 0.5*h*a, dy = 0.5*h;
    for( int i=0; i<m; i++ ){
      float theta = -TWO_PI*i/((float)m);
      add(xc.x+dx*cos(theta),xc.y+dy*sin(theta));      
    }
    end(); // finalize shape
  }

  void display( color C, Window window ) {
    fill(C); noStroke();
    ellipse(window.px(xc.x), window.py(xc.y), window.pdx(h*a), window.pdy(h));
  }

  float distance( float x, float y) {
    return (mag((x-xc.x)/a, y-xc.y)-h*0.5);
  }

  PVector WallNormal(float x, float y) {
    PVector wnormal = new PVector((x-xc.x)*sq(h*a), (y-xc.y)*sq(h));
    wnormal.normalize(); 
    return wnormal;
  }
  
  void rotate(float dphi){return;}// no rotation
}

