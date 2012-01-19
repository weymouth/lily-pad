/*******************************************

LineSegBody with general motions

********************************/

class GenMotionBody extends LineSegBody{
  ArrayList<PVector> coordsDx;
  
  GenMotionBody( float xc, float yc, float[] x, float[] y , Window window ){
    super(xc,yc,window);
    coordsDx = new ArrayList();
    for( int i=0; i<x.length; i++ ){
      add(x[i],y[i]);
      coordsDx.add(new PVector(0,0));
    }
    end();
  }
  
  // translation and rotation are done through with new coord update
  void translate( float dx, float dy ){ return;}
  void rotate( float dphi ){ return;}
  
  int closest( float x, float y ){
    int j=0; 
    float dis = orth[j].distance(x,y,false);
    for( int i=1; i<n-1; i++ ){
      float d = orth[i].distance(x,y,false);
      if(d<dis) {j=i; dis=d;}
    }
    return j;
  }
  
  float velocity( int d, float dt, float x, float y ){
    if(distance(x,y)>2) return 0; 
    // identify the nearest segment
    int i = closest(x,y);
    // get tangent coordinate of point (0<s<1)
    float s = orth[i].tanCoord(x,y);
    // get end point velocities
    PVector dx0 = coordsDx.get(i), dx1 = coordsDx.get(i+1);
    // interpolate requested component
    if(d==1) return ((1.-s)*dx0.x+s*dx1.x)/dt;
    else     return ((1.-s)*dx0.y+s*dx1.y)/dt;
  }

  void update( float[] x, float[] y ){
    for( int i=0; i<n; i++ ) {
      PVector x0 = coords.get(i);
      PVector x1 = new PVector(x[i],y[i]);
      coords.set(i,x1);
      coordsDx.set(i,PVector.sub(x1,x0));
    }
    end();
    unsteady = true;
  }
}

