/**********************************
 CirculationFinder class
 
 Finds and displays circulation of vortices in the wake.
 Algorithm: 
 1) Finds local peaks in vorticity field, labelling them as circular cores
 2a) Grows the cores until the vorticity at the border dies out
 2b) If cores of the same sign interefere with each other, core with less circulation is removed (as defined a rough circulation estimate)
 3) Finds final circulation by adding the vorticity within the core; however, only adds the vorticity of a single sign
 example code:
 
 BDIM flow;
 Body body;
 FloodPlot flood;
 CirculationFinder cf;
 
 void setup(){
   int n=(int)pow(2,7);
   float d = n/12;
   size(800,400);
   Window view = new Window(n,n/2);
 
   body = new CircleBody(n/4,n/4,d,view);
   flow = new BDIM(n,n/2,1.5,body);
 
   cf = new CirculationFinder(flow,body,view);
   cf.setAnnotate(true,1.0/d);
 
   flood = new FloodPlot(view);
   flood.setLegend("vorticity",-0.5,0.5);
 }
 void draw(){
   flow.update();flow.update2();
   cf.update();
 
   flood.display(flow.u.curl());
   body.display();
   cf.display();
 }
 ***********************************/

class CirculationFinder {
  ArrayList<VortexCore> cores = new ArrayList(1024);
  ArrayList<VortexCore> toremove = new ArrayList(1024);
  Window window;
  Field vorticity;
  float circres=8, r_init=1, dr=2, r_max;
  BDIM flow;
  Body body;

  float Qmin, wmin, bmin, diatol, annoscale = 1;
  boolean dispG=true;

