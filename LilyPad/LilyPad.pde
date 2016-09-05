/*********************************************************
                  Main Window!

Click the "Run" button to Run the simulation.

Change the geometry, flow conditions, numercial parameters
visualizations and measurments from this window.

This screen has an example. Other examples are found at 
the top of each tab. Copy/paste them here to run, but you 
can only have one setup & run at a time.

*********************************************************/
// Circle that can be dragged by the mouse
BDIM flow;
Body body;
FloodPlot flood;

void setup(){
  size(700,700);                             // display window size
  int n=(int)pow(2,7);                       // number of grid points
  float L = n/8.;                            // length-scale in grid units
  Window view = new Window(n,n);

  body = new CircleBody(n/3,n/2,L,view);     // define geom
  flow = new BDIM(n,n,1.5,body);             // solve for flow using BDIM
  flood = new FloodPlot(view);               // intialize a flood plot...
  flood.setLegend("vorticity",-.5,.5);       //    and its legend
}
void draw(){
  body.follow();                             // update the body
  flow.update(body); flow.update2();         // 2-step fluid update
  flood.display(flow.u.curl());              // compute and display vorticity
  body.display();                            // display the body
}
void mousePressed(){body.mousePressed();}    // user mouse...
void mouseReleased(){body.mouseReleased();}  // interaction methods
void mouseWheel(MouseEvent event){body.mouseWheel(event);}