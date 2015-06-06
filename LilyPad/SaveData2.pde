/**********************************
 SaveData2 class
 This is a simplified version of SaveData class which is exclusive for circular array of cylinders.
 Saves data to a text file with customizable header
 
---- example code fragment:

 SaveData2 dat;
 
 void setup(){
   ...
   dat = new SaveData2("saved/N39d12DragAoA90.txt",body);
   ...
 }
 
 void draw(){
   ...
   dat.addData(flow.p,"Drag", DG);
   ... 
 }
----see use in CircleArray.pde
***********************************/
class SaveData2{
  ArrayList<PVector> coords = new ArrayList<PVector>();
  PrintWriter output;
  int n;
  ArrayList<CircleBody> bodys = new ArrayList<CircleBody>();
    SaveData2(String name, CircleArrangement body){ 
    output = createWriter(name);
    n = 0;
    for(CircleArray subcircleArr : body.circleArr){
        for(CircleBody circle: subcircleArr.circleList){
          for(PVector xy: circle.coords){
            coords.add(xy);
          }
          bodys.add(circle);
          n++;
        }
    }
    this.bodys = bodys;
    this.n = n;
}
     
  void saveParam(String name, float value){
    output.println("% " + name + " = " + value + ";");
  }
  void saveString(String s){
    output.println(s);
  }
  
  
  void addData(Field a, String str, float L){
      //get pressure for every cylinder.
      PVector pressure=new PVector(0, 0);
      for(CircleBody cb : bodys){
         pressure.add(cb.pressForce(a));
      }
      
      if(str.equals("Drag")){
        output.println(2*pressure.x/L + " ");
      }
      else{
        output.println(2*pressure.y/L + " ");
      }
  }
  
  // New addData method that restores drag or lift coefficient of each cylinder.
  // The 4th argument is just only for distinguishing this function to store single cylinder's information with other functions. e.g. "Single".
  // Output file with the format: 
  /* 
     cylinder 1's Drag pressure, cylinder 2's Drag pressure, cylinder 3's Drag pressure,...,  cylinder n's Drag pressure  (first time step)
     cylinder 1's Drag pressure, cylinder 2's Drag pressure, cylinder 3's Drag pressure,...,  cylinder n's Drag pressure  (second time step)
     cylinder 1's Drag pressure, cylinder 2's Drag pressure, cylinder 3's Drag pressure,...,  cylinder n's Drag pressure  (third time step)
  */
  void addData(Field a, String str, float L, String str2){
      if(str.equals("Drag")){
        for(CircleBody cb : bodys){
         output.print(2*cb.pressForce(a).x/L+" ");
      }
        output.println();
      }
      else{
        for(CircleBody cb : bodys){
         output.print(2*cb.pressForce(a).y/L+" ");
      }
      output.println();
      }
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
