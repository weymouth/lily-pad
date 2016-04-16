/*********************************************************
                  Main Window!

Click the "Run" button to Run the simulation.

Change the geometry, flow conditions, numercial parameters
visualizations and measurments from this window.

This screen has two examples. You can comment/uncomment to 
run (but you can only use one setup & run at a time). Other 
examples are found at the top of each tab.

*********************************************************/
// Circle that can be dragged by the mouse
BDIM flow;
Body body;
FloodPlot flood;

void setup(){
  size(800,800);                             // display window size
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
  flood.display(flow.u.vorticity());         // compute and display vorticity
  body.display();                            // display the body
}
void mousePressed(){body.mousePressed();}    // user mouse...
void mouseReleased(){body.mouseReleased();}  // interaction methods
/*
// Foil that follows prescribed motion
BDIM flow;
Body foil;
FloodPlot plot;
PrintWriter output;
int n=(int)pow(2,7);   // number of grid points
float L = n/4.;        // length-scale in grid units
float St = 0.2;        // Strouhal number of motion
float Re = 2000;       // Reynolds number of flow
float x0 = n/3, y0 = n/2, t=0;

void setup(){
  size(800,800);                                // display window size
  Window view = new Window(n,n);                // mapping from grid to display

  foil = new NACA(x0,y0,L,0.2,view);            // define the geometry...
  foil.initPath(kinematics(t));                 //     and its starting point

  flow = new BDIM(n,n,0.,foil,L/Re,true);       // BDIM+QUICK
  
  plot = new FloodPlot( view );                 // define particle plot...
  plot.setLegend("Vorticity",-0.5,0.5);         //     and its legend
  
  output = createWriter("test/out"+L+".csv");   // open output file
}
void draw(){
  float dt = flow.dt; t += dt;               // update the time
  foil.follow(kinematics(t));                // update the body
  flow.update(foil); flow.update2();         // 2-step fluid update
  plot.display(flow.u.vorticity());          // display the vorticity
  foil.display();                            // display the body
  
  PVector force = foil.pressForce(flow.p);   // get pressure force
  float ts = St*t/L;                         // time coefficient
  float Cy = -2.*force.y/L;                  // vertical force coefficient
  float vs = foil.dxc.y/dt;                  // vertical velocity coefficient
  output.println(""+ts+","+Cy+","+vs);       // print to file

  if(ts>=3){                                 // finish after 3 cycles
    output.close();
    exit();
  }
}
PVector kinematics(float t){                 // define the foil motion
  float phase = TWO_PI*St*t/L;               // phase
  return new PVector(x0-0.1*L*sin(2*phase),  // x position
                     y0-0.75*L*sin(phase),   // y position
                     PI/3.*cos(phase));      // angular (phi) position
}
*/