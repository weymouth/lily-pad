/*********************************************************
                  Main Window! 

Click the "Run" button to Run the simulation.

Change the geometry, flow conditions, numercial parameters
 visualizations and measurments from this window. 

*********************************************************/
BDIM flow;
CircleBody body;
FloodPlot flood;

void setup(){
  int n=(int)pow(2,6)+2; // number of grid points
  size(400,400);         // display window size
  Window view = new Window(n,n);

  body = new CircleBody(n/3,n/2,n/8,view); // define geom (EllipseBody, initial location, radius, 
  flow = new BDIM(n,n,1.5,body);
//  flow = new BDIM(n,n,0.2,body,0.01,true);
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
}
void mousePressed(){body.mousePressed();}
void mouseReleased(){body.mouseReleased();}

