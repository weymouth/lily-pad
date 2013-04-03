/***************
 AmandaTest2 Class 
 
 Read in coordinate files and force motion on foil  (ascii files generated in MATLAB)
 Measure output pressure and velocity fields.
 Possible approximate moment calcuation.  (This will be used for motion optimization step to come)
 
 Example Code:
 
 //import processing.video.*;
MovieMaker mm;
SaveData dat, Power;
AmandaTest2 test;
AmandaData pres, OrthCoordX, OrthCoordY, seg, cen, nx, ny, dtime, mom;
AmandaData pField1, pField2, pField3, pField4, pField5, pField6, pField7, pField8, pField9, pField10;
AmandaData uField1, uField2, uField3, uField4, uField5, uField6, uField7, uField8, uField9, uField10;
AmandaData vField1, vField2, vField3, vField4, vField5, vField6, vField7, vField8, vField9, vField10;

void setup() {
  int resolution=32, xLengths=7, yLengths=5, xStart=1, yStart=3, zoom=3;
  float mr=0.157; 
  String r = "20";
  String folderpath = "/Users/AmandaJean/Desktop/Iterative Solver/"+r+"/";
  String inputfile = r+"-dataCoords.txt";
 

  test = new AmandaTest2(resolution, xLengths, yLengths, xStart, yStart, zoom, mr, folderpath+inputfile);
  mm = new MovieMaker(this, width, height, folderpath+r+"foil.mov", 30);   // initialize the movie
  dat = new SaveData(folderpath+r+"data.txt", test.foil.coords, resolution, xLengths, yLengths, zoom);
  Power = new SaveData(folderpath+r+"Power.txt",test.foil.coords,resolution,xLengths,yLengths,zoom);
 
  //For MATLAB sensor location optimization
  pres = new AmandaData(folderpath+r+"PressForce.txt", test.foil.coords, resolution, xLengths, yLengths);  
  OrthCoordX = new AmandaData(folderpath+r+"OrthCoordX.txt", test.foil.coords, resolution, xLengths, yLengths);
  OrthCoordY = new AmandaData(folderpath+r+"OrthCoordY.txt", test.foil.coords, resolution, xLengths, yLengths);
  seg = new AmandaData(folderpath+r+"SegmentLength.txt", test.foil.coords, resolution, xLengths, yLengths);
  cen = new AmandaData(folderpath+r+"CentroidCoord.txt", test.foil.coords, resolution, xLengths, yLengths);
  nx = new AmandaData(folderpath+r+"NormalX.txt", test.foil.coords, resolution, xLengths, yLengths);
  ny = new AmandaData(folderpath+r+"NormalY.txt", test.foil.coords, resolution, xLengths, yLengths);
  dtime = new AmandaData(folderpath+r+"DT.txt", test.foil.coords, resolution, xLengths, yLengths);
  mom = new AmandaData(folderpath+r+"FluidMoment.txt", test.foil.coords, resolution, xLengths, yLengths);
  
  //For Database
  pField1= new AmandaData(folderpath+r+"pField1.txt", test.foil.coords, resolution, xLengths, yLengths);
  pField2= new AmandaData(folderpath+r+"pField2.txt", test.foil.coords, resolution, xLengths, yLengths);
  pField3= new AmandaData(folderpath+r+"pField3.txt", test.foil.coords, resolution, xLengths, yLengths);
  pField4= new AmandaData(folderpath+r+"pField4.txt", test.foil.coords, resolution, xLengths, yLengths);
  pField5= new AmandaData(folderpath+r+"pField5.txt", test.foil.coords, resolution, xLengths, yLengths);
  pField6= new AmandaData(folderpath+r+"pField6.txt", test.foil.coords, resolution, xLengths, yLengths);
  pField7= new AmandaData(folderpath+r+"pField7.txt", test.foil.coords, resolution, xLengths, yLengths);
  pField8= new AmandaData(folderpath+r+"pField8.txt", test.foil.coords, resolution, xLengths, yLengths);
  pField9= new AmandaData(folderpath+r+"pField9.txt", test.foil.coords, resolution, xLengths, yLengths);
  pField10= new AmandaData(folderpath+r+"pField10.txt", test.foil.coords, resolution, xLengths, yLengths);
  
  uField1 = new AmandaData(folderpath+r+"uField1.txt", test.foil.coords, resolution, xLengths, yLengths);
  uField2= new AmandaData(folderpath+r+"uField2.txt", test.foil.coords, resolution, xLengths, yLengths);
  uField3 = new AmandaData(folderpath+r+"uField3.txt", test.foil.coords, resolution, xLengths, yLengths);
  uField4 = new AmandaData(folderpath+r+"uField4.txt", test.foil.coords, resolution, xLengths, yLengths);
  uField5 = new AmandaData(folderpath+r+"uField5.txt", test.foil.coords, resolution, xLengths, yLengths);
  uField6 = new AmandaData(folderpath+r+"uField6.txt", test.foil.coords, resolution, xLengths, yLengths);
  uField7 = new AmandaData(folderpath+r+"uField7.txt", test.foil.coords, resolution, xLengths, yLengths);
  uField8 = new AmandaData(folderpath+r+"uField8.txt", test.foil.coords, resolution, xLengths, yLengths);
  uField9 = new AmandaData(folderpath+r+"uField9.txt", test.foil.coords, resolution, xLengths, yLengths);
  uField10 = new AmandaData(folderpath+r+"uField10.txt", test.foil.coords, resolution, xLengths, yLengths);
  
  vField1 = new AmandaData(folderpath+r+"vField1.txt", test.foil.coords, resolution, xLengths, yLengths);
  vField2= new AmandaData(folderpath+r+"vField2.txt", test.foil.coords, resolution, xLengths, yLengths);
  vField3 = new AmandaData(folderpath+r+"vField3.txt", test.foil.coords, resolution, xLengths, yLengths);
  vField4 = new AmandaData(folderpath+r+"vField4.txt", test.foil.coords, resolution, xLengths, yLengths);
  vField5 = new AmandaData(folderpath+r+"vField5.txt", test.foil.coords, resolution, xLengths, yLengths);
  vField6 = new AmandaData(folderpath+r+"vField6.txt", test.foil.coords, resolution, xLengths, yLengths);
  vField7 = new AmandaData(folderpath+r+"vField7.txt", test.foil.coords, resolution, xLengths, yLengths);
  vField8 = new AmandaData(folderpath+r+"vField8.txt", test.foil.coords, resolution, xLengths, yLengths);
  vField9 = new AmandaData(folderpath+r+"vField9.txt", test.foil.coords, resolution, xLengths, yLengths);
  vField10 = new AmandaData(folderpath+r+"vField10.txt", test.foil.coords, resolution, xLengths, yLengths);
}

void draw() {

   
  if (test.k0>=2){
    
  pres.addFieldBody(test.flow.p, test.foil);  //Need for RS and GA
  OrthCoordX.addVec(test.Ocenx);
  OrthCoordY.addVec(test.Oceny);
  cen.addVector(test.foil.xc);
  seg.addVec(test.Ol);
  nx.addVec(test.Nx);
  ny.addVec(test.Ny);
  dtime.saveParam(test.dt);  
  mom.saveParam(test.fMoment);
  
  if (test.k0==2){
    pField1.addField(test.T, test.flow.p);  
    uField1.addField(test.T, test.flow.u.x);
    vField1.addField(test.T, test.flow.u.y); 
  }
    if (test.k0==3){
    pField2.addField(test.T, test.flow.p); 
    uField2.addField(test.T, test.flow.u.x);
    vField2.addField(test.T, test.flow.u.y);  
  }
    if (test.k0==4){
    pField3.addField(test.T, test.flow.p);
    uField3.addField(test.T, test.flow.u.x);
    vField3.addField(test.T, test.flow.u.y);
  }
    if (test.k0==5){
    pField4.addField(test.T, test.flow.p); 
    uField4.addField(test.T, test.flow.u.x); 
    vField4.addField(test.T, test.flow.u.y);   
  }
    if (test.k0==6){
    pField5.addField(test.T, test.flow.p);
    uField5.addField(test.T, test.flow.u.x);
    vField5.addField(test.T, test.flow.u.y); 
  }
    if (test.k0==7){
    pField6.addField(test.T, test.flow.p);
    uField6.addField(test.T, test.flow.u.x);
    vField6.addField(test.T, test.flow.u.y); 
  }
    if (test.k0==8){
    pField7.addField(test.T, test.flow.p);
    uField7.addField(test.T, test.flow.u.x);
    vField7.addField(test.T, test.flow.u.y); 
  }
    if (test.k0==9){
    pField8.addField(test.T, test.flow.p);
    uField8.addField(test.T, test.flow.u.x);
    vField8.addField(test.T, test.flow.u.y); 
  }
    if (test.k0==10){
    pField9.addField(test.T, test.flow.p);
    uField9.addField(test.T, test.flow.u.x);
    vField9.addField(test.T, test.flow.u.y); 
  }
    if (test.k0==11){
    pField10.addField(test.T, test.flow.p);
    uField10.addField(test.T, test.flow.u.x);
    vField10.addField(test.T, test.flow.u.y); 
  }


  if (test.k0<test.k) { 
    Power.saveParam("Avg Pow Avail",test.AvailCyc);
    Power.saveParam("Avg Pow Req",test.ReqCyc);
    dat.saveParam("Avg Efficiency", test.eff);
    dat.saveParam("Cycle Averaged Power", test.PowerCycle);
    dat.saveParam("Potential Power", test.PotPow);
    dat.saveParam("Heave Amp", test.HeaveAmp);
    dat.saveParam("Inertia",test.inertia);
  }
  }
  mm.addFrame();   
  test.update();
  test.display();
  test.incrementTime();
}


void keyPressed() {  //close and save everything when spacebar is pressed
  dat.finish();
  Power.finish();
  pres.finish();
  OrthCoordX.finish();
  OrthCoordY.finish();
  seg.finish();
  cen.finish();
  nx.finish();
  ny.finish();
  dtime.finish();
  mom.finish();
  
  pField1.finish();
  pField2.finish();
  pField3.finish();
  pField4.finish();
  pField5.finish();
  pField6.finish();
  pField7.finish();
  pField8.finish();
  pField9.finish();
  pField10.finish();
  
  uField1.finish();
  uField2.finish();
  uField3.finish();
  uField4.finish();
  uField5.finish();
  uField6.finish();
  uField7.finish();
  uField8.finish();
  uField9.finish();
  uField10.finish();
    
  vField1.finish();
  vField2.finish();
  vField3.finish();
  vField4.finish();
  vField5.finish();
  vField6.finish();
  vField7.finish();
  vField8.finish();
  vField9.finish();
  vField10.finish();  
  
  mm.finish();
  exit();
}
 
 ************/

