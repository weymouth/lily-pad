/*******************************************
Emplements a closed convex body defined by an array of points

example code:
void setup(){
  Body body = new Body(0,0,new Window(4,4,0,15,5,80,80));
  body.add(0,3);
  body.add(3,0);
  body.add(0,0);
  body.end();
  rect(15,5,80,80);
  body.display();
  println(body.distance(3.,1.));
}
************************************/
class ConvexBody extends Body{
  ArrayList coords;
  int n;
  PVector[] fcoords;
  ConvexBody box;

  ConvexBody( float x, float y, Window window ){
    super(x,y,window);
    coords = new ArrayList();
  }
  
  void add( float x, float y ){
    coords.add( new PVector( x, y ) );
// remove concave points
    for ( int i = 0; i<coords.size() && coords.size()>3; i++ ){
      PVector x1 = (PVector) coords.get(i);
      PVector x2 = (PVector) coords.get((i+1)%coords.size());
      PVector x3 = (PVector) coords.get((i+2)%coords.size());
      PVector t1 = PVector.sub(x1,x2);
      PVector t2 = PVector.sub(x2,x3);
      float a = atan2(t1.y,t1.x)-atan2(t2.y,t2.x);
      if(sin(a)<0){
       coords.remove((i+1)%coords.size());
       i=0;
      }
    }
  }
  
  void end(){
    n = coords.size();
    fcoords = new PVector[n];
    PVector mn = xc.get();
    PVector mx = xc.get();
    for ( int i = 0; i<n ; i++ ) {
      fcoords[i] = new PVector();
      fcoords[i] = ((PVector) coords.get(i)).get();
      mn.x = min(mn.x,fcoords[i].x);
      mn.y = min(mn.y,fcoords[i].y);
      mx.x = max(mx.x,fcoords[i].x);
      mx.y = max(mx.y,fcoords[i].y);
    }
    // make the bounding box
    if(n>4){
      box = new ConvexBody(xc.x,xc.y,window);
      box.add(mn.x,mn.y);
      box.add(mn.x,mx.y);
      box.add(mx.x,mx.y);
      box.add(mx.x,mn.y);
      box.end();
    }
  }

  void display( color C, Window window ){ // note: can display while adding
//    if(n>4) box.display(#FFCC00);
    fill(C); noStroke();
    beginShape();
    if(n==0) {
      for ( int i = 0; i<coords.size(); i++ ){
        PVector x = (PVector) coords.get(i);
        vertex(window.px(x.x),window.py(x.y));
      }
    }else{
      for ( int i = 0; i<n; i++ ){
        PVector x = fcoords[i];
        vertex(window.px(x.x),window.py(x.y));
      }
    }
    endShape(CLOSE);
  }
  
  float distance( float x, float y ){ // in cells
/*  the distance from a line defined by two points
  (x1,x2) and a third point (x0) is
       d = |x0-x1|sin{arg{(x2-x1),(x0-x1)}}
    the intersection (maxval) of the line distance 
  functions defines the shape distance function */   
    float dis = 0;
    // check distance to bounding box
    if(n>4) {
      dis = box.distance(x,y);
      if(dis>2) return dis;
    }
    // loop through lines
    PVector x0 = new PVector(x,y);
    for ( int i = 0; i<n; i++ ){
      PVector x1 = fcoords[i];
      PVector x2 = fcoords[(i+1)%n];
      PVector t = PVector.sub(x2,x1);
      PVector l = PVector.sub(x0,x1);
      float a = atan2(l.y,l.x)-atan2(t.y,t.x);
      float d = l.mag()*sin(a);
      dis = (i==0)?d:max(d,dis);
    }
    return dis;
  }
  
  void translate( float dx, float dy ){
    super.translate(dx,dy);
    for ( int i = 0; i<n; i++ ){
      fcoords[i].add(dxc);
    }
    if(n>4) box.translate(dx,dy);
  }
  
  void rotate( float dphi ){
    super.rotate(dphi);
    for ( int i = 0; i<n; i++ ){
      fcoords[i] = rotate( fcoords[i] );
    }
    if(n>4) box.rotate(dphi);
  }
  PVector rotate( PVector x ){
    x.sub(xc);
    PVector z = new PVector(cos(dphi)*x.x-sin(dphi)*x.y,
                            sin(dphi)*x.x+cos(dphi)*x.y);
    z.add(xc);
    return z;
  }
}
