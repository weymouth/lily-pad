class Particle {
  Window window;
  color bodyColor;
  PVector x,x0;
  int step=0, life=10;
  
  Particle( float x0, float y0, color _color, Window _window ) {
    x = new PVector( x0 , y0 );
    bodyColor = _color;
    window = _window;
  }
  
  void update( float dt, VectorField u, VectorField u0 ){
    x0 = x.get();
    float px = x.x+dt*u0.x.quadratic( x.x, x.y ); // forward
    float py = x.y+dt*u0.y.quadratic( x.x, x.y ); //   projection
    float p0x = px-dt*u.x.quadratic( px, py );    // backward 
    float p0y = py-dt*u.y.quadratic( px, py );    //   projection
    x.set(px+(x.x-p0x)*0.5,py+(x.y-p0y)*0.5,0);   // O(2) update
    step++;
  }

  void display(){display(bodyColor);}
  void display(color C){
    stroke(C);
    line(window.px(x0.x),window.py(x0.y),window.px(x.x),window.py(x.y));
  }
  
  boolean dead(){
    return ( window.px(x.x)<-10 || window.py(x.y)<-10 || window.px(x.x)>width+10 || window.py(x.y)>height+10 || step > life );
  }
}

class Swarm{
  ArrayList<Particle> pSet;
  Window window;
  int imax;

  Swarm( Window window, int imax){ 
    pSet = new ArrayList();
    this.window = window;
    this.imax = imax; 
  }

  void update(BDIM flow){
    // remove dead Particles
    Iterator<Particle> pIter = pSet.iterator();
    while ( pIter.hasNext() ){
      if( pIter.next().dead() ) pIter.remove();
    }
    // add new Particles
    boolean free = flow.u.x.bval > 0;
    for( int i=0; pSet.size()<imax & i<imax/10; i++) {
      float x = random(1,width), y = random(1,height);
      if(free) x = -log(random(1))*width/2;
      x = window.ix((int)x); y = window.iy((int)y);
      pSet.add( new Particle(x,y,color(0),window) );
    }
    // update Particles
    println("Swarm size:"+pSet.size());
    for( Particle p: pSet) p.update( flow.dt, flow.u, flow.u0 );
  }
  
  void display(){
    for( Particle p: pSet) p.display();
  }
  
}



