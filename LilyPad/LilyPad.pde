/*********************************************************
                  Main Window!

Click the "Run" button to Run the simulation.

Change the geometry, flow conditions, numercial parameters
visualizations and measurments from this window.

*********************************************************/
BDIM flow;
Body body;
FloodPlot flood;

void setup(){
  size(800,800);         // display window size
  int n=(int)pow(2,7);   // number of grid points
  float L = n/8.;        // length-scale in grid units
  Window view = new Window(n,n);

  body = new CircleBody(n/3,n/2,L,view);     // define geom
  flow = new BDIM(n,n,1.5,body);             // solve for flow using BDIM
//  flow = new BDIM(n,n,0.,body,L/200,true);   // BDIM+QUICK
  flood = new FloodPlot(view);               // intialize...
  flood.setLegend("vorticity",-.5,.5);       // and label a flood plot
}
void draw(){
  body.update();                             // update the body
  flow.update(body); flow.update2();         // 2-step fluid update
  flood.display(flow.u.vorticity());         // compute and display vorticity
  body.display();                            // display the body
}
void mousePressed(){body.mousePressed();}    // user mouse...
void mouseReleased(){body.mouseReleased();}  // interaction methods