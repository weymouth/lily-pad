/*************************
 Vortex class
 
 This is an example class for initializing the flow with one or more Rankine 
 vortices.  In the example code, a vortex pair is initialized in a quiescent 
 flow and then moves with its self-induced velocity.
 
 Example code:
//INPUT PARAMETERS_______________________________________________________________________
int resolution = 8;            // number of grid points spanning vortex diameter
int xLengths = 16;             // (streamwise length of computational domain)/(resolution)
int yLengths = 8;              // (transverse length of computational domain)/(resolution)
int area = 300000;             // window view area
int Re = 1000;                 // Reynolds number
float q = 1;                   // vortex circulation
float sep = 1;                 // (separation between opposite sign vortices)/(core diameter)
//_______________________________________________________________________________________

Vortex test;

void settings(){
  float s = sqrt(area*xLengths/yLengths);
  size((int)s, (int)s*yLengths/xLengths);
}
void setup() {
  test = new Vortex(resolution, Re, xLengths, yLengths, q, sep);
}

void draw() {
  test.update(); 
  test.display();
}

void keyPressed(){exit();}
***********************/


class Vortex {
  BDIM flow;
  boolean QUICK = true, order2 = true;
  int n, m, resolution;
  float dCore, q, sep, xc, yc, dt=1;
  CircleBody body;
  FloodPlot flood;
  VectorField u0;

  Vortex(int resolution, int Re, int xLengths, int yLengths, float q, float sep) {
    this.resolution = resolution;
    n=xLengths*resolution+2;
    m=yLengths*resolution+2;
    Window view = new Window(0, 0, n, m);
    this.dCore = resolution;
    this.q = q;
    this.sep = sep;
    this.u0 = new VectorField(n, m, 0, 0);
    xc = 0.2*n;
    yc = 0.5*m;
  
    //set up an initial velocity field of a Rankine vortex pair
    for ( int i=1 ; i<n-1 ; i++ ) {
      for ( int j=1 ; j<m-1 ; j++ ) {
        for ( int btype=1 ; btype<3 ; btype++ ) {
          float x = i;
          float y = j;
          if (btype==1) {
            x -= 0.5;
          }
          if (btype==2) {
            y -= 0.5;
          }
          //first vortex
          if (btype==1) {
            u0.x.a[i][j] += vortexX(x, y, xc, (yc - sep*dCore/2), -1);
          }
          if (btype==2) {
            u0.y.a[i][j] += vortexY(x, y, xc, (yc - sep*dCore/2), -1);
          }
          //second vortex
          if (btype==1) {
            u0.x.a[i][j] += vortexX(x, y, xc, (yc + sep*dCore/2), 1);
          }
          if (btype==2) {
            u0.y.a[i][j] += vortexY(x, y, xc, (yc + sep*dCore/2), 1);
          }
        }
      }
    }
    
    flow = new BDIM(n-2, m-2, 0, u0, (float)resolution/Re, QUICK);

    flood = new FloodPlot(view); 
    flood.range = new Scale(-.5, .5);
    flood.setLegend("vorticity");
  }

  // the integer pos specifies if the circulation is positive or negative
  float vortexX( float x, float y, float xc, float yc, int pos) {
    float c;
    if ((sq(x-xc) + sq(y-yc)) <= sq(dCore/2)) {
      c = -pos*q*(y-yc);
    } 
    else {
      c = -pos*q*sq(dCore/2)/( sq(x-xc) + sq(y-yc) )*(y-yc);
    }
    return c;
  }  

  float vortexY( float x, float y, float xc, float yc, int pos) {
    float c;
    if ((sq(x-xc) + sq(y-yc)) <= sq(dCore/2)) {
      c = pos*q*(x-xc);
    } 
    else {
      c = pos*q*sq(dCore/2)/( sq(x-xc) + sq(y-yc))*(x-xc);
    }  
    return c;
  }

  void update() {
    if (QUICK) {
      dt = flow.checkCFL();
      flow.dt = dt;
    }
    
    flow.update();
    if (order2) {
      flow.update2();
    }
  }

  void display() {
    flood.display(flow.u.curl());
  }
}