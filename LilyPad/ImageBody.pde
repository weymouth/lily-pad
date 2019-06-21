/*********************************************************
ImageBody Class
                  
Use an image to define a BDIM body instead of a set of points.

Example code:

BDIM flow;
FloodPlot flood;
ImageBody img;

void setup(){
  size(700,700);                             // display window size
  int n=(int)pow(2,7);                       // number of grid points
  Window view = new Window(n,n);
  Body body = new CircleBody(n/3.,n/2.,n/6.,view);
  img = new ImageBody(n, n, body);
  flow = new BDIM(n,n,0.,img);               // solve for flow using BDIM
  //flow = new BDIM(n,n,0., body);             // for comparison
  flood = new FloodPlot(view);               // initialize a flood plot...
  flood.setLegend("vorticity",-.5,.5);       //    and its legend
}

void draw(){
  flow.update(); flow.update2();             // 2-step fluid update
  flood.display(flow.u.curl());              // compute and display vorticity
  img.display();                             // display the BodyImage
}
*********************************************************************************/
class ImageBody{
  PImage img;
  float area,mass;

  // Makes an ImageBody from an image
  ImageBody(int n, int m, PImage src){
    img = src.copy();
    img.resize(n,m);
    setAlpha();
    getArea();
  }
  
  // set alpha to (near) zero where there is no body for displaying
  void setAlpha(){
    colorMode(RGB, 1);
    img.loadPixels();
    for ( int i=0 ; i<img.height*img.width ; i++ ) {
        float f = brightness(img.pixels[i]);
        img.pixels[i] = color(f,map(f,0,1,1,0.01));
    }
    img.updatePixels();
  }

  // Makes an ImageBody from a body
  ImageBody(int n, int m, Body body){
    colorMode(RGB, 1);                                // define 0->black & 1->white
    img = createImage(n,m,RGB);                       // empty image
    img.loadPixels();                                 // load pixels
    for ( int i=0 ; i<n ; i++ ) {                     // loop through...
    for ( int j=0 ; j<m ; j++ ) {                     // ... the cells
        float dist = body.distance((float)i, (float)j);  // distance from cell to body
        float f = delta0(dist);                          // indicator function
        img.pixels[i+j*n] = color(f);                    // set pixel brightness
    }}
    img.updatePixels();
    setAlpha();
    getArea();
  }
  float delta0( float d ){
    float eps = 2;
    if( d <= -eps ){
      return 0;
    } else if( d >= eps ){
      return 1;
    } else{
      return 0.5*(1.+d/eps+sin(PI*d/eps)/PI);
    } 
  }
  
  void getArea() {    // get the body image area
    area=0;
    for ( int i=0 ; i<img.width*img.height; i++ ) {
      area += 1-brightness(img.pixels[i]);
    }
    mass = area; // default unit density
  }
  
  // get/interpolate the local brightness value
  float b(int i, int j){
    colorMode(RGB, 1); // define 0->black & 1->white
    int ii = max(min(i-1,img.width-1),0);
    int jj = max(min(j-1,img.height-1),0);
    return brightness(img.pixels[ii+jj*img.width]);
  }
  float b(float i, float j){
    int ii = floor(i), jj = floor(j);
    float ri = i-ii, rj = j-jj;
    if(ri==0 & rj==0){
      return b(ii,jj);
    }else{
      return (1-rj)*((1-ri)*b(ii,jj)+ri*b(ii+1,jj))
            +rj*((1-ri)*b(ii,jj+1)+ri*b(ii+1,jj+1));
    }
  }
  
  // get the gradient of the local brightness
  PVector db(float i, float j){
    return new PVector(b(i+0.5,j)-b(i-0.5,j),b(i,j+0.5)-b(i,j-0.5));
  }

  // display the image
  void display(){
    int x0 = width/img.width, y0 = height/img.height;
    image(img,x0,y0,width,height);
  }

  // Compute the pressure force on an ImageBody
  PVector pressForce(Field p){
    PVector pv = new PVector(0, 0);
    img.loadPixels();                                 // load pixels
    for ( int i=1 ; i<p.n-1 ; i++ ) {                     // loop through...
    for ( int j=1 ; j<p.m-1 ; j++ ) {                     // ... the cells
        pv.add(db(i,j).mult(p.a[i][j]));
    }}
    return pv;
  }
}