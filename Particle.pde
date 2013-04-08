/*
Particle class

This class defines Lagrangian marker Particles which can be advected with the flow.

The Swarm class can be used to update a pack of these Particles. 


example code:

BDIM flow;
CircleBody body;
Swarm streaks;

void setup(){
  int n=(int)pow(2,6)+2; size(400,400);
  Window view = new Window(n,n);
  body = new CircleBody(n/3,n/2,n/8,view);
  flow = new BDIM(n,n,1,body);
  streaks = new Swarm( view, 1500, 25 );
}
void draw(){
  body.update();
  flow.update(); flow.update2();
  streaks.update(flow);
  noStroke(); fill(255,25); rect(0,0,width,height); // Draw partially transparent background to get streaky effect
  streaks.display();
  body.display();
}
**************************/

class Particle {
  Window window;
  color bodyColor;
  PVector x,x0;
  int step=0, lifeSpan;
  
  Particle( float x0, float y0, color _color, Window _window, int _lifeSpan ) {
    x = new PVector( x0 , y0 );
    bodyColor = _color;
    window = _window;
    lifeSpan = _lifeSpan;
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
    return ( window.py(x.y)<-10 || window.px(x.x)>width+10 || window.py(x.y)>height+10 || step > lifeSpan );
  }
}

class Swarm{
  ArrayList<Particle> pSet;
  Window window;
  int imax, lifeSpan;

  Swarm( Window window, int imax, int lifeSpan){ 
    pSet = new ArrayList();
    this.window = window;
    this.imax = imax; 
    this.lifeSpan = lifeSpan;
  }

  void update(BDIM flow){
    // remove dead Particles
    Iterator<Particle> pIter = pSet.iterator();
    while ( pIter.hasNext() ){
      if( pIter.next().dead() ) pIter.remove();
    }
    // add new Particles
    float upstream = flow.u.x.bval*lifeSpan*flow.dt;
    int i0 = 1-window.px(upstream);
    for( int i=0; pSet.size()<imax & i<imax/lifeSpan; i++) {
      float x = random(i0,width), y = random(1,height);
      x = window.ix((int)x); y = window.iy((int)y);
      pSet.add( new Particle( x, y, color(0), window, lifeSpan ) );
    }
    // update Particles
    println("Swarm size:"+pSet.size());
    for( Particle p: pSet) p.update( flow.dt, flow.u, flow.u0 );
  }
  
  void display(){
    for( Particle p: pSet) p.display();
  }
  
}



