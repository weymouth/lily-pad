/*********************************************************
                  Main Window!

Click the "Run" button to Run the simulation.

Change the geometry, flow conditions, numercial parameters
visualizations and measurments from this window.

This screen has two examples. You can comment/uncomment to run.
Other exmaples are found at the top of each tab.

*********************************************************/
// Interactive example...
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

// Prescribed motion example
/*
BDIM flow;
Body body;
FloodPlot plot;
int n=(int)pow(2,7);   // number of grid points
float L = n/4.;        // length-scale in grid units
float St = 0.2;        // Strouhal number of motion
float Re = 2000;       // Reynolds number of flow
float x0 = n/3, y0 = n/2, t=0;

void setup(){
  size(800,800);         // display window size
  Window view = new Window(n,n);
  body = new NACA(x0,y0,L,0.2,view);         // define the geometry...
  body.setPath(kinematics(t),false);         //     and its path

  flow = new BDIM(n,n,0.,body,L/Re,true);    // BDIM+QUICK
  
  plot = new FloodPlot( view );              // define particle plot...
  plot.setLegend("Vorticity",-0.5,0.5);      //     and its legend
}
void draw(){
  t += flow.dt;
  body.path.add(kinematics(t));
  body.update();                             // update the body
  flow.update(body); flow.update2();         // 2-step fluid update
  plot.display(flow.u.vorticity());
  body.display();                            // display the body
}

PVector kinematics(float t){
  float phase = t/L*St*TWO_PI;               // phase
  return new PVector(x0+0.2*L*sin(2*phase),  // x position
                     y0-L*sin(phase),        // y position
                     PI/3.*cos(phase));      // angular (phi) position
}
*/