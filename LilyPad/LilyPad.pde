/*********************************************************
                  Main Window! 

Click the "Run" button to Run the simulation.

Change the geometry, flow conditions, numercial parameters
 visualizations and measurments from this window. 

*********************************************************/
BDIM flow;
CircleArrangement body;
FloodPlot flood;

void setup(){
  int n=(int)pow(2,8)+2; // number of grid points
  size(1400,1000);         // display window size
  Window view = new Window(0, 0, n, n);
  
  float D;           //Bundle radius
  float d = 2;       //Define each cylinder's diameter
  D = d * 21;
  float x = n/4, y = n/2;
  float aoa = PI/2;   //aoa is Angle of Attack
   
  body = new CircleArrangement(x, y, d, D/2, 95, aoa, view);
  
//  flow = new BDIM(n,n,1.5,body);           // solve for flow using BDIM
  flow = new BDIM(n,n,0,body,0.01,true);   // QUICK with adaptive dt
  flood = new FloodPlot(view);
  flood.range = new Scale(-1.,1);
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




