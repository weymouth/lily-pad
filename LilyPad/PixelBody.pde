/*********************************************************
PixelBody Class
            
Use an array of pixels to define a BDIM body 

The standard Body type uses an array of points to define the 
boundary of a body, with everything inside that boundary being solid.
PixelBody uses an alternative representation: the fraction of each 
grid cell taken up by the solid. This is a very general approach
to representing the topolgy and should allow for some fun studies.

This class is a work in progress.

Example code:

BDIM flow;
PixelBody body;

void setup(){
  size(700,700);                   // display window size
  int n=(int)pow(2,7);             // number of grid points
  Field a = new Field(n,n,0,1.);   // init empty geom array
  a.eq(0.0,40,50,30,40);           // add solid square
  a.eq(0.0,50,60,50,70);           // add solid rectangle
  a.eq(0.0,40,50,80,90);           // add solid square
  body = new PixelBody(a);         // create pixel body
  flow = new BDIM(n,n,0.,body);    // solve for flow using BDIM
}

void draw(){
  flow.update(); flow.update2();    // 2-step fluid update
  flow.u.x.display(-1,2);           // compute and display vorticity
  body.display();                   // display the BodyImage
}
*********************************************************************************/
class PixelBody extends AbstractBody{
  Field pix;
  int n,m;
  Window window;
  float area,mass;

  PixelBody(Field pix){
    n = pix.n; m=pix.m; this.pix = pix;
    window = new Window(n,m);
    getArea();
  }
  PixelBody(int n, int m){this(new Field(n,m));}
  
  void getArea() { // get the body area
    area = (n-2)*(m-2)-pix.sum();
    mass = area; // default unit density
  }
  
  // display the image
  void display(){
    colorMode(ALPHA,1);
    PImage img = new PImage(window.dx,window.dy,ALPHA);
    img.loadPixels();
    for ( int i=0 ; i<window.dx ; i++ ) {
      float x = window.ix(i+window.x0);
      for ( int j=0 ; j<window.dy ; j++ ) {
        float y = window.iy(j+window.y0);
        float f = pix.interp(x,y);
        img.pixels[i+j*window.dx] = color(f,1-f);
      }
    }
    img.updatePixels();
    image(img,window.x0,window.y0);
  }

  PVector dpix(float i, float j){
    return new PVector(pix.interp(i+0.5,j)-pix.interp(i-0.5,j),pix.interp(i,j+0.5)-pix.interp(i,j-0.5));
  }
  PVector del(float i, float j, float eps){return new PVector(pix.interp(i,j), dpix(i,j).mag()*eps);}
  PVector WallNormal(float i, float j){
    PVector n = dpix(i,j);
    float m = n.mag();
    if(m>1e-8){n.div(m);}
    return n;
  }

  // Compute the pressure force on an PixelBody
  PVector pressForce(Field p){
    PVector pv = new PVector(0, 0);
    for ( int i=1 ; i<n-1 ; i++ ) {
    for ( int j=1 ; j<m-1 ; j++ ) {
        pv.add(dpix(i,j).mult(p.a[i][j]));
    }}
    return pv;
  }

}
