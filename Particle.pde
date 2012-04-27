class Particle {
  Window window;
  color bodyColor;
  PVector x;
  
  Particle( float x0, float y0, color _color, Window _window ) {
    x = new PVector( x0 , y0 );
    bodyColor = _color;
    window = _window;
  }
  
  void update( float dt, VectorField u, VectorField u0 ){
    float px = x.x+dt*u0.x.quadratic( x.x, x.y ); // forward
    float py = x.y+dt*u0.y.quadratic( x.x, x.y ); //   projection
    float p0x = px-dt*u.x.quadratic( px, py );    // backward 
    float p0y = py-dt*u.y.quadratic( px, py );    //   projection
    x.set(px+(x.x-p0x)*0.5,py+(x.y-p0y)*0.5,0);   // O(2) update
  }

  void display(){display(bodyColor);}
  void display(color C){
    fill(C);
    ellipse(window.px(x.x),window.py(x.y),3,3);
  }

}


