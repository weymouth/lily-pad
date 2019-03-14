/************************
Chaotic Ellipse Class

This class demonstrates how the `react` function can be
used to model rigid-body fluid/structure interactions.

Example Code:

BDIM flow;
Body body;
FloodPlot flood;
int example = 3; // Choose an example reaction function

void setup(){
  size(700,700);                             // display window size
  int n=(int)pow(2,7);                       // number of grid points
  float L = n/4., l = 0.2;                   // length-scale in grid units
  Window view = new Window(n,n);
  body = new ChaoticEllipse(n/3,n/2,L*l,l,example,view); // define geom
  flow = new BDIM(n,n,1.,body);               // solve for flow using BDIM
  flood = new FloodPlot(view);                // intialize a flood plot...
  flood.setLegend("vorticity",-.5,.5);        //    and its legend
}
void draw(){
  body.react(flow);
  flow.update(body); flow.update2();         // 2-step fluid update
  flood.display(flow.u.curl());              // compute and display vorticity
  body.display();                            // display the body
}
*/

class ChaoticEllipse extends EllipseBody{
  float pivot, y0, x0, L;
  int example=0;
  
  ChaoticEllipse( float x, float y, float h, float a, float pivot, int example, Window window ){
    super(x+h/a*(0.5-pivot),y,h,a,window);
    this.example = example;
    x0 = x; y0 = y; L = h/a;
    // move pivot to x and adjust properties
    xc.x = x; box.xc.x = x;
    I0 += sq(L*(0.5-pivot))*area;
    ma.z += sq(L*(0.5-pivot))*ma.y;
  }
  ChaoticEllipse( float x, float y, float h, float a, int example, Window window ){
    this(x,y,h,a,0.5,example,window);
  }
  
  void display(color C, Window window ){
    super.display( C, window );
    fill(255);
    ellipse(window.px(xc.x),window.py(xc.y),5,5);
  }

  // Specialized body reaction functions
  void react(BDIM flow){
    if(example==1){
    // Example 1: free pitch, no actuation, no limits
      xfree = false; yfree=false; pfree=true;
      super.react(flow);
    } else if(example==2){
    // Example 2: free pitch, actuated heave, no limits
    //   Use the `react`-computed phi/dphi in `follow`
      xfree = false; yfree=false; pfree=true;
      super.react(flow);
      float St = 0.2, amp = 0.5*L;
      float y = amp*sin(TWO_PI*St/L*flow.t),
            dy = amp*cos(TWO_PI*St/L*flow.t)*TWO_PI*St/L*flow.dt;
      follow(new PVector(x0,y0+y,phi), new PVector(0,dy,dphi));  
    } else if(example==3){
    // Example 3: free pitch and heave, no actuation, heave limits
    //    Compute f.y and use to `check_y_free` and in `react`.
      PVector f = pressForce(flow.p).mult(-1);
      float m = pressMoment(flow.p)*(-1);
      xfree = false; yfree = check_y_free(f.y,y0+L,y0-L); pfree=true;
      super.react(f,m,flow.dt);
    } else {
      println("Unknown update example");
      stop();
    }
  }
}