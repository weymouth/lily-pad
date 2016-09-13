import java.util.Iterator;
import java.util.ListIterator;
/*
Swarm class

This class and its extensions hold and update an ArrayList of Particles.

example code:

BDIM flow;
CircleBody body;
Swarm streaks;

void setup(){
  int n=(int)pow(2,6); size(400,400);
  Window view = new Window(n,n);
  body = new CircleBody(n/3,n/2,n/8,view);
  flow = new BDIM(n,n,1,body);
  streaks = new Swarm( view );  // adds when clicked or dragged
//  streaks = new SourceSwarm( view, new PVector(0,33) );
//  streaks = new FieldSwarm( view, 5000 );
//  streaks = new InletSwarm( view, 5000 );
}
void draw(){
//  background(200); // turn this on/off
  flow.update(); flow.update2();
  streaks.bodyColor = color(random(0,255),random(0,255),random(0,255));
  streaks.update(flow);
  streaks.display();
  body.display();
}
void mousePressed(){streaks.mousePressed();}
void mouseDragged(){streaks.mousePressed();}

**************************/

class Swarm{
  ArrayList<Particle> pSet;
  Window window;
  color bodyColor = color(0);
  int imax=1000, lifeSpan=200;
  boolean points=false, lines=true;

  Swarm( Window window ){ 
    pSet = new ArrayList<Particle>();
    this.window = window;
  }

  void update(VectorField u, VectorField u0 , float dt){
    remove();
    add( u, u0, dt);
    for( Particle p: pSet) p.update( u, u0, dt );
    println("Swarm size:"+pSet.size());
  }
  void update(BDIM flow){ update(flow.u,flow.u0,flow.dt); }

  void remove(){
    Iterator<Particle> pIter = pSet.iterator();
    while ( pIter.hasNext() ){
      if( pIter.next().dead() ) pIter.remove();
    }
  }

  void  add(VectorField u, VectorField u0 , float dt){
    return;
  }
  
  void display(){
    if(lines)  for( Particle p: pSet) p.display();
    if(points) for( Particle p: pSet) p.displayPoint();
  }
  
  void mousePressed() {
    float x = window.ix(mouseX), y = window.iy(mouseY);
    pSet.add( new Particle( x, y, bodyColor, window, lifeSpan ) );
  }

}


// Add particles uniformly over the window and upstream ! good for streamlines
class FieldSwarm extends Swarm{
  
  FieldSwarm( Window window , int imax ){
    super( window );
    this.imax = imax;
  }

  void add(VectorField u, VectorField u0 , float dt){
    float upstream = u.x.bval*lifeSpan*dt;
    int i0 = 1-window.px(upstream);
    for( int i=0; pSet.size()<imax & i<imax/lifeSpan; i++) {
      float x = random(i0,width), y = random(0,height);
      x = window.ix((int)x); y = window.iy((int)y);
      pSet.add( new Particle( x, y, bodyColor, window, lifeSpan ) );
    }
  }
}

// Add particle at a source point ! good for streaklines
class SourceSwarm extends Swarm{
  PVector p;

  SourceSwarm( Window window, PVector p ){
    super( window );
    this.p = new PVector(p.x,p.y);
    points = true; lines = false;
  }
  
  void add(VectorField u, VectorField u0 , float dt){
    Particle q = new Particle( p.x, p.y, bodyColor, window, lifeSpan );
    int n = imax/lifeSpan;
    for( int i=0; i<n ; i++){
      pSet.add( new Particle( q.x.x, q.x.y, bodyColor, window, lifeSpan ) );
      q.update( u, u0, -dt/(float)n ); // advect a partial step back
    }
  }
  
  void mousePressed() {
    p.x = window.ix(mouseX);
    p.y = window.iy(mouseY);
  }
}

// Add particles along the inlet ! good for colored path areas
class InletSwarm extends Swarm{
  
  InletSwarm( Window window, int imax ){
    super( window );
    this.imax = imax;
  }
  
  void add(VectorField u, VectorField u0 , float dt){
    for( int i=0; pSet.size()<imax & i<max(1,imax/lifeSpan) ; i++) {
      float x = 0, y = random(0,height);
      color c = (y<height/2+1)?color(#00FF33):color(#215E21);
//      color c = bodyColor;
      x = window.ix((int)x); y = window.iy((int)y);
      pSet.add( new Particle( x, y, c, window, lifeSpan ) );
    }
  }
}

// Extend SourceSwarm to fill in gaps between points. Even better for streaklines
class StreakSwarm extends SourceSwarm{
  Particle pp;

  StreakSwarm( Window window, PVector p, color bodyColor ){
    super( window, p );
    lifeSpan *= 10;
    this.bodyColor = bodyColor;
    pSet.add(new Particle( p.x, p.y, bodyColor, window, lifeSpan));
    pp = new Particle( p.x, p.y, bodyColor, window, lifeSpan);
  }
  
  void add(VectorField u, VectorField u0 , float dt){
    ListIterator<Particle> pIter = pSet.listIterator();
    while ( pIter.hasNext() ){
      Particle a = pIter.next();
      Particle b = pp;
      if( pIter.hasNext() ) b = pSet.get(pIter.nextIndex());
      int d2 = window.pdx(sq(a.x.x-b.x.x)+sq(a.x.y-b.x.y));
      if(d2>9) {
        pIter.add( new Particle( 0.5*(a.x.x+b.x.x), 0.5*(a.x.y+b.x.y), bodyColor, window, lifeSpan, (a.step+b.step)/2 ) );
      }else if(d2<1) {
        pIter.remove();
      }
    }
  }
}