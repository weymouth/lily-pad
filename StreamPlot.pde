/******************************************
StreamPlot

Uses a FieldSwarm to produce a colored 
unsteady streamline plot

example code:

BDIM flow;
Body body;
StreamPlot plot;

void setup(){
  int n = (int)pow(2,6)+2; size(400,400);
  Window window = new Window(n,n);
  body = new CircleBody( n/3, n/2, n/8, window );
  body.bodyColor = color(#00008B);
  flow = new BDIM(n,n,1,body);

  plot = new StreamPlot( window, 10000 );
  plot.setColorMode(4);
  plot.setLegend("Vorticity",-0.5,0.5);
}

void draw(){
  flow.update(body); flow.update2();
  plot.update(flow); // !NOTE!
  plot.display(flow.u.vorticity());
  body.display();
}
********************************************/

class StreamPlot extends FloodPlot{
  FieldSwarm swarm;
  
  StreamPlot( Window window, int num ){
    super( window );
    swarm = new FieldSwarm( window, num );
  }

  void update( BDIM flow ){ swarm.update(flow); }
  void update( VectorField u, VectorField u0 , float dt){ swarm.update( u, u0, dt ); }

  void display ( Field a ){
    float minv = 1e6, maxv = -1e6;
    colorMode(HSB,360,1.0,1.0,1.0);
    color c = sequential?colorScale(range.out(0.6)):color(300); fill(c,0.2);
    noStroke(); rect(0,0,width,height); // Draw partially transparent background to get streaky effect
    strokeWeight(2);
    for( Particle p: swarm.pSet){
      float f = a.interp(p.x.x,p.x.y);
      p.display(colorScale(f));
      minv = min(minv,f);
      maxv = max(maxv,f);
    }
    if(legendOn) {
      legend.box = true;
      legend.display(minv,maxv);
    }
  }
}