class AmandaTest2 {
  final int n, m, resolution, yStart, xStart;
  int i=0, k=0, k0=0; 
  float aoa, theta, ypos;
  PVector forceP = new PVector(0, 0);
  float[] Ocenx = new float[0];
  float[] Oceny = new float[0];
  float[] Ol = new float[0];
  float[] Nx = new float[0];
  float[] Ny = new float[0];
  int[] c = new int[8];
  float[] Heave = new float[0];
  float[] Hold = new float[0];
  float[] CycleHeave = new float[0];
  float pitchAmp = 12*PI/180, Psi = PI/2, freq=0.2, DT=0;
  float t=0, T=0, omega, dt0=1, dt=0, mr, FoilArea, fMoment, aMoment, inertia, heaveVel=0, angVel, PowAvail, PowReq, Power; 
  float AvailCyc, ReqCyc, AvailSum, ReqSum, beta, pitch, angAccel, StepEff, sumMomError, momError, MomError, AvgMomError;
  float Attack, AttackDeg, PCyc, HeaveAmp, phi0, time0=0, PotPow, eff, PowerCycle, time, rho=1, pitchVel, pitchDeg;
  boolean QUICK = true, order2 = true;
  NACA foil;
  BDIM flow;
  FloodPlot flood, flood2;
  Window window;
  ReadData reader;

