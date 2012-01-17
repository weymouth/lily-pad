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
  body.display();
}
********************************/

class LineSegBody extends ConvexBody{

  LineSegBody( float x, float y, Window window ){super(x,y,window);}
  
  void add( float x, float y ){coords.add( new PVector( x, y ) );}
  
  void end(){super.end(false);}
  
  void display( color C, Window window ){ // note: can display while adding
//    if(n>4) box.display(#FFCC00);
//    fill(C); ellipse(window.px(xc.x),window.py(xc.y),3,3);
    stroke(C); noFill(); strokeWeight( 2 );
    beginShape();
    for ( PVector x:  coords ) vertex(window.px(x.x),window.py(x.y));
    endShape();
  }
  
  float distance( float x, float y ){ // in cells
    float dis = -1e10;
    if(n>4) { // check distance to bounding box
      dis = box.distance(x,y);
      if(dis>2) return dis;
    }
    // get dist to each line segment, choose min
    dis = 1e10;
    for(int i=0; i<orth.length; i++){
      PVector o = orth[i];
      PVector a = coords.get(i); 
      PVector b = coords.get((i+1)%n);
      float d = x*o.x-y*o.y-o.z;          // norm dis to line
      float ta = (x-a.x)*o.y+(y-a.y)*o.x; // tang dis to start
      float tb = (x-b.x)*o.y+(y-b.y)*o.x; // tang dis to end
      dis = min(dis,sqrt(sq(d)+sq(max(0,ta))+sq(max(0,-tb))));
    }
    return dis-1.5;
  }
}

