/*******************************************
Emplements a 1D body defined by an array of points
  The body is given a thickness of one.

example code:
void setup(){
  size(300,300);
  LineSegBody body = new LineSegBody(0.,.5,new Window());
  for( int i=1; i<25; i++ ){
    body.add(i/25.,(sin(i/3.)+1.5)/3.);      
  }
  body.end();
  body.weight = 4;
  body.display();
}
********************************/

class LineSegBody extends Body{
  float thk=4,weight;
  
  LineSegBody( float x, float y, Window window ){super(x,y,window); weight = window.pdx(thk);}
  
  void add( float x, float y ){coords.add( new PVector( x, y ) );}
  
  void end(){super.end(false);}
  
  void display( color C, Window window ){ // note: can display while adding
    stroke(C); noFill(); strokeWeight(weight);
    beginShape();
    for ( PVector x:  coords ) vertex(window.px(x.x),window.py(x.y));
    endShape();
  }
  
  float distance( float x, float y ){ // in cells
    float dis = -1e10;
    if(n>4) { // check distance to bounding box
      dis = box.distance(x,y);
      if(dis>3+thk) return dis;
    }
    // get dist to each line segment, choose min
    dis = 1e10;
    for( OrthoNormal o: orth ) dis = min(dis,o.distance(x,y,false));
    return dis-0.5*thk;
  }
  
  PVector pressForce ( Field p ) {
    PVector pv = new PVector(0, 0);
    for ( int s=-1; s<=1; s+=2 ){
      for ( OrthoNormal o: orth ) {
        float pdl = p.linear( o.cen.x+0.5*s*thk*o.nx, o.cen.y+0.5*s*thk*o.ny )*o.l;
        pv.add(s*pdl*o.nx, s*pdl*o.ny, 0);
      }
    }
    return pv;
  }
  
}

