/**********************************
 FloodPlot class
 
 Holds the values and operators for
 very nice flood plots
 
 example code:
void setup(){
  size(400,400);
  int n=100,m=2;
//  FloodPlot plot = new FloodPlot(new Window(1,1,n-2,m-2,100,1,300,325)); //custom window
  FloodPlot plot = new FloodPlot(new Window(n,m)); // standard window
  Field p = new Field(n,m);
  for( int i=0; i<n; i++){
  for( int j=0; j<m; j++){
    p.a[i][j] = 1.5*(0.5-i/(float)(n-1));
  }}
  plot.range = new Scale(-1,1);
  plot.hue = new Scale(200,140);
  plot.setLegend("test");
  plot.display(p);
}
***********************************/
 
class FloodPlot{
  LegendPlot legend;
  PImage img;
  Window window;
  Scale range = new Scale(0,1);
  Scale hue = new Scale(240,0);
  Scale sat = new Scale(1,1);
  Scale bri = new Scale(1,1);
  boolean sequential=false,legendOn=false,dark=false,sharp=false;

  FloodPlot( Window window ){
    this.window = window;
    img = new PImage(window.dx,window.dy,HSB);
  }
  FloodPlot( FloodPlot a){
    legend = a.legend; 
    img = a.img; 
    window = a.window;
    range = a.range; 
    hue = a.hue; sat = a.sat; bri = a.bri;
    sequential = a.sequential; 
    legendOn = a.legendOn; dark = a.dark; sharp = a.sharp;
  }

  color colorScale( float f ){
    float i = range.in(f); // get % of the range
    if( sharp & i>0.4 & i<0.6 ) i = 0.5;
    if(sequential){          // blend hue and saturation
      return color(hue.outB(i),sat.out(i),bri.out(i));
    } 
    else if(i<0.5) {       // blend from low end to black/white
      if (dark) {return color(hue.outS,sat.outS,1-2*i);}
      else {return color(hue.outS,(0.5-i)*2,1);}
    } 
    else {                 // blend from high end to black/white
      if (dark) {return color(hue.outE,sat.outE,2*i-1);}
      else {return color(hue.outE,(i-0.5)*2,1);}
    }
  } 

  void display ( Field a ){
    float minv = 1e6, maxv = -1e6;
    colorMode(HSB,360,1.0,1.0,1.0);
    noStroke();
    img.loadPixels();
    for ( int i=0 ; i<window.dx ; i++ ) {
      float x = window.ix(i+window.x0);
      for ( int j=0 ; j<window.dy ; j++ ) {
        float y = window.iy(j+window.y0);
        float f = a.interp(x,y);
        img.pixels[i+j*window.dx] = colorScale(f);
        minv = min(minv,f);
        maxv = max(maxv,f);
      }
    }
    img.updatePixels();
    image(img,window.x0,window.y0);
    if(legendOn) legend.display(minv,maxv);
  }

  void setLegend(String title, float low, float high){
    range = new Scale(low,high);
    legend = new LegendPlot(this,title);
    legendOn = true;
  }
  void setLegend(String title){ setLegend( title, range.outS, range.outE );}

  void setColorMode(int mode){
    if (mode==1){dark = false;}
    if (mode==2){sequential = true;}
    if (mode==3){sequential = true; sat = new Scale(0,0); bri = new Scale(0,1);}
    if (mode==4){sequential = true; sat = new Scale(1,0); bri = new Scale(0.24,1); hue.outE = hue.outS; hue.r = 0;}
    if (legendOn){legend.setColorMode(mode);}
  }

  class LegendPlot extends FloodPlot{
    String title;
    PFont font;
    Field levels;
    boolean box = false;

    LegendPlot( FloodPlot a, String _title){
      super(a); legendOn = false; // duplicate the flood settings, except for legend

      int n = 11, m = 2; // resize the window and image
      window = new Window(1,1,n-2,m-2,a.window.x0+a.window.dx/4,a.window.y0+14,a.window.dx/2,16);
      img = new PImage(window.dx,window.dy);

      font = loadFont("Dialog.bold-14.vlw"); // load text stuff
      title = _title;

      levels = new Field(n,m);  // generate data to plot
      for (int i=0; i<n; i++){
        for (int j=0; j<m; j++){
          levels.a[i][j] = range.out(i/float(n-1));
        }
      }
    }
    void display( float minv, float maxv ){
      if(box) {
        noStroke(); fill(colorScale(0));
        rect(0,0,width,45);
      }

      super.display(levels);

      int x0 = window.x0, x1 = window.x0+window.dx;
      int y0 = window.y0, y1 = window.y0+window.dy;
      float low = range.outS, high = range.outE;
      Scale x = new Scale(low,high,x0,x1);

      textFont(font);
      fill((sequential |!dark )?0:360);
      textAlign(RIGHT,CENTER);
      text(title,x0,0.5*(y0+y1));
      textAlign(CENTER,BASELINE);
      text(""+low,x0,y0);
      text(""+high,x1,y0);
      if(low<0&&high>0)text("0",x.out(0),y0);
      textAlign(CENTER,TOP);
      stroke(0);
      fill(colorScale(minv)); 
      String a = ""+minv;
      text(a.substring(0,min(a.length(),5)),x.out(minv),y1);
      fill(colorScale(maxv)); 
      a = ""+maxv;
      text(a.substring(0,min(a.length(),5)),x.out(maxv),y1);
      
    }
  }
  
      void displayTime(float t){
      PFont font = loadFont("Dialog.bold-14.vlw");
      int x0 = window.x0, x1 = window.x0+window.dx;
      int y0 = window.y0, y1 = window.y0+window.dy;
      textFont(font);
      textAlign(CENTER,BASELINE);
      fill(255);
      text("t = "+ nfs(t,2,2),0.5*(x0+x1),y1);
    }
}

