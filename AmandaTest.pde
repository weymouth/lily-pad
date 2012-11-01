/**********************
AmandaTest Class 

Goal: NACA foil with forced sinusoidal pitch motion. Heave translation resulting from pressure force on foil for each time step. 
Swap which draw command is commented out (and uncomment other lines) if you want recording.

Example code:

//import processing.video.*;
//boolean recording=true;
SaveData dat;
AmandaTest test;
//int Time =100;
//MovieMaker mm; 
void setup(){
  int resolution=32, xLengths=4, yLengths=3, xStart=1, zoom=3;  // choose the number of grid points per chord, the size of the domain in chord units and the zoom of the display
  float mr=5, pitchAmp=PI/8.;
  test = new AmandaTest(resolution, xLengths, yLengths, xStart, zoom, pitchAmp, mr);
  //mm = new MovieMaker(this, width, height, "foil_Amanda.mov", 30);   // initialize the movie
  dat = new SaveData("PressForce.txt", test.foil.coords, resolution, xLengths, yLengths, zoom);
}

void draw(){
  dat.addText("Heave Motion (per time step)");  
  dat.addDataSimple(test.t, test.foil.dxc2, test.foil, test.flow.p);  // adds heave values: t heave.x heave.y
  dat.addText("Pressure Force");  
  dat.addDataSimple(test.t, test.forceP, test.foil, test.flow.p);  //add Pressure force x and y values 
  test.update();
  test.display();
}

//void draw(){
//  if(test.t<Time){  // run simulation until t<Time
//  test.update();
//  if(test.t>-2*Time){   // only display and save once t>-2*Time
//  test.display();
//    if(recording){      
//    mm.addFrame();      // add frame to the movie
//    dat.addData(test.t, test.flow.p);    // add the pressure around the foil to the data file
//      }
//    }
//  }
//  if(test.t>=Time){  // close and save everything when t>Time
//    mm.finish();
//    dat.finish();
//    exit();
//}
//}

void keyPressed(){  //close and save everything when spacebar is pressed
  //mm.finish();
  dat.finish();
  exit();
}
******************************/

class AmandaTest{
  final int n,m;
  PVector forceP = new PVector(0,0);
  float t=0, pitchAmp, omega=0.5, dt0=1, dt=1, mr, r, FoilArea; 
  boolean QUICK = true, order2 = true;
  NACA foil;
  BDIM flow;
  FloodPlot flood, flood2;
  Window window;
  
  AmandaTest(int resolution, int xLengths, int yLengths, int xStart, float zoom, float pitchAmp, float mr){
    n=xLengths*resolution+2;
    m=yLengths*resolution+2;
    int w = int(zoom*(n-2)), h=int(zoom*(m-2));
    size(w,h);
    window = new Window(n,m);

    //NACA0018 foil with chord lengths equal to resolution positioned in middle of window
    foil = new NACA(xStart*resolution, m/2,resolution,0.18,window); 
    Float FoilArea = 0.18*resolution*0.685084; //thickness * chord length * 0.685084
    
    this.pitchAmp = pitchAmp; 
    this.mr=mr;
    omega = TWO_PI*omega/resolution;  //frequency pi/2
    
    flow = new BDIM(n,m,0,foil,0.01,QUICK);
    
    flood=new FloodPlot(window);
    flood.range = new Scale(-1,1);
    flood.setLegend("vorticity");
    
    flood2 = new FloodPlot(window);
    flood.range = new Scale(-0.5,0.5);
    flood2.setLegend("pressure");
  }
  
  void update(){
      // save previous time step duration
    dt0 = dt;
    // calculate next time step duration
    if (QUICK) {
      dt = flow.checkCFL();  
      flow.dt = dt;
    }
    

    forceP = foil.pressForce(flow.p); 
    //angular velocity minus current pitch location minus desired pitch position
    float pitch = atan2(pitchAmp*omega*sin(omega*t),1.) - foil.phi - pitchAmp*sin(omega*t);  
    foil.react(forceP,dt0,dt,mr);     
    foil.rotate(pitch);     //input angular velocity value
   
    foil.update();
    flow.update(foil);
    if (order2) {
      flow.update2();
    }
    t +=flow.dt;
  }
  
  void display(){
    flood.display(flow.u.vorticity());
    foil.display();
    flood.displayTime(t);
    //flood2.display(flow.p);
    //foil.display();
    //flood2.displayTime(t);
  }
}
