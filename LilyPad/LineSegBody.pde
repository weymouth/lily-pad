/*******************************************
 Emplements a 1D body defined by an array of points
 The body is given a thickness of 2 cells.
 
 example code:
BDIM flow;
Body line; 
void setup() {
  int n=(int)pow(2, 7);
  size(400, 400);      
  Window view = new Window(n, n);
  line = new LineSegBody(n/3., n/2., view);
  for ( int i=0; i<n/3.; i++ ) {
    line.add(n/3.+i, n/2.+5.*sin(TWO_PI*i/(n/3.)));
  }
  line.end();
  flow = new BDIM(n, n, 0.5, line,0.01,true);  
}

void draw() {
  flow.update();
  flow.update2();
  flow.u.curl().display(-0.5,0.5);
  line.display();
}
********************************/

class LineSegBody extends Body {
  float thk=2, weight;

  LineSegBody( float x, float y, Window window ) {
    super(x, y, window); 
    weight = window.pdx(thk);
  }

  void add( float x, float y ) {
    coords.add( new PVector( x, y ) );
  }

  void end() {
    super.end(false);
  }

  void display( color C, Window window ) { // note: can display while adding
    stroke(C); 
    noFill(); 
    strokeWeight(weight);
    beginShape();
    for ( PVector x : coords ) vertex(window.px(x.x), window.py(x.y));
    endShape();
  }

  float distance( float x, float y ) { // in cells
    float dis;
    if (n>4) { // distance to bounding box
      dis = box.distance(x, y);
      if (dis>3+thk) return dis;
    }
    // get dist to each line segment, choose min
    dis = 1e10;
    for ( OrthoNormal o : orth ) dis = min(dis, o.distance(x, y, false));
    return dis-0.5*thk;
  }

  PVector pressForce ( Field p ) {
    PVector pv = new PVector(0, 0);
    for ( int s=-1; s<=1; s+=2 ) {
      for ( OrthoNormal o : orth ) {
        float pdl = p.linear( o.cen.x+0.5*s*thk*o.nx, o.cen.y+0.5*s*thk*o.ny )*o.l;
        pv.add(s*pdl*o.nx, s*pdl*o.ny, 0);
      }
    }
    return pv;
  }
}