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
//  flow = new BDIM(n,n,0.,body,L/200,true);  // BDIM+QUICK
  flood = new FloodPlot(view);
  flood.setLegend("vorticity",-.5,.5);
}
void draw(){
  body.update();
  flow.update(body); flow.update2();
  flood.display(flow.u.vorticity());
  body.display();
}
void mousePressed(){body.mousePressed();}
void mouseReleased(){body.mouseReleased();}