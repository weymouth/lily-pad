/*******************************************
Emplements a closed convex body defined by an array of points

example code:
void setup() {
  ConvexBody body = new ConvexBody(0,0,new Window(0,0,4,4));
  body.add(0.5,2.5);
  body.add(2.75,0.25);
  body.add(0,0);
  body.end();
  body.display();
  println(body.distance(3.,1.)); // should be sqrt(1/2)
}
************************************/
class ConvexBody extends Body{
  ArrayList<PVector> coords;
  int n;
  PVector[] fcoords,orth;
  ConvexBody box;

  ConvexBody( float x, float y, Window window ){
    super(x,y,window);
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
    fcoords = new PVector[n];
    PVector mn = xc.get();
    PVector mx = xc.get();
    for ( int i = 0; i<n ; i++ ) {
      fcoords[i] = coords.get(i);
      mn.x = min(mn.x,fcoords[i].x);
      mn.y = min(mn.y,fcoords[i].y);
      mx.x = max(mx.x,fcoords[i].x);
      mx.y = max(mx.y,fcoords[i].y);
    }
    orth = new PVector[closed?n:n-1];
    getOrth(); // get orthogonal projection of line segments

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
  void end(){end(true);}

  void getOrth(){    // get orthogonal projection to speed-up distance()
    for( int i = 0; i<orth.length ; i++ ) {
      PVector x1 = fcoords[i];
      PVector x2 = fcoords[(i+1)%n];
      float l = PVector.sub(x1,x2).mag();
      float sa = (x1.y-x2.y)/l;  // sin alpha
      float ca = (x1.x-x2.x)/l;  // cos alpha
      float o = x1.x*sa-x1.y*ca; // offset
      orth[i] = new PVector(sa,ca,o);
    }
  }


  void display( color C, Window window ){ // note: can display while adding
//    if(n>4) box.display(#FFCC00);
    fill(C); noStroke();
    beginShape();
    if(n==0) {
      for ( PVector x:  coords ) vertex(window.px(x.x),window.py(x.y));
    }else{
      for ( PVector x: fcoords ) vertex(window.px(x.x),window.py(x.y));
    }
    endShape(CLOSE);
  }
  
  float distance( float x, float y ){ // in cells
    float dis = -1e10;
    if(n>4) { // check distance to bounding box
      dis = box.distance(x,y);
      if(dis>2) return dis;
    }
    // check distance to each line, choose max
    for ( PVector o : orth ) dis = max(dis,x*o.x-y*o.y-o.z);
    return dis;
  }
  
  void translate( float dx, float dy ){
    super.translate(dx,dy);
    for ( PVector x: fcoords ) x.add(dxc);
    for ( PVector o: orth    ) o.z += dx*o.x-dy*o.y; // adjust offset
    if(n>4) box.translate(dx,dy);
  }
  
  void rotate( float dphi ){
    super.rotate(dphi);
    float sa = sin(dphi), ca = cos(dphi);
    for ( PVector x: fcoords ) rotate( x, sa, ca ); 
    getOrth(); // get new orthogonal projection
    if(n>4) box.rotate(dphi);
  }
  void rotate( PVector x , float sa, float ca ){
    PVector z = PVector.sub(x,xc);
    x.x = ca*z.x-sa*z.y+xc.x;
    x.y = sa*z.x+ca*z.y+xc.y;
  }
}
