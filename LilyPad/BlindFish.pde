/*************************
Audrey's Blind Cave Fish Test Class
  Example test case in which a cylinder passes by a foil

Example code:

SaveData dat;
BlindFish test;
int resolution = 64, xLengths=5, yLengths=3, zoom = 2;    // choose the number of grid points per chord, the size of the domain in chord units and the zoom of the display

void settings(){
    size(zoom*xLengths*resolution, zoom*yLengths*resolution);
}
void setup(){
  float xStart = 1, yDist = 0.06;        // choose the initial horizontal position of the cylinder and vertical separation between the foil and the cylinder
  test = new BlindFish(resolution, xLengths, yLengths, xStart , yDist, zoom);
  dat = new SaveData("saved/pressure.txt",test.body.bodyList.get(0).coords,resolution,xLengths,yLengths,zoom);    // initialize the output data file with header information
}
void draw(){
  if(test.t<2){  // run simulation until t<Time
    test.update();
    test.display();
    dat.addData(test.t, test.flow.p);    // add the pressure arounf the foil to the data file
    saveFrame("saved/frame-####.png");   // save images. To make a movie use Tools > Movie Maker
  }else{  // close and save everything when t>Time
    dat.finish();
    exit();
  }
}

void keyPressed(){   // close and save everything when the space bar is pressed
    dat.finish();
    exit();
}
***********************/

class BlindFish{
  final int n,m, resolution, NT=2;  //nXm domain with resolution grid points per chord. displays and saves every NT computational time step
  float dt = 0, t, t0, Re=50000, cDiameter = 0.5; //choose time step if using semi-lagrangian, Reynolds number if using QUICK, and cylinder diameter in chord units
  boolean QUICK = true, order2 = true; // choose whether to use QUICK and second order time integration
  BodyUnion body; BDIM flow; FloodPlot flood, flood2; Window window, window2;
  
  BlindFish( int resolution, int xLengths, int yLengths, float xStart , float yDist, float zoom){
    n = xLengths*resolution;
    m = yLengths*resolution;
    this.resolution = resolution;
    float xFoil = 1.0/3.0;     // position of the foil in % of the domain size
    float yFoil = 1.0/2.0;
    float yStart = yLengths*yFoil-yDist-0.06-0.5*cDiameter;   // position of the cylinder at the beginning of the simulation
    
    t0 = xStart-xFoil*xLengths;    // choose initial time such that the cylinder is passing the foil at time=0
    t=t0;

    smooth();
//    window = new Window(n,m);      // display the entire domain
    window = new Window(n/6,m/5,n/2,m/2);
    window2 = new Window(n/6,m/5,n/2,m/2);    // zoom on the foil

    body = new BodyUnion( new NACA(xFoil*n,yFoil*m,resolution,0.12,window), new CircleBody(xStart*resolution,yStart*resolution,cDiameter*resolution,window));   // create foil and cylinder

    flow = new BDIM(n,m,dt,body,(float) resolution/Re,QUICK);

    flood = new FloodPlot(window);
    flood.range = new Scale(-0.75,0.75);
    flood.setLegend("vorticity");

    flood2 = new FloodPlot(window2);
    flood2.range = new Scale(-0.5,0.5);
    flood2.setLegend("pressure");
  }
  
  void update(){
    for ( int i=0 ; i<NT ; i++ ) {
    if (QUICK){dt = flow.dt;}
     body.bodyList.get(1).translate(dt,0);    // translate the cylinder of dt*velocity. here the cylinder moves one chord length per unit time
     flow.update(body);
     if (order2) {flow.update2(body);}
    print("t="+nfs(t,2,2)+";  ");
    t += dt/resolution;
    }
  }
  
  void display(){
//    flood.display(flow.u.curl());
//    body.display();
//    flood.displayTime(t);
    flood2.display(flow.p);
    body.display(window2);
    flood2.displayTime(t);
  }
}