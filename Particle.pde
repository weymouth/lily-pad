/*
Particle class

This class defines Lagrangian marker Particles which can be advected with the flow.

example code:

BDIM flow;
CircleBody body;
Particle marker;

void setup(){
  int n=(int)pow(2,6)+2; size(400,400);
  Window view = new Window(n,n);
  body = new CircleBody(n/3,n/2,n/8,view);
  flow = new BDIM(n,n,1,body);
  marker = new Particle( 0, 32, color(0), view, 300 );
}
void draw(){
  body.update();
  flow.update(); flow.update2();
  marker.update(flow.u,flow.u0,flow.dt);
  marker.display();
  body.display();
  if(marker.dead()) marker = new Particle( 0, 32, color(0), marker.window, 300 );
}
**************************/

class Particle {
  Window window;
  color bodyColor;
  PVector x,x0;
  int step=0, lifeSpan;
  
  Particle( float x0, float y0, color _color, Window _window, int _lifeSpan, int _step ) {
    x = new PVector( x0 , y0 );
    bodyColor = _color;
    window = _window;
    lifeSpan = _lifeSpan;
    step = _step;
  }
  Particle( float x0, float y0, color _color, Window _window, int _lifeSpan ) { this(x0,y0,_color,_window,_lifeSpan,0); }
  
  void update( VectorField u, VectorField u0, float dt ){
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
  
  void displayPoint(){displayPoint(bodyColor);}
  void displayPoint(color C){
    noStroke(); fill(C); ellipse(window.px(x.x),window.py(x.y),4,4);
  }

  boolean dead(){
    return ( window.py(x.y)<-10 || window.px(x.x)>width+10 || window.py(x.y)>height+10 || step > lifeSpan );
  }
}
