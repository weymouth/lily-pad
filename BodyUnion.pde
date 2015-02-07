/********************************
BodyUnion class

this class combines any two body instances by a union operator
which `adds` bodies to the flow. other operations are possible.

note that it is possble to get an arbitrary number of bodies by
applying the union multiple times, as in the example.

Example code:

BodyUnion body;
void setup(){
  size(400,400);
  Window view = new Window(100,100);
  body = new BodyUnion( new NACA(30,30,20,0.2,view),
                        new BodyUnion( new CircleBody(70,30,15,view), 
                                       new CircleBody(30,70,15,view) ));
}
void draw(){
  background(0);
  body.update();
  body.display();
}
void mousePressed(){body.mousePressed();}
void mouseReleased(){body.mouseReleased();}
********************************/

class BodyUnion extends Body{
  Body a,b;

  BodyUnion(Body a, Body b){
    super(a.xc.x,a.xc.y,a.window);  
    this.a = a; this.b = b;
  }


  void display( color C, Window window ){
    a.display(C,window);
    b.display(C,window);
  }

  void display(){
    a.display();
    b.display();
  }
  
  float distance( float x, float y){ // in cells
    return min(a.distance(x,y),b.distance(x,y));
  }
  int distance( int px, int py){     // in pixels
    return min(a.distance(px,py),b.distance(px,py));
  }

  Body closer(float x, float y){
    if(a.distance(x,y)<b.distance(x,y)) return a;
    else return b;
  }
  
  PVector WallNormal(float x, float y){
   Body c = closer(x,y);
   return c.WallNormal(x,y); 
  }
  
  float velocity( int d, float dt, float x, float y ){
    Body c = closer(x,y);
    return c.velocity(d,dt,x,y);
  }

  void update(){a.update();b.update(); unsteady=a.unsteady|b.unsteady; }
  void mousePressed(){a.mousePressed();b.mousePressed();}
  void mouseReleased(){a.mouseReleased();b.mouseReleased();}
}

