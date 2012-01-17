/**********************************
 SaveData class
 
Saves data to a text file with customizable header
 
 example code:
 dat = new SaveData("pressure.txt",test.foil.fcoords,resolution,xLengths,yLengths,zoom);
 dat.addData(test.t, test.flow.p);
 dat.finish();
***********************************/
 
class SaveData{
  PVector[] coord;
  PrintWriter output;
  int n;
  
  SaveData(String name, PVector[] coord, int resolution, int xLengths, int yLengths, int zoom){
    output = createWriter(name);
    this.coord = coord;
    n = coord.length;
    output.println("%% Pressure distribution along the foil using processing viscous simulation");
    output.print("% xcoord = [");
    for(int i=0; i<n; i++){
      output.print(coord[i].x +" ");
    }
    output.println("];");
    
    output.print("% ycoord = [");
    for(int i=0; i<n; i++){
      output.print(coord[i].y +" ");
    }
    output.println("];");
  
    output.print("% resolution = "+ resolution);
    output.print("; xLengths = "+ xLengths);
    output.print("; yLengths = "+ yLengths);
    output.print("; zoom = "+ zoom);
    output.println(";");  
}
     
  
  void addData(float t, Field a){
    output.print(t + " ");
    for(int i=0; i<n; i++){
      output.print(a.linear( coord[i].x, coord[i].y ) +" ");
    }
    output.println(";");
  }
  
  void finish(){
    output.flush(); // Writes the remaining data to the file
    output.close(); // Finishes the file
  }
} 
  
 
