/******************************************
 StreamPlot
 
  Draws the streamlines on top of a regular plot, using the stream function
 example code:
 
BDIM flow;
CircleBody body;
StreamPlot flood;

void setup(){
  int n=(int)pow(2,6);   // number of grid points
  int nlines = 15;       // number of streamlines
  size(400,400);         // display window size
  Window view = new Window(n,n);

  body = new CircleBody(n/3,n/2,n/8,view); // define geom
  flow = new BDIM(n,n,1.5,body);           // solve for flow using BDIM

  flood = new StreamPlot(view,flow,nlines);
  flood.range = new Scale(-.75,.75);
  flood.setLegend("vorticity");
  flood.setLineColor(0);
  flood.setLineThickness(0.1);
}
void draw(){
  body.update();
  flow.update(body);
  flow.update2();
  flood.display(flow.u.curl());
  body.display();
}
void mousePressed(){body.mousePressed();}
void mouseReleased(){body.mouseReleased();}
 ********************************************/

class StreamPlot extends FloodPlot {
  BDIM flow;
  PImage streamImage;
  int nlines;
  float thickness = 0.1; //In fraction of spacing between streamlines
  color streamcolor = 0;

  StreamPlot(Window window, BDIM flow, int nlines) {
    super( window );
    this.flow = flow;
    this.nlines = nlines;
    streamImage = new PImage(window.dx, window.dy, ARGB);
  }
  void setLineColor(color c) {
    this.streamcolor = c;
  }
  void setLineThickness(float thick) {
    this.thickness = thick;
  }
  void display ( Field a ) {
    float minv = 1e6, maxv = -1e6;
    super.display(a);
    Field psi = flow.u.streamFunc();

    colorMode(HSB, 360, 1.0, 1.0, 1.0);
    streamImage.loadPixels();
    float psimod = (float)flow.m/nlines;
    for ( int i=0 ; i<window.dx ; i++ ) {
      float x = window.ix(i+window.x0);
      for ( int j=0 ; j<window.dy ; j++ ) {
        float y = window.iy(j+window.y0);
        float streamon = ((psi.interp(x, y)) % psimod)/psimod - 0.5;
        if (abs(streamon)<0.5*thickness)
          streamImage.pixels[i+j*window.dx] = color(hue(streamcolor),saturation(streamcolor),brightness(streamcolor),1-abs(streamon)/(0.5*thickness));
        else
          streamImage.pixels[i+j*window.dx] = color(0, 0);
        float f = a.interp(x, y);
        minv = min(minv, f);
        maxv = max(maxv, f);
      }
    }
    streamImage.updatePixels();
    image(streamImage, window.x0, window.y0);
    if (legendOn)
      legend.display(minv, maxv);
  }
}