/********************************
BodyUnion class

This class combines an array of body instances by a union operator
which `adds` bodies to the flow. If two bodies are given, they are added
automatically. Bodies can also be 'add'ed individually. 

Other operations are possible but haven't been coded up yet.

SaveArray is a writer class that outputs all the values for the array 
in one line. At this point, only the pressure forces have been coded.

Example code:

BodyUnion body;
void setup(){
  size(400,400);
  Window view = new Window(100,100);
  body = new BodyUnion( new NACA(30,30,20,0.2,view),
                        new CircleBody(70,30,15,view));
  body.add(new CircleBody(30,70,15,view));
}
void draw(){
  background(0);
  body.follow(); // uncomment to move as a group
  //for (Body child : body.bodyList) child.follow(); // uncomment to move individually
  body.display();
}
void mousePressed(){body.mousePressed();}
void mouseReleased(){body.mouseReleased();}
********************************/
class BodyUnion extends Body{
  ArrayList<Body> bodyList = new ArrayList<Body>();  //This is a container for all bodies

  BodyUnion(float x, float y, Window window){ 
    super(x, y, window);
  }

  BodyUnion(Body a, Body b){
    super(a.xc.x,a.xc.y,a.window);
    add(a); add(b);
  }

  void add(Body body){
    bodyList.add(body);
    area += body.area;
  }
  
  void recenter(){
    xc = new PVector(); 
    for (Body b : bodyList){xc.add(b.xc.copy().mult(b.area));}
    xc = xc.div(area);
  }
  void recenter(float x, float y){xc = new PVector(x,y);}
  
  void display(color C, Window window ){
    for ( Body body : bodyList ){
        body.display(C, window);
    }
  }
  
  float distance(float x, float y){
    float d = 1e6;
    for ( Body body : bodyList )
      d = min(d,body.distance(x,y));
    return d;
  }  
  
  PVector WallNormal(float x, float y){
    float w[] = get_weights(x,y);
    PVector m = new PVector(0,0);
    for ( int i = 0; i<bodyList.size(); i++ ) {
      PVector n = bodyList.get(i).WallNormal(x,y);
      m.add(n.mult(w[i]));
    }
    return m;
  }
  
  float velocity( int d, float dt, float x, float y ){
    float w[] = get_weights(x,y);
    float v = 0;
    for ( int i = 0; i<bodyList.size(); i++ ) {
      float u = bodyList.get(i).velocity(d,dt,x,y);
      v += u*w[i];
    }
    return v;
  }

  void translate(float dx, float dy){
    xc.add(new PVector(dx, dy));
    for (Body body : bodyList) body.translate(dx,dy);
  }
  void rotate(float dphi){ // rotate around _union_ xc
    float sa = sin(dphi), ca = cos(dphi)-1;
    phi = phi+dphi;
    for (Body body : bodyList){
      PVector z = PVector.sub(body.xc,xc);
      float dx = ca*z.x-sa*z.y;
      float dy = sa*z.x+ca*z.y;
      body.translate(dx,dy);
      body.rotate(dphi);
    }
  }
  void initPath(PVector p){
    follow(p);
    for (Body body : bodyList) {
      body.dxc = new PVector(); body.dphi = 0;
    }
  }

  boolean unsteady(){ 
    boolean unsteady = false;
    for (Body body : bodyList){
      unsteady = unsteady | body.unsteady();
    }
    return unsteady;
  }

  void react(BDIM flow){
    for (Body body : bodyList) body.react(flow);
  }
  void react(PVector f, float m, float dt){
    for (Body body : bodyList) body.react(f,m,dt);
  }

  void mousePressed(){
    super.mousePressed();
    for (Body body : bodyList){body.mousePressed();}
  }  
  void mouseReleased(){
    super.mouseReleased();
    for (Body body : bodyList){body.mouseReleased();}
  }
  void mouseWheel(MouseEvent event){
    super.mouseWheel(event);
    for (Body body : bodyList){body.mouseWheel(event);}
  }

// weight the body influences at point x,y
  float[] get_weights(float x, float y){
    int n = bodyList.size();
    float s=0, weights[]=new float[n];
    for ( int i = 0; i<n; i++ ){
      float d = bodyList.get(i).distance(x,y);
      weights[i] = delta0(-d/3.); // kernel weight
      s += weights[i];
    }
    for ( int i = 0; i<n & s>0; i++) 
        weights[i] /= s;          // normalize weights
    return weights;
  }
  
  float delta0( float d ){
    if( d <= -1 ){
      return 0;
    } else if( d >= 1 ){
      return 1;
    } else{
      return 0.5*(1.+d+sin(PI*d)/PI);
    } 
  }
}

// Save values on an array of bodies

class SaveArray{
  PrintWriter output;
  
  SaveArray(String name){
    output = createWriter(name);
  }
  
  void printPressForce(Field pressure, BodyUnion bodies, float L){
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