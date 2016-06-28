/*********************************
Sets up an array of circles of the same diameter into a ringed arrangement.
The input arguments are center coordinates X, Y; diameter of each cylinder D; 
Radius of circle array; division n; Angle of Attack rad; window.

Example code: 

CircleArrangement body; 
BDIM flow;
FloodPlot flood;
int n = (int)pow(2,8), m = n/2;
float DG = m/2;            // Bundle diameter
float d = DG/21.;          // Cylinder's diameter
float ReG = 2100;          // physical Reynolds number

void setup(){
  size(1000,500);           // display window size
  float Reh = ReG/DG;       // grid-based Reynolds number
  float x = m/2, y = m/2.;  // central position 
  Window view = new Window(n,m);
  body = new CircleArrangement(x, y, d, DG/2, 20, PI/2, view); 
  flow = new BDIM(n,m,0,body,(float)1./Reh,true);
  flood = new FloodPlot(view);
  flood.setLegend("vorticity",-.75,.75);
}

void draw(){
  flow.update();
  flow.update2();
  flood.display(flow.u.curl());
  body.display();
}
**********************************/

class CircleArrangement extends BodyUnion {
  CircleArrangement(float x, float y, float d, float R, int n, float rad, Window window) {
    super(x, y, window);
    
    int N; // N is number of rings
    if (n<=7){
      N = 1;
    } else if (n<=20){
      N = 2;
    } else if (n<=39){
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
    ring[3] = 19;
    ring[4] = 25;
    ring[5] = 31;

//  The logic for the arrangement is expect from centric cylinder and most outer ring, 
//  the middle parts are arranged separately with specific AoA.
    if (N==1){
      if(n>1){
        ring( x, y, d, R, n-1, rad, window );
      }
      ring( x, y, d, 0, 1, rad, window );
    } else{
      int temp;
      temp = n-1;
      for (int i=1; i<N; i++){ //loop in the different ring; i is current ring.
        ring( x, y, d, R/N*i, ring[i], rad, window );
        temp = temp - ring[i];
      }
      ring( x, y, d, R, temp, rad, window );
      ring( x, y, d, 0, 1, rad, window );
    }
  }
  
  void ring(float x, float y, float d, float R, int n, float rad, Window window){
    for ( int i = 1; i <= n; i++ ){
      float X = x+R*cos(TWO_PI/n*i+rad);
      float Y = y+R*sin(TWO_PI/n*i+rad);
      add(new CircleBody(X, Y, d, window));
    }    
  }
}