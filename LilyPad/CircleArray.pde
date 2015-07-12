/*********************************
CircleArray class creats a single circle ring of cylinders.
The input arguments are center coordinates X, Y; diameter of each cylinder D; 
Radius of circle array; division n; Angle of Attack rad; window.

CircleArrangement class extends CircleArray class to create circle arrangement 
for many times.

SaveDrag class saves drag coefficient by two methods: 
1. saves the total drag coefficient; 
2. saves each cylinder's drag coefficient.

Example code: 

SaveDrag dat;
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
  dat = new SaveDrag("saved/test.txt",body);   
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
  dat.addDataT(flow.p, DG);
}
**********************************/

class CircleArray extends Body{
  ArrayList<CircleBody> circleList = new ArrayList<CircleBody>();          //This is a container for all bodies

  CircleArray(float x, float y, Window window){ 
    super(x, y, window);
  }

  void add(float X, float Y, float d){
    circleList.add(new CircleBody(X, Y, d, window));
  }
  
  void display(color C, Window window ){
    for ( CircleBody circle : circleList ){
        circle.display(C, window);
    }   
  }
  
  Body closest (float x, float y){
    float dmin = 1e5;
    Body body = circleList.get(0);
    for (CircleBody circle: circleList){
      if(circle.distance(x, y) < dmin){
        dmin = circle.distance(x, y);
        body = circle;
      }
    }
    return body;
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
}


/*================================================
            CircleArrangement class 
================================================*/

class CircleArrangement extends CircleArray {
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
        ring( x, y, d, R, n-1, rad );
      }
      ring( x, y, d, 0, 1, rad );
    } else{
      int temp;
      temp = n-1;
      for (int i=1; i<N; i++){ //loop in the different ring; i is current ring.
        ring( x, y, d, R/N*i, ring[i], rad );
        temp = temp - ring[i];
      }
      ring( x, y, d, R, temp, rad );
      ring( x, y, d, 0, 1, rad );
    }
  }
  
  void ring(float x, float y, float d, float R, int n, float rad){
    for ( int i = 1; i <= n; i++ ){
      float X = x+R*cos(TWO_PI/n*i+rad);
      float Y = y+R*sin(TWO_PI/n*i+rad);
      add(X, Y, d);
    }    
  }
}

/*================================================
            SaveDrag class 
================================================*/

class SaveDrag{
  PrintWriter output;
  ArrayList<CircleBody> bodys = new ArrayList<CircleBody>();
  int n;
  
  SaveDrag(String name, CircleArrangement body){
    output = createWriter(name);
    n = 0;
    for(CircleBody circle : body.circleList){
      bodys.add(circle);
      n++; 
    }
    this.bodys = bodys;
    this.n = n;
  }
  
  // add total drag coefficient of array
  void addDataT(Field a, float L){
      PVector pressure=new PVector(0, 0);
      for(CircleBody circle : bodys){
         pressure.add(circle.pressForce(a));
      }
        output.println(2*pressure.x/L + " ");
      }
  // add single drag coefficient of each cylinder of array
  void addDataS(Field a, float L){
      for(CircleBody circle : bodys){
         output.print(2*circle.pressForce(a).x/L+" ");
      }
        output.println();
      }
  
    void finish(){
    output.flush(); // Writes the remaining data to the file
    output.close(); // Finishes the file
  }
  
}



