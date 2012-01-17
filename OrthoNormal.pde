// Class to hold the ortho-normal project terms of a line segment

class OrthoNormal{
  float nx,ny,tx,ty,off,t1,t2;

  OrthoNormal(){ this(new PVector(0,0), new PVector(0,1));}
  OrthoNormal(PVector x1, PVector x2 ){ // set the ortho-normal values based on two points
    float l = PVector.sub(x1,x2).mag();
    tx = (x2.x-x1.x)/l;    // x tangent
    ty = (x2.y-x1.y)/l;    // y tangent
    t1 = x1.x*tx+x1.y*ty;  // tangent location of point 1
    t2 = x2.x*tx+x2.y*ty;  // tangent location of point 2
    nx = -ty; ny = tx;     // normal vector
    off = x1.x*nx+x1.y*ny; // normal offset
  }

  float distance( float x, float y){ return distance(x,y,true); }
  float distance( float x, float y, Boolean projected){ // distance function
    float d = x*nx+y*ny-off; // normal distance to line 
    if(projected) return d;  // |distance|_n (signed, fastest)
    float d1 = x*tx+y*ty-t1; // tangent dis to start
    float d2 = x*tx+y*ty-t2; // tangent dis to end
    return sqrt(sq(d)+sq(max(0,-d1))+sq(max(0,d2))); // |distance|_2
//    return abs(d)+max(0,-d1)+max(0,d2);            // |distance|_1 (faster)
  }

  void translate(float dx, float dy){
    t1 += dx*tx+dy*ty;
    t2 += dx*tx+dy*ty;
    off += dx*nx+dy*ny;
  }

  void print(){
    println("t=["+tx+","+ty+"]");
    println("n=["+nx+","+ny+"]");
    println("offsets=["+t1+","+t2+","+off+"]");
  }
}
