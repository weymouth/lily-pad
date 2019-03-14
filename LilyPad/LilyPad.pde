Body body;
Tabs tabs;
Window view;
BDIM flow;
ParticlePlot plot;
int n;

void setup(){
  fullScreen();
  n = 3*int(pow(2,6));
  view = new Window(1,1,n-1,n-1,width/2-height/3,0,height,height);
  tabs = new Tabs();
  body = new Body(0,0,view);
}
void draw(){
  if(tabs.running.active) {
    colorMode(RGB,1);
    flow.update();//flow.update2();
    plot.update(flow); // !NOTE!
    plot.display(flow.u.curl());
  }else {
    colorMode(RGB,1);
    background(1);
    noFill(); stroke(0.8);
    rect((width-height)/2+height/4,height/4,height/2,height/2);
  }
  body.display();
  colorMode(RGB,1);
  tabs.display();
}
void mousePressed(){
  if(tabs.mouseInput(mouseX,mouseY)){
    if(tabs.drawing.active){body = new Body(view.ix(mouseX),view.iy(mouseY),view);}
    if(tabs.running.active){
      body.end();
      flow = new BDIM(n,n,0.,body);
      plot = new ParticlePlot(view,5000);
      plot.setLegend("Vorticity",-0.5,0.5);
      plot.setColorMode(4);
    }
  body.mousePressed();
  }
}
void mouseDragged(){
  if(tabs.drawing.active){body.add(view.ix(mouseX),view.iy(mouseY));}
}

void mouseReleased(){
  body.mouseReleased();
}