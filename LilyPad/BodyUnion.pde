/********************************
BodyUnionArray & BodyUnion class

This class combines an array of body instances by a union operator
which `adds` bodies to the flow. 

Other operations are possible but haven't been coded up yet.


Example code:

BodyUnion bodyU;
BodyUnionArray bodyA;
void setup(){
  size(400,400);
  Window view = new Window(100,100);
  bodyU = new BodyUnion( new NACA(30,30,20,0.2,view),
                         new CircleBody(70,30,15,view));
  bodyA = new BodyUnionArray( 30,30,view ); 
  bodyA.add(new NACA(30,30,20,0.2,view));
  bodyA.add(new CircleBody(70,30,15,view));
  bodyA.add(new CircleBody(30,70,15,view));
}
void draw(){
  background(0);
  //bodyU.update();
  //bodyU.display();
  bodyA.update();
  bodyA.display();
}
//void mousePressed(){bodyU.mousePressed();}
//void mouseReleased(){bodyU.mouseReleased();}
void mousePressed(){bodyA.mousePressed();}
void mouseReleased(){bodyA.mouseReleased();}
********************************/
class BodyUnionArray extends Body{
  ArrayList<Body> bodyList = new ArrayList<Body>();  //This is a container for all bodies

  BodyUnionArray(float x, float y, Window window){ 
    super(x, y, window);
  }

  void add(Body body){
    bodyList.add(body);
  }
  
  void display(color C, Window window ){
    for ( Body body : bodyList ){
        body.display(C, window);
    }
  }
  
  Body closest (float x, float y){
    float dmin = 1e5;
    Body closest = bodyList.get(0);
    for (Body body : bodyList){
      if(body.distance(x, y) < dmin){
        dmin = body.distance(x, y);
        closest = body;
      }
    }
    return closest;
  }
  
  float distance(float x, float y){
    Body c = closest(x,y);
    return c.distance(x,y); 
  }  
  
  PVector WallNormal(float x, float y){
     Body c = closest(x,y);
     return c.WallNormal(x,y); 
  }
  
  float velocity( int d, float dt, float x, float y ){
    Body c = closest(x,y);
    return c.velocity(d,dt,x,y);
  }

  void update(){
    for (Body body : bodyList){body.update();}
  }
  void mousePressed(){
    for (Body body : bodyList){body.mousePressed();}
  }  
  void mouseReleased(){
    for (Body body : bodyList){body.mouseReleased();}
  }
}

class BodyUnion extends BodyUnionArray{
  Body a,b;
  
  BodyUnion(Body a, Body b){
    super(a.xc.x,a.xc.y,a.window);  
    add(a); add(b);
    this.a = a; this.b = b;
  }
}

// Save values on an array of bodies

class SaveArray{
  PrintWriter output;
  
  SaveArray(String name){
    output = createWriter(name);
  }
  
  void printPressForce(Field pressure, BodyUnionArray bodies, float L){
    for(Body body: bodies.bodyList){
        PVector force = body.pressForce(pressure);
        output.print(2.*force.x/L+" "+2.*force.y/L+" ");
    }
    output.println();
  }

  void close(){
    output.close(); // Finishes the file
  }  
}