/********************************
 Body class
 
 this is the parent of all the body classes
 
 it defines the position and motion of a convex body. 
 
 points added to the body shape must be added counter
 clockwise so that the convexity can be tested.
 
 the easiest way to include dynamics is to use follow()
 which follows the path variable (or mouse) or to use
 react() which integrates the rigid body equations.
 You can also translate() and rotate() directly.
 
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
  body.follow();
  body.display();
}
void mousePressed(){body.mousePressed();}
void mouseReleased(){body.mouseReleased();}
void mouseWheel(MouseEvent event){body.mouseWheel(event);}

********************************/

class Body {
  Window window;
  color bodyColor = #993333;
  final color bodyOutline = #000000;
  final color vectorColor = #000000;
  PFont font = loadFont("Dialog.bold-14.vlw");
  float phi=0, dphi=0, dotphi=0, ddotphi=0;
  float mass=1, I0=1, area=0;
  ArrayList<PVector> coords=new ArrayList<PVector>();
  int n;
  boolean convex=false;
  boolean pressed=false, xfree=true, yfree=true, pfree=true;
  PVector xc, dxc=new PVector(), dotxc=new PVector(), ddotxc=new PVector();
  PVector handle=new PVector(), ma=new PVector();
  OrthoNormal orth[];
  Body box;

  Body( float x, float y, Window window ) {
    this.window = window;
    xc = new PVector(x, y);
  }

  void add( float x, float y ) {
    coords.add( new PVector( x, y ) );
  }

  void end(Boolean closed) {
    n = coords.size();
    orth = new OrthoNormal[closed?n:n-1];
    getOrth(); // get orthogonal projection of line segments
    if(closed) getArea();

    // make the bounding box
    if (n>4) {
      PVector mn = xc.copy(), mx = xc.copy();
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
    
    // check for convexity
    convex = true;
    double_loop: for ( OrthoNormal oi : orth ) {
      for ( OrthoNormal oj : orth ){
        if(oi.distance(oj.cen.x,oj.cen.y)>0.001) {
          convex = false; 
          break double_loop;
    }}}
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
        int x0 = window.x0, y1 = window.y0+window.dy;
        textAlign(LEFT,BASELINE);
        String ax = ""+V.x;
        String ay = ""+V.y;
        text(title + " X: " + ax.substring(0,min(ax.length(),5)),x0+spacing,y1-2*spacing);
        text(title + " Y: " + ay.substring(0,min(ay.length(),5)),x0+spacing,y1-spacing);
    }
  }

  float distance( float x, float y ) { // in cells
    float dis;
    if (n>4) { // distance to bounding box
      dis = box.distance(x, y);
      if (dis>3) return dis;
    }
    
    if(convex){ // distance to convex body
      // check distance to each line, choose max
      dis = -1e10;
      for ( OrthoNormal o : orth ) dis = max(dis, o.distance(x, y));
      return dis;
    } else {   // distance to non-convex body
      // check distance to each line segment, choose min
      dis = 1e10;
      for( OrthoNormal o: orth ) dis = min(dis,o.distance(x,y,false));
      return (wn(x,y)==0)?dis:-dis; // use winding to set inside/outside
    }
  }
  int distance( int px, int py) {     // in pixels
    float x = window.ix(px);
    float y = window.iy(py);
    return window.pdx(distance( x, y ));
  }

