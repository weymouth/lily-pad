/**********************************
 ReadData class
 
 Reads timestamped data from a file to use in Lilypad
 
 ----example code fragment:
 reader = new ReadData("FileToRead.txt");
 float dat = reader.interpolate(t, column);
 ----see use in InlineFoilTest.pde
 
 ----the file should look like this, with Tabs between the data:
 #rows #cols dt <AnyOtherInfoYouWant (Optional)>
 data00 data01 data02....
 data10 data11 data12....
 ...
 
 each row is the data at a timestep - 0zth row is t=0, 1st is t=dt, etc
 
 ----you can create this file type in matlab with these commands (if 'arr' is the array of data, 'dt' is your timestep, and 'filepath' is a string that points to a text file)
header = [size(arr,1) size(arr,2) dt <AnyOtherInfoYouWant>]
save(filepath,'header','-ascii', '-tabs');
save(filepath,'arr','-append','-ascii', '-tabs');
 ***********************************/

class ReadData {
  float[][] data;
  BufferedReader reader;
  String line;
  float dat=0, dt=1;
  String[] header;
  int rows, cols;
  boolean verbose = false;
  char delim = TAB;

  ReadData(String filepath) {
    reader = createReader(filepath);
    readAll();
  }

  void readAll() {
    try {
      line = reader.readLine();
      header = split(line, delim);
      rows = int(float(header[0]));
      cols = int(float(header[1]));
      dt =  float(header[2]);
      data = new float[rows][cols];
    }
    catch (Exception e) {
      println("Error - Bad Header");
      println(rows);
      e.printStackTrace();
    }
    if (verbose) {
      println("#Rows: " + rows + "  #Cols: " + cols + "  dt: " + dt);
    }
    for (int i=0; i<rows; i++) {
      try {
        line = reader.readLine();
      } 
      catch (Exception e) {
        println("Error - Ran out of Data");
        e.printStackTrace();
      }
      String[] pieces = split(line, delim);
      for (int j=0; j<cols; j++) {
        dat = float(pieces[j]);
        if (verbose) {
          println("Row: " + i + "  Col: " + j + "  t: " + i*dt + "  Data: " + dat + "#Rows: " + rows);
        }
        data[i][j] = dat;
      }
    }
  }
  float interpolate(float t, int column) {
    int index = floor(t/dt)%rows;
    int next = ceil(t/dt)%rows;
    if (verbose) {
      println("Index: " + index + "  Next: " + next + "  t: " + t + "  Column: " + column);
    }
    if (column>=cols || column<0) {
      throw new Error("Requested data column not within data");
    }

    if (index==next) {
      return data[index][column];
    }

    float slope = (data[next][column]-data[index][column])/dt;
    return data[index][column]+(t%(dt*rows)-index*dt)*slope;
  }
} 

