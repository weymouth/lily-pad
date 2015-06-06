/*********************************
CircleArray class creats a single circle ring of cylinders.
The input arguments are center coordinates X, Y; diameter of each cylinder D; 
Radius of circle array; division n; Angle of Attack rad; window.

CircleArrangement class uses CircleArray to setup circular arrangement for many times.

Example code: 

SaveData2 dat;
CircleArrangement body;
BDIM flow;
FloodPlot flood;
int n=(int)pow(2,6)+2;
float DG = float(n-2)/2;   // Bundle diameter
float d = DG/21.;          // Cylinder's diameter
float R = DG/2;            //Bundle radius 
float ReG = 2100;          //physical Reynolds number
float Reh = ReG/DG;        //grid-based Reynolds number

void setup(){
  size(600,600);            // display window size
  Window view = new Window(n,n);
  float x = (float)n/2., y = (float)n/2.;  //central position 
  body = new CircleArrangement(x, y, d, R, 20, PI/2, view); 
  dat = new SaveData2("saved/N39d12DragAoA90.txt",body);   
  flow = new BDIM(n,n,0,body,(float)1./Reh,true);
  flood = new FloodPlot(view);
  flood.range = new Scale(-.75,.75);
  flood.setLegend("vorticity");
}

void draw(){
  body.update();
  flow.update(body);
  flow.update2();
  flood.display(flow.u.vorticity());
  body.display();
  dat.addData(flow.p,"Drag", DG);    // "Drag" or "Lift"
}
**********************************/

class CircleArray extends Body{
  ArrayList<CircleBody> circleList = new ArrayList<CircleBody>();          //This is a container for all bodies
  float X, Y;                                                              //X, Y represent a temporal coordinate of a new body
  CircleArray(float x, float y, float d, float R, int n, float rad, Window window){
    super(x, y, window);
    for ( int i = 1; i <= n; i++ ){
      //Define each body's center coordinate.
      X = x+R*cos(TWO_PI/n*i+rad);
      Y = y+R*sin(TWO_PI/n*i+rad);
      circleList.add(new CircleBody(X, Y, d, window));
    }
  }
  
  void display(color C, Window window ){
    for ( CircleBody circle : circleList ){
        circle.display(C, window);
    }   
  }
  
  float distance(float x, float y){
    float d = 0;
    float dmin = 1E5;
    for ( CircleBody circle : circleList ){
        d = circle.distance(x, y);
        dmin = min(d, dmin);
    }
    return dmin;
  }  
  
   int distance( int px, int py){     // in pixels
    int d = 0;
    int dmin = (int)1e3;
    for ( CircleBody circle : circleList ){
        d = circle.distance(px, py);
        dmin = min(d, dmin);
    }
    return dmin;
    }  
    
  Body closest (float x, float y){  
      float dmin = 1e5;
      Body body = circleList.get(0);
      //CircleBody b;
      for (CircleBody circle: circleList){
          if(circle.distance(x, y) < dmin){
            dmin = circle.distance(x, y);
            body = circle;
          }
      }
      return body;
  }  
  
   PVector WallNormal(float x, float y){
     Body c = closest(x,y);
     return c.WallNormal(x,y); 
  }
  
    float velocity( int d, float dt, float x, float y ){
    Body c = closest(x,y);
    return c.velocity(d,dt,x,y);
    }
}



/*================================================
            CircleArrangement class 
================================================*/

class CircleArrangement extends Body {
  ArrayList<CircleArray> circleArr = new ArrayList<CircleArray>();  
  CircleArrangement(float x, float y, float d, float R, int n, //float ro,
      float rad, Window window) {
    super(x, y, window);
    
    int N; // N is number of rings
    if (n<=7){
      N = 1;
    } else if (n<=20){
      N = 2;
    } else if (n<=40){
      N = 3;
    } else if (n<=65){
      N = 4;
    } else if (n<=96) {
      N = 5;
    } else{
      N = 6;
    }
    
//  New a arraylist to restore the number of maximum cylinders on each ring.
//  This set of numbers is implemented from Eames' paper.
    int[] ring = new int[7];
    ring[1] = 6;
    ring[2] = 13;
    ring[3] = 20;
    ring[4] = 25;
    ring[5] = 31;

//  The logic for the arrangement is expect from centric cylinder and most outer ring, 
//  the middle parts are arranged separately with specific AoA.
    if (N==1){
      if(n==1){
        circleArr.add(new CircleArray(x, y, d, 0, 1, rad, window));
      }
      else{
        circleArr.add(new CircleArray(x, y, d, R, n-1, rad, window));
        circleArr.add(new CircleArray(x, y, d, 0, 1, rad, window));
      }
    } else{
    int temp;
    temp = n-1;
    for (int i=1; i<N; i++){ //loop in the different ring; i is current ring.
      circleArr.add(new CircleArray(x, y, d, R/N*i, ring[i], rad, window));
      temp = temp - ring[i];
      }
      circleArr.add(new CircleArray(x, y, d, R, temp, rad, window));
      circleArr.add(new CircleArray(x, y, d, 0, 1, rad, window));
    }
  }

  float distance(float x, float y) {
    float d = 0;
    float dmin = 1E5;
    for (CircleArray array : circleArr) {
      d = array.distance(x, y);
      dmin = min(d, dmin);
    }
    return dmin;
  }

  void display(color C, Window window ){
    for ( CircleArray circle : circleArr ){
        circle.display(C, window);
    } 
  }
  
  int distance(int px, int py) { // in pixels
    int d = 0;
    int dmin = (int) 1e3;
    for (CircleArray array : circleArr) {
      d = array.distance(px, py);
      dmin = min(d, dmin);
    }
    return dmin;
  }

  Body closest(float x, float y) {
    float dmin = 1e5;
    CircleArray body = circleArr.get(0);
    // CircleBody b;
    for (CircleArray array : circleArr) {
      if (array.distance(x, y) < dmin) {
        dmin = array.distance(x, y);
        body = array;
      }
    }
    return body.closest(x, y);
  }

  PVector WallNormal(float x, float y) {
    Body c = closest(x, y);
    return c.WallNormal(x, y);
  }

  float velocity(int d, float dt, float x, float y) {
    Body c = closest(x, y);
    return c.velocity(d, dt, x, y);
  }
}