  int wn( float x, float y){
    // Winding number. If wn==0 the point is inside the body
    int wn=0;
    for ( int i = 0; i<coords.size()-1; i++ ){      
      float yi = coords.get(i).y;    // y value of point i
      float yi1 = coords.get(i+1).y; // y value of point i+1
      OrthoNormal o = orth[i];       // segment from i to i+1
      if(yi <= y){                   // check for positive crossing
        if(yi1 > y && o.distance(x,y)>0) wn++;
      }else{                         // check for negative crossing
        if(yi1 <= y && o.distance(x,y)<0) wn--;
      }
    }
    return wn;
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

  boolean unsteady(){return (dxc.mag()!=0)|(dphi!=0);}

  void translate( float dx, float dy ) {
    dxc = new PVector(dx, dy);
    xc.add(dxc);
    for ( PVector x: coords ) x.add(dxc);
    for ( OrthoNormal o: orth   ) o.translate(dx, dy);
    if (n>4) box.translate(dx, dy);
  }

  void rotate( float dphi ) {
    this.dphi = dphi;
    phi = phi+dphi;
    float sa = sin(dphi), ca = cos(dphi);
    for ( PVector x: coords ) rotate( x, xc, sa, ca ); 
    getOrth(); // get new orthogonal projection
    if (n>4) box.rotate(dphi);
  }
  void rotate( PVector x, PVector xc, float sa, float ca ) {
    PVector z = PVector.sub(x, xc);
    x.x = ca*z.x-sa*z.y+xc.x;
    x.y = sa*z.x+ca*z.y+xc.y;
  }
  void rotate( PVector x, float sa, float ca ) {rotate(x,new PVector(),sa,ca);}
  
  // Move body to path=(x,y,phi)
  void follow(PVector path) {
    PVector d = path.copy().sub(xc.copy().add(handle)); // distance to point;
    d.z = (d.z-phi);                                    // arc length to angle
    translate(d.x,d.y); rotate(d.z);                    // translate & rotate
  }
  void follow() {
    if(pressed) follow(new PVector(window.ix(mouseX),window.iy(mouseY)));
  }
  void follow(PVector path, PVector dpath){
    follow(path);
    dxc = new PVector(dpath.x, dpath.y);
    dphi = dpath.z;
  }
  
  void mousePressed() {
    if (distance( mouseX, mouseY )<1) {
      pressed = true;
      handle = new PVector(window.ix(mouseX),window.iy(mouseY)).sub(xc);
    }
  }
  void mouseReleased() {
    pressed = false;
    dxc = new PVector(); dphi = 0; // Don't include velocity
  }
  void mouseWheel(MouseEvent event) {
    if (distance( mouseX, mouseY )<1) rotate(event.getCount()/PI/100);
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

  float pressPower ( Field p, float dt ) {
    float power = 0;
    for ( OrthoNormal o: orth ) {
      float x = o.cen.x, y = o.cen.y,
            u = velocity( 1, dt, x, y ),
            v = velocity( 2, dt, x, y ),
            pdl = p.linear( x, y )*o.l;
      power += pdl*(u*o.nx+v*o.ny);
    }
    return power;
  }

  // compute body reaction to applied force and moment
  void react (PVector force, float moment, float dt) {
    /* X,Y */
    if(xfree|yfree){
      // rotate to body-fixed axis
      float sa = sin(phi), ca = cos(phi);
      rotate(force,-sa,ca);
      rotate(ddotxc,-sa,ca);
      // compute acceleration (in global axis)
      ddotxc.x = (force.x+ma.x*ddotxc.x)/(mass+ma.x);
      ddotxc.y = (force.y+ma.y*ddotxc.y)/(mass+ma.y);
      rotate(ddotxc,sa,ca);
      // compute velocity and delta
      dotxc.add(ddotxc.copy().mult(dt));
      dxc = dotxc.copy().mult(dt);
      // translate
      if(!xfree) {dxc.x=0; dotxc.x=0; ddotxc.x=0;}
      if(!yfree) {dxc.y=0; dotxc.y=0; ddotxc.y=0;}
      translate(dxc.x+0.5*ddotxc.x*sq(dt),dxc.y+0.5*ddotxc.y*sq(dt));
    } else{
      dxc=new PVector(); dotxc=new PVector(); ddotxc=new PVector();
    }
    /* Phi */
    if(pfree){
      // compute acceleration & velocity
      ddotphi = (moment+ma.z*ddotphi)/(I0+ma.z);
      dotphi += ddotphi*dt;
      // compute delta and position
      dphi = dotphi*dt;
      rotate(dphi+0.5*ddotphi*sq(dt));
    } else{
      dphi=0; dotphi=0; ddotphi=0;
    }
  }
  void react (BDIM flow) {
    PVector f = pressForce(flow.p).mult(-1);
    float m = pressMoment(flow.p)*(-1);
    react(f,m,flow.dt);
  }

  // check if motion is within box limits
  boolean check_phi_free(float m, float phi_high, float phi_low){
    return !(phi<phi_low & (m<0 | dotphi<0)) & 
           !(phi>phi_high & (m>0 | dotphi>0));
  }
  boolean check_y_free(float fy, float y_high, float y_low){
    return !(xc.y<y_low & (fy<0 | dotxc.y<0)) & 
           !(xc.y>y_high & (fy>0 | dotxc.y>0));
  }

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
    a = 1./_a;
    float dx = 0.5*h*a, dy = 0.5*h;
    for ( int i=0; i<m; i++ ) {
      float theta = -TWO_PI*i/((float)m);
      add(xc.x+dx*cos(theta), xc.y+dy*sin(theta));
    }
    end(); // finalize shape

    ma = new PVector(PI*sq(dy),PI*sq(dx),0.125*PI*sq(sq(dx)-sq(dy)));
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
  }
  
}