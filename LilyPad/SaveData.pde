/**********************************
 SaveData class
 
Saves data to a text file with customizable header
 
---- example code fragment:
 dat = new SaveData("pressure.txt",test.foil.fcoords,resolution,xLengths,yLengths,zoom);
 dat.addData(test.t, test.flow.p);
 dat.finish();
----see use in InlineFoilTest.pde, AudreyTest.pde, etc
***********************************/
 
class SaveData{
  ArrayList<PVector> coords;
  PrintWriter output;
  int n;
  
  SaveData(String name, ArrayList<PVector> coords, int resolution, int xLengths, int yLengths, int zoom){
    output = createWriter(name);
    this.coords = coords;
    n = coords.size();
    output.println("%% Pressure distribution along the foil using processing viscous simulation");
    output.print("% xcoord = [");
    for(int i=0; i<n; i++){
      output.print(coords.get(i).x +" ");
    }
    output.println("];");
    
    output.print("% ycoord = [");
    for(int i=0; i<n; i++){
      output.print(coords.get(i).y +" ");
    }
    output.println("];");
  
    output.print("% resolution = "+ resolution);
    output.print("; xLengths = "+ xLengths);
    output.print("; yLengths = "+ yLengths);
    output.print("; zoom = "+ zoom);
    output.println(";");  
}
     
  void saveParam(String name, float value){
    output.println("% " + name + " = " + value + ";");
  }
  void saveString(String s){
    output.println(s);
  }
  
  void addData(float t, Field a){
    output.print(t + " ");
    for(int i=0; i<n; i++){
      output.print(a.linear( coords.get(i).x, coords.get(i).y ) +" ");
    }
    output.println(";");
  }
  
  void addData(float t, PVector p, Body b, Field a){
    output.print(t + " ");
    output.print(p.x + " " + p.y + " ");
    output.print(b.xc.x + " " + b.xc.y + " ");
    for(int i=0; i<n; i++){
      output.print(b.coords.get(i).x + " " + b.coords.get(i).y + " ");
      output.print(a.linear( b.coords.get(i).x, b.coords.get(i).y ) +" ");
    }
    output.println(";");
  }
  
  void addDataSimple(float t, PVector p, Body b, Field a){  //simplified to only output time and vector x and y values 
    output.print(t + " ");
    output.print(p.x + " " + p.y + " ");
    output.println(";");
  }

  void addText(String s){   //allows to insert text anywhere in txt
    output.println(s);
  }

  void finish(){
    output.flush(); // Writes the remaining data to the file
    output.close(); // Finishes the file
  }
} 
  
 
