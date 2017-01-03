/*********************************************************
Simple model of a swimming plesiosaur
 
 The foils both use simple harmonic pitch and heave 
 flapping. You can set the horizontal spacing and phase 
 difference between the foils. 
 
 Note that the example code needs increased domain and resolution 
 should use QUICK convection to obtain highly accurate results. 

Example code:

AncientSwimmer plesiosaur;
BDIM flow;
FloodPlot plot;
PrintWriter output;
int n=(int)pow(2,8);      // number of grid points
float L = n/8., St = 0.4; // chord length, Strouhal number
float t = 0;              // time
 
void setup(){
  size(1000,500);                                     // display window size
  Window view = new Window(n,n/2);                    // mapping from grid to display
  plesiosaur = new AncientSwimmer(1.25*L,n/4,L,3*L,   // define the geometry...
                                  1.75*PI,St,view);   //    and motion
  flow = new BDIM(n,n/2,1.0,plesiosaur);              // define fluid
  plot = new FloodPlot( view );                       // define plot...
  plot.setLegend("Vorticity",-0.5,0.5);               //    and legend
  output = createWriter("plesiosaur/out.csv");        // open output file
}

void draw(){
  t += flow.dt;                                       // update the time
  plesiosaur.update(t,flow.dt);                       // update the geometry
  flow.update(plesiosaur); flow.update2();            // 2-step fluid update
  plot.display(flow.u.curl());                        // display the vorticity
  plesiosaur.display();                               // display the geometry
  
  PVector[] forces = plesiosaur.pressForces(flow.p);  // pressure force on both bodies
  float ts = St*t/(2.*L);                             // time coefficient
  float front = 2.*forces[0].x/L;                     // thrust coefficient on front
  float back = 2.*forces[1].x/L;                      // thrust coefficient on back
  output.println(""+ts+","+front+","+back);           // print to file

  if(ts>=4){                                          // finish after 4 cycles
    output.close();
    exit();
  }
}
*******************************************************/

class AncientSwimmer extends BodyUnion{
  float x0,y0,L,s,lead,St,pamp;
  
  AncientSwimmer( float x0, float y0, float L, float s, float lead, float St, Window view){
//  make geometry
    super(new NACA(x0,y0,L,0.16,view),        // front foil
          new NACA(x0+s,y0,L,0.16,view));     // back foil

// save parameters
    this.L = L;                              // Foil coord
    this.x0 = x0; this.y0 = y0;              // Starting position of front foil
    this.s = s; this.lead = lead;            // Spacing and phase lag
    this.St = St;                            // Strouhal number of motion

// set pitch amplitude to get 10 degree AOA
    pamp = atan(PI*St)-PI/18.;               
    
// set initial state
    bodyList.get(0).follow(kinematics(0,0,0),new PVector());
    bodyList.get(1).follow(kinematics(s,lead,0),new PVector());

// set color
    bodyColor=color(255);
  }

// update the position of the two foils
  void update(float t, float dt){
    bodyList.get(0).follow(kinematics(0,0,t),dkinematics(0,t,dt));
    bodyList.get(1).follow(kinematics(s,lead,t),dkinematics(lead,t,dt));
  }
  
// define the foil motion
  PVector kinematics(float s, float lead, float t){    
    float phase = PI*St*t/L+lead;          // phase
    return new PVector(x0+s,               // x position
                       y0-L*sin(phase),    // y position
                       pamp*cos(phase));   // pitch position
  }
  PVector dkinematics(float lead, float t, float dt){
    float phase = PI*St*t/L+lead;          // phase
    return new PVector(0,                  // dx
                       -cos(phase)*PI*St*dt,   // dy
                       -pamp*sin(phase)*PI*St/L*dt); // dphi
  }
  
// get pressure force of both foils
  PVector[] pressForces(Field p){
    PVector f0 = bodyList.get(0).pressForce(p);
    PVector f1 = bodyList.get(1).pressForce(p);
    return new PVector[]{f0,f1};
  }
}