/***************
AmandaData class

Edited to SaveData class to have no header (simpler for my Matlab importing and usage).

Example code:

 dat = new AmandaData("pressure.txt",test.foil.fcoords,resolution,xLengths,yLengths,zoom);
 dat.saveParam(test.t);
 dat.finish();
 
***********/

class AmandaData {
  ArrayList<PVector> coords;
  PrintWriter output;
  int n, N, M;
  
  AmandaData(String name, ArrayList<PVector> coords, int resolution, int xLengths, int yLengths){
    output = createWriter(name);
    this.coords = coords;
    n = coords.size(); 
    N = xLengths*resolution;
    M = yLengths*resolution;
  }
     
    
  void saveParam(float value){
    output.println(value + " ");
  }

  void addFieldBody(Field a, Body b){
    for(int i=0; i<n; i++){
      output.print(a.linear( b.coords.get(i).x, b.coords.get(i).y ) + " ");
    }
    output.println(";");
  }
  
  void addField(float t, LilyPad.Field b){    //output entire velocity and pressure fields
    for(int i=0; i<N; i++){
      for(int j=0; j<M; j++){
      output.print(b.a[i][j] +" ");
    }
    output.println(";");
    }
  }
  
  void addCoords(Body b){
    output.println("x = ");
    for(int i=0; i<n; i++){
      output.print(b.coords.get(i).x + " ");
    }
    output.println(";");
    output.println("y = ");
     for(int i=0; i<n; i++){
      output.print(b.coords.get(i).y + " ");
    }
    output.println(";");
  }
  
  void addVector(PVector p){
    output.print(p.x + " " + p.y + " ");
    output.println(";");
  }
  
  void addVec( float[] f){
    for(int i=0; i<f.length; i++){
      output.print(f[i] + " ");
    }
    output.println(";");
  }
  
  void addBodyCen(Body b){
    output.print(b.xc.x + " " + b.xc.y + " ");
    output.println(";");
  }

  void addText(String s){  
    output.println(s);
  }

  void finish(){
    output.flush(); // Writes the remaining data to the file
    output.close(); // Finishes the file
  }
} 

