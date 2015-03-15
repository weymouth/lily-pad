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
 
Example code:
 
Body body;
void setup(){
  size(400,400);
  body = new Body(0,0,new Window(0,0,4,4));
  body.add(0.5,2.5);
  body.add(2.75,0.25);
  body.add(0,0);
  body.end();
  body.display();
  println("The distance "+body.distance(3.,1.)+" should equal "+sqrt(.5));
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
  color bodyColor = #993333;
  final color bodyOutline = #000000;
  final color vectorColor = #000000;
  PFont font = loadFont("Dialog.bold-14.vlw");
  float phi=0, dphi=0, mass=1, I0=1, area=0;
  int hx, hy;
  ArrayList<PVector> coords;
  int n;
  boolean unsteady, pressed, xfree=true, yfree=true, updated=true;
  PVector xc, dxc;
  OrthoNormal orth[];
  Body box;

  Body( float x, float y, Window window ) {
    this.window = window;
    xc = new PVector(x, y);
    dxc = new PVector(0, 0);
    coords = new ArrayList();
  }

  void add( float x, float y ) {
    coords.add( new PVector( x, y ) );
    // remove concave points
    for ( int i = 0; i<coords.size() && coords.size()>3; i++ ) {
      PVector x1 = coords.get(i);
      PVector x2 = coords.get((i+1)%coords.size());
      PVector x3 = coords.get((i+2)%coords.size());
      PVector t1 = PVector.sub(x1, x2);
      PVector t2 = PVector.sub(x2, x3);
      float a = atan2(t1.y, t1.x)-atan2(t2.y, t2.x);
      if (sin(a)<0) {
        coords.remove((i+1)%coords.size());
        i=0;
      }
    }
  }

  void end(Boolean closed) {
    n = coords.size();
    orth = new OrthoNormal[closed?n:n-1];
    getOrth(); // get orthogonal projection of line segments
    if(closed) getArea();

    // make the bounding box
    if (n>4) {
      PVector mn = xc.get();
      PVector mx = xc.get();
      for ( PVector x: coords ) {
        mn.x = min(mn.x, x.x);
        mn.y = min(mn.y, x.y);
        mx.x = max(mx.x, x.x);
        mx.y = max(mx.y, x.y);
      }
      box = new Body(xc.x, xc.y, window);
      box.add(mn.x, mn.y);
      box.add(mn.x, mx.y);
      box.add(mx.x, mx.y);
      box.add(mx.x, mn.y);
      box.end();
    }
  }
  void end() {
    end(true);
  }

  void getOrth() {    // get orthogonal projection to speed-up distance()
    for ( int i = 0; i<orth.length ; i++ ) {
      PVector x1 = coords.get(i);
      PVector x2 = coords.get((i+1)%n);
      orth[i] = new OrthoNormal(x1, x2);
    }
  }
  void getArea() {    // get the polygon area and moment
    float s=0, t=0;
    for ( int i = 0; i<n ; i++ ) {
      PVector p1 = coords.get(i);
      PVector p2 = coords.get((i+1)%n);
      float x1 = p1.x-xc.x, x2 = p2.x-xc.x, y1 = p1.y-xc.y, y2 = p2.y-xc.y, da = x1*y2-x2*y1;
      s -= da;
      t -= (sq(x1)+x1*x2+sq(x2)+sq(y1)+y1*y2+sq(y2))*da;
    }
    area = 0.5*s;
    I0 = t/12.;
    mass = area; // default unit density
  }
 
  void setColor(color c) {
    bodyColor = c;
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
  void display( color C, Window window ) { // note: can display while adding
    //    if(n>4) box.display(#FFCC00);
    fill(C); 
    //noStroke();
    stroke(bodyOutline);
    strokeWeight(1);
    beginShape();
    for ( PVector x: coords ) vertex(window.px(x.x), window.py(x.y));
    endShape(CLOSE);
  }
  void displayVector(PVector V) {
    displayVector(vectorColor, window, V, "Force", true);
  }
  void displayVector(color C, Window window, PVector V, String title, boolean legendOn) { // note: can display while adding
    //    if(n>4) box.display(#FFCC00);
    float Vabs = sqrt(V.x*V.x+V.y*V.y);
    float Vscale=10;
    float circradius=6; //pix
    
    stroke(C);
    strokeWeight(2);
    line(window.px(xc.x), window.py(xc.y), window.px(xc.x-Vscale*V.x), window.py(xc.y-Vscale*V.y));
    
    fill(C); 
    noStroke();
    ellipse(window.px(xc.x-Vscale*V.x), window.py(xc.y-Vscale*V.y), circradius, circradius);
    
    if (legendOn){
        textFont(font);
        fill(C);
        float spacing=20;
        int x0 = window.x0, x1 = window.x0+window.dx;
        int y0 = window.y0, y1 = window.y0+window.dy;
        textAlign(LEFT,BASELINE);
        String ax = ""+V.x;
        String ay = ""+V.y;
        text(title + " X: " + ax.substring(0,min(ax.length(),5)),x0+spacing,y1-2*spacing);
        text(title + " Y: " + ay.substring(0,min(ay.length(),5)),x0+spacing,y1-spacing);
    }
  }

  float distance( float x, float y ) { // in cells
    float dis = -1e10;
    if (n>4) { // check distance to bounding box
      dis = box.distance(x, y);
      if (dis>3) return dis;
    }
    // check distance to each line, choose max
    for ( OrthoNormal o : orth ) dis = max(dis, o.distance(x, y));
    return dis;
  }
  int distance( int px, int py) {     // in pixels
    float x = window.ix(px);
    float y = window.iy(py);
    return window.pdx(distance( x, y ));
  }

  PVector WallNormal(float x, float y  ) {
    PVector wnormal = new PVector(0, 0);
    float dis = -1e10;
    float dis2 = -1e10;
    if (n>4) { // check distance to bounding box
      if ( box.distance(x, y)>3) return wnormal;
    }
    // check distance to each line, choose max
    for ( OrthoNormal o : orth ) {
      dis2=o.distance(x, y);
      if (dis2>dis) {
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

  void translate( float dx, float dy ) {
    dxc = new PVector(dx, dy);
    xc.add(dxc);
    for ( PVector x: coords ) x.add(dxc);
    for ( OrthoNormal o: orth   ) o.translate(dx, dy);
    if (n>4) box.translate(dx, dy);
    updated = false;
  }

  void rotate( float dphi ) {
    this.dphi = dphi;
    phi = phi+dphi;
    float sa = sin(dphi), ca = cos(dphi);
    for ( PVector x: coords ) rotate( x, sa, ca ); 
    getOrth(); // get new orthogonal projection
    if (n>4) box.rotate(dphi);
    updated = false;
  }
  void rotate( PVector x, float sa, float ca ) {
    PVector z = PVector.sub(x, xc);
    x.x = ca*z.x-sa*z.y+xc.x;
    x.y = sa*z.x+ca*z.y+xc.y;
  }

  void updatePositionOnly() {updated=true; update(); }
  void update() {
    if (pressed) {
      this.translate( window.idx(mouseX-hx), window.idy(mouseY-hy) );
      hx = mouseX;
      hy = mouseY;
    }
    unsteady = (dxc.mag()!=0)|(dphi!=0);
    if(updated){ dxc = new PVector(0,0); dphi = 0; }
    updated = true;
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

  PVector pressForce ( Field p ) {
    PVector pv = new PVector(0, 0);
    for ( OrthoNormal o: orth ) {
      float pdl = p.linear( o.cen.x, o.cen.y )*o.l;
      pv.add(pdl*o.nx, pdl*o.ny, 0);
    }
    return pv;
  }
  
  float pressMoment ( Field p ) {
    float mom = 0;
    for ( OrthoNormal o: orth ) {
      float pdl = p.linear( o.cen.x, o.cen.y )*o.l;
      mom += pdl*(o.ny*(o.cen.x-xc.x)-o.nx*(o.cen.y-xc.y));
    }
    return mom;
  }

  // compute body reaction to applied force using 1st order Euler 
  void react (PVector force, float moment, float dt1, float dt2) {
    float dx,dy,dp;
    dx = -dt2*(dt1+dt2)/2*force.x/mass + dt2/dt1*dxc.x;
    dy = -dt2*(dt1+dt2)/2*force.y/mass + dt2/dt1*dxc.y; 
    dp = -dt2*(dt1+dt2)/2*moment/I0 + dt2/dt1*dphi;
    translate(xfree?dx:0, yfree?dy:0); 
    rotate(dp);
  }
  void react (PVector force, float dt1, float dt2) {react(force, 0, dt1, dt2);}

}
/********************************
 EllipseBody class
 
 simple elliptical body extension
 ********************************/
class EllipseBody extends Body {
  float h, a; // height and aspect ratio of ellipse
  int m = 40;

  EllipseBody( float x, float y, float _h, float _a, Window window) {
    super(x, y, window);
    h = _h; 
    a = _a;
    float dx = 0.5*h*a, dy = 0.5*h;
    for ( int i=0; i<m; i++ ) {
      float theta = -TWO_PI*i/((float)m);
      add(xc.x+dx*cos(theta), xc.y+dy*sin(theta));
    }
    end(); // finalize shape
  }
}
/* CircleBody
 simplified rotation and distance function */
class CircleBody extends EllipseBody {

  CircleBody( float x, float y, float d, Window window ) {
    super(x, y, d, 1.0, window);
  }

  float distance( float x, float y) {
    return mag(x-xc.x, y-xc.y)-0.5*h;
  }

  void rotate(float _dphi) {
    dphi = _dphi;
    phi = phi+dphi;
    updated = false;
  }
  
}

