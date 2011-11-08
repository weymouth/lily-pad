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
  float s0;

  LineSegBody( float x, float y, Window window ){
    super(x,y,window);
    add(x,y);    
  }
  
  void add( float x, float y ){
    coords.add( new PVector( x, y ) );
  }
  
  void display( color C, Window window ){ // note: can display while adding
//    if(n>4) box.display(#FFCC00);
    stroke(C); noFill(); strokeWeight( 2 );
    ellipse(window.px(xc.x),window.py(xc.y),4,4);
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
    endShape();
  }
  
  PVector get( float s){
/* the curve is defined by 
       P(s) = x0-(s-i)*(x0-x1)
       i = floor(s)
       x0 = P[i]
       x1 = P[i+1] */
    int i = floor(s);
    return new PVector(fcoords[i].x*(1-s+i)+fcoords[i+1].x*(s-i),
                       fcoords[i].y*(1-s+i)+fcoords[i+1].y*(s-i));
  }

  PVector get( float s, int i){
    return new PVector(fcoords[i].x*(1-s)+fcoords[i+1].x*(s),
                       fcoords[i].y*(1-s)+fcoords[i+1].y*(s));
  }

  float distance( float x, float y ){ // in cells
    float dis = 0;
    // check distance to bounding box
    if(n>4) {
      dis = box.distance(x,y);
      if(dis>2) return dis;
    }
/* continuing from above, the distance to 
     a third point x2 is 
       l(s) = |P(s)-x2|
     which is minimized by
       s = i+(x0-x2)(x0-x1)/(x0-x1)^2
     in each segment. all segments must be 
     compared to get the global minimum */
    PVector x2 = new PVector(x,y);
    for ( int i = 0; i<n-1; i++ ){
    // loop through lines
      PVector x0 = fcoords[i];
      PVector x1 = fcoords[i+1];
      PVector t = PVector.sub(x0,x1);
      PVector l = PVector.sub(x0,x2);
      float s = min(1,max(0,l.dot(t)/t.dot(t)));
      PVector Ps = get(s,i);
      float d = (PVector.sub(Ps,x2)).mag();
      if(d<dis || i==0){
        dis = d;
        s0 = s+i;  // save the index!
      }        
    }
    return dis-1;
  }
}

