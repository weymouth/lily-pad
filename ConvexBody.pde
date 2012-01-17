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
  OrthoNormal orth[];
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
      PVector x1 = coords.get(i);
      PVector x2 = coords.get((i+1)%n);
      orth[i] = new OrthoNormal(x1,x2);
    }
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
      if(dis>2) return dis;
    }
    // check distance to each line, choose max
    for ( OrthoNormal o : orth ) dis = max(dis,o.distance(x,y));
    return dis;
  }
  
  void translate( float dx, float dy ){
    super.translate(dx,dy);
    for ( PVector x: coords ) x.add(dxc);
    for ( OrthoNormal o: orth   ) o.translate(dx,dy);
    if(n>4) box.translate(dx,dy);
  }
  
  void rotate( float dphi ){
    super.rotate(dphi);
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
}
