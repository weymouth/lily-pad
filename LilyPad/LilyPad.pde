CamBody body;
BDIM flow;
ParticlePlot plot;
Window view;
int b = int(pow(2,4)), n=8*b, m=5*b;

void setup() {
  fullScreen();
  view = new Window(n, m);
  body = createCamBody(0, n, m);
  flow = new BDIM(n, m, 0., body);
  plot = new ParticlePlot(view, 5000);
  plot.setLegend("Flow speed", -0.5, 1.5);
  plot.setColorMode(2);
}

void draw() {
  body.update();
  flow.update(body);
  plot.update(flow);

  body.background();
  plot.display(flow.u.x);
  body.display();

  if(body.area>1){
    println(body.area);
    PVector force = body.pressForce(flow.p).div(-0.5*sqrt(body.area));
    textSize(32);
    float spacing=32;
    int x0 = view.x0, y1 = view.y0+view.dy;
    textAlign(LEFT,BASELINE);
    String ax = ""+force.x;
    String ay = ""+force.y;
    text(" Drag coefficient: " + ax.substring(0,min(ax.length(),5)),x0+spacing,y1-2*spacing);
    text(" Lift coefficient: " + ay.substring(0,min(ay.length(),5)),x0+spacing,y1-spacing);
  }
}