  AmandaTest2(int resolution, int xLengths, int yLengths, int xStart, int yStart, float zoom, float mr, String filepath) {

    n=xLengths*resolution+2;
    m=yLengths*resolution+2;
    int w = int(zoom*(n-2)), h=int(zoom*(m-2));
    size(w, h);
    window = new Window(n, m);

    reader = new ReadData(filepath);

    foil = new NACA(xStart*resolution, m/2, resolution, 0.18, window);  // 0.18=thickness
    foil.xfree = false; // restrain freedom in x direction
    foil.mass = mr*foil.area;
    
    foil.rotate(0);
    foil.translate(0, 0);

    this.mr=mr;
    this.resolution = resolution;
    this.xStart = xStart;
    this.yStart = yStart;

    flow = new BDIM(n, m, dt, foil, 0.01, QUICK);

    flood = new FloodPlot(window);
    flood.range = new Scale(-1, 1);
    flood.setLegend("vorticity");

    flood2 = new FloodPlot(window);
    flood.range = new Scale(-0.5, 0.5);  //was -0.5 to 0.5
    flood2.setLegend("pressure");
  }

  void update() {
    DT=dt/resolution;
    phi0=foil.phi;      // saves previous angle of attack in radians 
    i=i+1;              //adds up iteration for every time step  
    k0=k;
    
    aoa=reader.interpolate(T, 0);
    theta=reader.interpolate(T, 1);
    ypos=reader.interpolate(T, 2)*resolution;
    foil.rotate(-theta-foil.phi);        //theta positive should go down 
    foil.translate(0, yStart*resolution+ypos-foil.xc.y);

    forceP = foil.pressForce(flow.p); 
    fMoment = foil.pressMoment(flow.p);  //with this new fluid moment calculation no seperate cP calculation is needed
    pitchDeg=foil.phi*180/PI;

    Ocenx = foil.orthCenX();   //stores o.cen.x
    Oceny = foil.orthCenY();   //stores o.cen.y
    Ol = foil.ol();   //stores line segment lengths o.l
    Nx = foil.nx();
    Ny = foil.ny();

//APPROX MOMENT CALCULATION
//    int[] c = {34, 64, 80, 95, 106, 121, 137, 167};  //input chosen sensor locations 
//    aMoment = foil.approxMoment(flow.p, c);
//    momError = fMoment-aMoment;
//    if (fMoment==0) {
//      MomError = 0;
//    }
//    else {
//      MomError = momError/fMoment;
//    }
//    sumMomError += MomError;
    
    
    omega = TWO_PI*freq/resolution;
    pitch = pitchAmp*sin(omega*t+Psi);  // positive
    angVel = pitchAmp*omega*resolution*cos(omega*t+Psi);   //positive
    angAccel= -pitchAmp*omega*resolution*omega*resolution*sin(omega*t+Psi);   //negative
    
    inertia = foil.I0;
    heaveVel = foil.dxc.y/dt;     //here both dy and dt would need to be divided by resolution so they would be canceled out 
    beta = atan(heaveVel/1);
    Attack = -foil.phi-beta;       //this doesnt matter in calculations 
    AttackDeg = Attack*180/PI;
   

    PowAvail = forceP.y*heaveVel*DT; 
    AvailSum += PowAvail;
    PowReq = ((inertia*angAccel)+fMoment)*angVel*DT;   
    ReqSum += PowReq;
    Power = PowAvail+PowReq;
    PCyc += Power;
    
    
    if(i>0){         //this stores all heave values for HeaveAmp calculation and if you want to output heave values
    Hold = Heave;
    Heave = new float[i];
   for(int j=0; j<i-1; j++){ 
      Heave[j] = Hold[j];
    }
    Heave[i-1]=foil.xc.y; 
    }
    
    StepEff=Power/(foil.dxc.y/resolution);    //this calculates the efficiency of movement for each time step 
   
    if (phi0<0 && phi0*foil.phi<0) {         //when the angle of attack changes from negative to positive
      k0=k;
      k=k+1;
      time=(T-time0); 
       
      PowerCycle = PCyc/time;  
      AvailCyc = AvailSum/time;  
      ReqCyc = ReqSum/time;
      
      HeaveAmp=(max(Heave)-min(Heave))/(2*resolution);   //half of sweep over cycle
      PotPow=rho*pow(flow.u.x.a[1][1], 3)*HeaveAmp;  
      eff=PowerCycle/PotPow; 
      
//      AvgMomError=sumMomError/i;
      CycleHeave = new float[0];
      CycleHeave = Heave; 
      i=0;  
      Heave = new float[0];    
      time0=T;
      PCyc=0;
      AvailSum=0;
      ReqSum=0;
//      sumMomError=0;
    }  
    
    foil.update();
    foil.unsteady = true;
    flow.update(foil);
    flow.update2(foil);
  }
  
  void incrementTime(){
    dt = flow.dt;
    t += dt;
    T = t/resolution;
  }


  void display() {
    flood.display(flow.u.vorticity());
    foil.display();
    flood.displayTime(T);
    //    flood2.displayValue(Power, "Power", 0.15);
    //    flood2.displayValue(StepEff, "Efficiency", 0.8);
    //flood2.display(flow.p);
    //foil.display();
    //flood2.displayTime(t);
  }
}

