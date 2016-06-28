/*************************
UnsteadyLiftControl test;
SaveData dat;
float maxT = 10;
float numframes = 1000;
float frame = 0;
String datapath = "";
BufferedReader reader;
float[] yd = {0.5, 0.25, -0.25, 0.5};

void setup() {
  int Re = 6000;
  int resolution = 32, xLengths=7, yLengths=7, xStart = 3, zoom = 2;

  test = new UnsteadyLiftControl(resolution, xLengths, yLengths, xStart, zoom, Re, true);

  mm = new MovieMaker(this, width, height, datapath+"control.mov", 30);
  dat = new SaveData(datapath+"control.txt", test.foil.coords, resolution, xLengths, yLengths, int(zoom*10));
  
  maxT = maxT*resolution;
}
void draw() {
  int i = floor(test.t/maxT*yd.length);
  if (i>=yd.length){i = yd.length-1;}
  test.setyd(yd[i]);
  test.update();
  test.display();
  dat.addData(test.t, test.foil.pressForce(test.flow.p), test.foil, test.flow.p);

  if (frame<test.t*numframes/maxT) {
    frame = frame+1;
    mm.addFrame();
  }

  if (test.t>=maxT) {
    dat.finish();
    mm.addFrame();
    mm.finish();
    exit();
  }
}
 ***********************/

class UnsteadyLiftControl {
  final int n, m;
  float dt = 0, t = 0, dto = 0;
  float a = 5*PI/180, w = 2*PI;
  float yd = 0;
  
  float[] Xhat = {0, 0, 0, 0};
  float[] A0 = {-0.3414, 1, 0, 0}, A1 = {-0.01582, 0, 0, 0}, A2 = {PI, 0, 0, 0}, A3 = {PI/2, 0, 1, 0};
  float[] B = {0, 0, 0, 1}, Ct = {0.09846, 0.00757, 0.5177*PI, PI/4+0.5177*PI/2};
  float D = PI/16, alph = 4.2640;
  float[] Kt = {0.4049, 0.0314, 7.1122, 7.8715}, L = {2.4923, 0.1078, 17.449, 16.8507};
  int nX = 4;
  
  float th = 0, thdot = 0, thddot= 0;
  float lift=0;
  int resolution, zoom;

  NACA foil; 
  BDIM flow; 
  FloodPlot flood, flood2; 
  Window window;