  CirculationFinder(BDIM flow, Body body, Window window) {
    this.flow = flow;
    this.body = body;
    this.window = window;
    setParams(0.01, 0.01, 5, 0.05);
    r_max = 0.25*window.dy;
  }
  void setParams(float Qmin, float wmin, float bmin, float diatol) {
    this.Qmin = Qmin; //Minimum Qcriterion to be considered a core
    this.wmin = wmin; //Minimum vorticity in center to be considered a core
    this.bmin = bmin; //Minimum distance from body
    this.diatol = diatol; //Tolerance on vorticity reaching asymtote as the core diameter increases, as a fraction of center vorticity
  }
  void setAnnotate(boolean dispG, float s) {
    this.dispG=dispG; //Display circulation value
    this.annoscale=s;  //Display scaling of circulation values
  }
  void update() {
    //Updates the vortex cores

    // +++++++++++++++ Step 1 - Finds local maxima in vorticity that also satisfy requirements of minimum vorticity, Qcriterion, and distance from body
    vorticity = flow.u.curl();
    float[][] w = vorticity.a;
    cores.clear();
    for ( int i=1 ; i<flow.n-1 ; i++ ) {
      for ( int j=1 ; j<flow.m-1 ; j++ ) {
        //Find local peaks
        if ((w[i+1][j] < w[i][j] && w[i-1][j] < w[i][j] && w[i][j+1] < w[i][j] && w[i+1][j-1] < w[i][j]) || (w[i+1][j] > w[i][j] && w[i-1][j] > w[i][j] && w[i][j+1] > w[i][j] && w[i+1][j-1] > w[i][j])) {
          if (Qcrit(i, j, flow.u)>Qmin && abs(w[i][j])>wmin && body.distance((float)i, (float)j)>bmin) { //Check for Q criterion, max vorticity, and distance from body
            cores.add(new VortexCore(i, j, r_init, w[i][j])); //Add a new vortex core
          }
        }
      }
    }
    println("Number of Valid Peaks: " + cores.size());

    // +++++++++++++++ Step 2 - Expands all the cores until either they interefere with each other, or the vorticity dies out
    boolean running=true; //indicator that all cores have finished dilating
    while (running) {
      running = false;

      //Dilate all the cores, but only if the vorticity on the border is above a threshold
      for (VortexCore c : cores) {
        float meanborderw = lineinteg(c.xc, c.r, vorticity, true)/(2*PI*c.r); //Find mean of vorticity along perimeter
        if ((abs(meanborderw)>diatol*abs(c.w))) { //Check if mean vorticity along perimeter is greater than a small fraction of max vorticity
          if ((c.r<r_max)&&(c.r<body.distance(c.xc.x, c.xc.y)-dr)) { //Check if radius is too big or interferes with body
            //Dilate the given core, and reset indicator
            running = true;
            c.G_rough += meanborderw*(2*PI*c.r)*dr; //Rough circulation found iteratively, used to compare strength of vorticies
            c.r += dr;
          }
        }
      }

      //Check for core interference with other cores
      toremove.clear();
      for (int i=cores.size()-1; i>=0; i--) {
        VortexCore ci = cores.get(i);
        for (int j=i-1; j>=0; j--) {
          VortexCore cj = cores.get(j);
          //Check for interference between cores
          if ((PVector.sub(ci.xc, cj.xc).mag()<(ci.r+cj.r+2*dr)) && (cj.w*ci.w>0)) {       
            //Remove core with smaller rough circulation if same sign
            if (abs(ci.G_rough)>abs(cj.G_rough))
              toremove.add(cj);
            else
              toremove.add(ci);
          }
        }
      }
      cores.removeAll(toremove);
    }

    //+++++++++++++++ Step 3 - Find final circulation again by area method, ignoring vorticity of the wrong sign
    for (VortexCore c: cores)
      c.G = areainteg(c.xc, c.r, vorticity, true);
    println("Final Number of Cores: " + cores.size());
  }
  void display() {
    //Displays the vortex cores, and labels the circulation if specified
    int G = #000393, S = #0003A3, w = #0003C9, txtpnt = 12;
    PImage img = copy();
    img.loadPixels();
    if (cores.size()>0) {
      for ( VortexCore c: cores ) {
        stroke(img.pixels[window.px(c.xc.x)+window.py(c.xc.y)*img.width]);
        fill(0, 0);
        dashcirc(c.xc.x, c.xc.y, c.r, round(c.r*2), window);
        if (dispG) {
          textSize(txtpnt);
          textAlign(CENTER, TOP);
          fill(0);
          char sign = '+';
          if (c.G<0)
            sign = '-';
          text("" + (char)S + (char)w + sign + ": " + nfs(c.G*annoscale, 1, 2), window.px(c.xc.x), window.py(c.xc.y+c.r));
        }
      }
    }
  }
  void dashcirc(float x0, float y0, float r, int n, Window window) {
    //Draws a dashed circle at (x0,y0) with radius 'r' and 'n' dashes
    float x1, y1, x2, y2;
    for (float i=0; i<2*n-1; i+=2) {
      x1 = r*cos(PI*i/n)+x0;
      y1 = r*sin(PI*i/n)+y0;
      x2 = r*cos(PI*(i+1)/n)+x0;
      y2 = r*sin(PI*(i+1)/n)+y0;
      line(window.px(x1), window.py(y1), window.px(x2), window.py(y2));
    }
  }
  float lineinteg(PVector xc, float r, VectorField u) {
    //Finds line integral about a circle, integral of u-dot-ds
    int n = round(r*circres);
    float res=0, x, y, dx, dy, dth = 2*PI/n;
    if (r<0)
      return 0;
    for (int i=0; i<n; i++) {
      x = r*cos(i*dth);
      y = r*sin(i*dth);
      dx = x-r*cos((i-1)*dth);
      dy = y-r*sin((i-1)*dth);
      res += u.x.linear(xc.x+x, xc.y+y)*dx + u.y.linear(xc.x+x, xc.y+y)*dy;
    }
    return res;
  }
  float lineinteg(PVector xc, float r, Field F, boolean sum_only_same_sign) {
    //Finds line integral about a circle, integral of Fds
    float n = round(r*circres);
    float res=0, x, y, dth = 2*PI/n, Fds;
    float Fmid = F.linear(xc.x, xc.y);
    if (r<0) {
      return 0;
    }
    for (int i=0; i<n; i++) {
      x = r*cos(i*dth);
      y = r*sin(i*dth);
      Fds = F.linear(xc.x+x, xc.y+y)*r*dth;
      if (!sum_only_same_sign || (Fds*Fmid>0 && sum_only_same_sign))
        res += Fds;
    }
    return res;
  }
  float areainteg(PVector xc, float R, Field F, boolean sum_only_same_sign) {
    //Finds area integral on the inside of a circle, integral of FdA, using concentric circles
    float res=0, x, y, n, dth, r1, r2, FdA, Fmid; 
    if (R<0)
      return 0;
    Fmid = F.linear(xc.x, xc.y)*PI*dr*dr/4.0;
    for (float r=1; r<=R; r+=dr) {
      n = round(r*circres);
      r2 = r+dr/2; 
      r1 = r-dr/2;
      if (r==R)
        r2 = R;
      dth = 2*PI/n;
      for (int i=0; i<n; i++) {
        x = r*cos(i*dth);
        y = r*sin(i*dth);
        FdA = F.linear(xc.x+x, xc.y+y)*(r2*r2-r1*r1)*dth/2.0;
        if (!sum_only_same_sign || (FdA*Fmid>0 && sum_only_same_sign))
          res += FdA;
      }
    }
    return res+Fmid;
  }
  float Qcrit(int i, int j, VectorField velo) {
    //Finds Qcriterion of flow at location (i,j)
    if ((i-1<0)||(j-1<0)||(i+1>velo.n-1)||(j+1>velo.m-1))
      return 0;
    float[][] u = velo.x.a;
    float[][] v = velo.y.a;
    float dudx = 0.5*(u[i+1][j]-u[i-1][j]);
    float dudy = 0.5*(u[i][j+1]-u[i][j-1]);
    float dvdx = 0.5*(v[i+1][j]-v[i-1][j]);
    float dvdy = 0.5*(v[i][j+1]-v[i][j-1]);
    return dudx*dvdy-dvdx*dudy;
  }
}
class VortexCore {
  //Vortex Core object, has two circulations 'G' and 'G_rough' (area integral of vorticity and a rough estimate used to compare vortex strengths)
  //Also has a center 'xc', radius 'r', vorticity at center 'w'
  float G_rough, G, r, w;
  PVector xc;
  boolean grow;
  VortexCore(float x, float y, float r, float w, float Gv, float G) {
    this.xc = new PVector(x, y, 0);
    this.r = r;
    this.w = w;
    this.G_rough = G;
    this.G = G;
    this.grow = true;
  }
  VortexCore(float x, float y, float r, float w) {
    this(x, y, r, w, 0, 0);
  }
  VortexCore(PVector xc, float r, float w) {
    this(xc.x, xc.y, r, w, 0, 0);
  }
}