class BodyUnion extends Body{
  Body a,b;

  BodyUnion(a,b){ this.a = a; this.b = b;}

  void display(){a.display(); b.display();}
  
  float distance( float x, float y){ // in cells
    return min(a.distance(x,y),b.distance(x,y));
  }
  int distance( int px, int py){     // in pixels
    return min(a.distance(px,py),b.distance(px,py));
  }

  Body closer(float x, float y){
    if(a.distance(x,y)<b.distance(x,y)){
      return a;
    }else{
      return b;
    }
  }
  
  float velocity( int d, float dt, float x, float y ){
    Body c = closer(x,y);
    return c.velocity(d,dt,x,y);
  }

  void update(){a.update();b.update();}
  void mousePressed(){a.mousePressed();b.mousePressed();}
  void mouseReleased(){a.mouseReleased();b.mouseReleased();}
}