  UnsteadyLiftControl( int resolution, int xLengths, int yLengths, int xStart, int zoom, int Re, boolean QUICK) {
    this.resolution = resolution;
    this.zoom = zoom;
    n = xLengths*resolution+2;
    m = yLengths*resolution+2;
    //thdot = a*w;

    int w = int(zoom*(n-2)), h = int(zoom*(m-2));
    size(w, h);
    window = new Window(n, m);

    foil = new NACA(xStart*resolution, m/2, resolution, .12, .25, window);
    
    foil.rotate(0);
    foil.translate(xLengths, -yLengths);
    foil.translate(0,0);
    flow = new BDIM(n, m, dt, foil, (float)resolution/Re, QUICK);

    flood = new FloodPlot(window);
    flood.range = new Scale(-1, 1);
    flood.setLegend("vorticity");
    flood.setColorMode(1); 
    foil.setColor(#CCCCCC);

    flood2 = new FloodPlot(window);
    flood.range = new Scale(-0.5, 0.5);
    flood2.setLegend("pressure");
  }
  void setSys(float[] A1, float[] A2, float[] A3, float[] A4, float[] B, float[] Ct, float D, int nX) {
    this.Xhat = new float[nX];
    this.nX = nX;
    this.A1 = A1;
    this.A2 = A2;
    this.A3 = A3;

    this.B = B;
    this.Ct = Ct;
    this.D = D;
  }
  void setGains(float[] Kt, float[] L, int nX) {
    this.L = L;
    this.Kt = Kt;
  }

  float controller(float[] Xhat, float yd) {
    //Takes Xhat, computes Thetaddot
    return -Kt[0]*Xhat[0]-Kt[1]*Xhat[1]-Kt[2]*Xhat[2]-Kt[3]*Xhat[3]+ alph*yd;
    //return -w*w*a*sin(t/resolution*w);
  }
  float[] estimator(float y, float u, float[] Xhat_in) {
      float Xhatdot;
      float[] Xhatnew = new float[nX];
      float yhat = Ct[0]*Xhat_in[0] + Ct[1]*Xhat_in[1] + Ct[2]*Xhat_in[2] + Ct[3]*Xhat_in[3] + D*u;
      for(int i=0; i<nX; i++){
        Xhatdot = A0[i]*Xhat_in[0]+A1[i]*Xhat_in[1]+A2[i]*Xhat_in[2]+A3[i]*Xhat_in[3]+B[i]*u+L[i]*y-L[i]*yhat;
        Xhatnew[i] = Xhat_in[i]+dt/resolution*Xhatdot;
      }
      return Xhatnew;
  }
  void setyd(float yd){
    this.yd = yd;
  }

  void update() {
    dto = dt;
    if (flow.QUICK) {
      dt = flow.checkCFL();
      flow.dt = dt;
    }
    float dtr = dt/resolution;
    
    PVector pforce = foil.pressForce(flow.p);
    lift = pforce.y;
 
    // Do first Euler step
    float thddot0 = controller(Xhat,yd);
    float dth0 = thdot*dtr;
    float dthdot0 = thddot0*dtr;
    
    //Integrate
    float thdot1 = thdot+dthdot0;
    float[] Xhat1 = estimator(lift,thddot0, Xhat);

    //Do Second Euler Step
    float thddot1 = controller(Xhat1,yd);
    float dth1 = thdot1*dtr;
    float dthdot1 = thddot1*dtr;
    
    //Integrate
    th = th + 0.5*(dth0+dth1);
    thdot = thdot + 0.5*(dthdot0+dthdot1);
    thddot = 0.5*(thddot0+thddot1);
    Xhat = estimator(lift,thddot, Xhat);
    
    foil.rotate(-foil.phi+th);
    println("Theta: "+th*180/PI + "  Thetadot: "+thdot*180/PI + "  Thetaddot: "+thddot*180/PI + "  dt:" + dt/resolution);
    println("Xhat: "+Xhat[0]*180/PI+"  "+Xhat[1]*180/PI + "  "+Xhat[2]*180/PI + "  "+Xhat[3]*180/PI);
    
    if (mousePressed==true){
    flow.u.x.a[mouseX/zoom][mouseY/zoom-2] += 1;
    flow.u.x.a[mouseX/zoom][mouseY/zoom-1] += 2;
    flow.u.x.a[mouseX/zoom][mouseY/zoom] += 2;
    flow.u.x.a[mouseX/zoom][mouseY/zoom+1] += 2;
    flow.u.x.a[mouseX/zoom][mouseY/zoom+2] += 1;
    }
     
    flow.update(foil);
    flow.update2(foil);
    t += dt;
  }
  void display() {
    flood.display(flow.u.curl());
    foil.display();
    foil.displayVector(foil.pressForce(flow.p));
    
    PFont font = loadFont("Dialog.bold-14.vlw");
      int x0 = window.x0, x1 = window.x0+window.dx;
      int y0 = window.y0, y1 = window.y0+window.dy;
      int spacing = 20;
      textFont(font);
      textAlign(CENTER,BASELINE);
      fill(#000000);
      text("t = "+ nfs(t/resolution,2,2),0.5*(x0+x1),y1-spacing*2);
      textAlign(RIGHT,BASELINE);
      text("Theta: "+ nfs(th*180/PI,2,2),x1-spacing,y1-2*spacing);
      text("Liftset: "+ nfs(yd,2,2),x1-spacing,y1-spacing);
  }
}