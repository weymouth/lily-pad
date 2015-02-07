/********************************************************
A 'standalone' program which draws various wing paths for flapping flight/swimming.

The user can control certain parameters in realtime to visualise what different stroke types look like. 

A work in progress, trying to calculate velocities and accelerations but not sure if my maths is correct :/

It can also be used to draw pretty pictures...

Example code:

WingTestKinematics wing1;

void setup() {

//Initialise the object - define starting values of variables.

int windowsize = 4;
 
float phasesurge = 0; //phase difference between heave and surge
float strokeplaneangle = 0; //stroke plane angle, clockwise from vertical


float chordm = 0.1; //Chord length of foil in m
float chord = 100 * chordm * windowsize;// Chord length of foil in pixels

float xampm = 0.10; //surge amplitude in m
float yampm = 0.50; //heave amplitude in m

float xamp = 100*xampm*windowsize; //surge amplitude in pixels
float yamp = 100*yampm*windowsize; //heave amplitude in pixels

float xpos0 = 0.5; //Starting xpos of foil in percentage of screen
float ypos0 = 0.5; //Starting ypos of foil in percentage of screen

float frequency = 1; // Number of revolutions per second
float omega = 2 * PI * frequency;  //radians per second

size(windowsize*300, windowsize*200); //The window size always represents 2m by 3m
background(255);
  wing1 = new WingTestKinematics(xamp, yamp, xpos0, ypos0, chord, phasesurge, strokeplaneangle, 2, windowsize, omega);

}

void draw() {
  
// Call methods on the object
  wing1.fly();
  wing1.display();

}

*********************************************************/

class WingTestKinematics {
  color c;
  float xpos, ypos, xposm, yposm, xpos0, ypos0, xspeed, yspeed, xacc, yacc, xamp, yamp;
  float chord, t=0, phasesurge, strokeplaneangle, omega;
  int stroketype, windowsize;
 
  
  WingTestKinematics(float xamp, float yamp, float xpos0, float ypos0, float chord, float phasesurge, float strokeplaneangle, int stroketype, int windowsize, float omega){
    this.xamp = xamp;
    this.yamp = yamp;
    this.xpos0 = xpos0;
    this.ypos0 = ypos0;
    this.chord = chord;
    this.phasesurge = phasesurge;
    this.strokeplaneangle = strokeplaneangle;
    this.stroketype = stroketype;
    this.windowsize = windowsize;
    this.omega = omega;
    
    c = color(255);
    xspeed = 1;
    yspeed = 1;

    }
  
//The fly method. 
  void fly() {
    
//Define time
    t = t + 0.01;

    
    //phasesurge = phasesurge+0.01; // Use this to constantly change the phase
    
//Calculate current x and y positions IN PIXELS

    ypos   = ypos0*height - yamp*sin(omega*t);
    
    xpos   = xpos0*width + xamp*sin((stroketype*omega*t)+phasesurge) + (ypos0*height-ypos)*atan(strokeplaneangle);  
    
//Calculate current x and y positions IN METRES
    yposm   = ypos0*2 - (yamp*sin(omega*t))/(100*windowsize);
    
    xposm  = xpos0*3 + (xamp*sin((stroketype*omega*t)+phasesurge))/(100*windowsize) + (ypos0*height-ypos)*atan(strokeplaneangle)/(100*windowsize);  
    
//Calculate current x and y speeds    
   // yspeed = -yamp*omega*cos(omega*t);
    
    //xspeed = xamp*stroketype*omega*cos((stroketype*omega*t)+phasesurge);
    
//Calculate current x and y accelerations - I don't think these are correct

   // yacc   = yamp*sq(omega)*sin(omega*t);
    
    //xacc   = -xamp*sq(stroketype*omega)*sin((stroketype*omega*t)+phasesurge);


 
//Enable user to adjust parameters
// -LEFT and RIGHT arrows increase and decrease the stroke plane angle
// -UP and DOWN increase and decrease the heave amplitude, which also affects the surge amplitude due to the stroke plane angle
// -ALT and CONTROL increase and decrease the width of the figure-8
//'W' and 'C' adjust the phase of the surge with respect to the heave.

    if (keyPressed){
      if (key == 'c') {
        background(255);
      }
      if (key == 'w') {
        phasesurge = phasesurge+0.01;
      }
      if (key == 's') {
        phasesurge = phasesurge-0.01;
      }
      if (key == CODED) {
                if (keyCode == LEFT){
                strokeplaneangle = strokeplaneangle+0.01;
                }
                if (keyCode == RIGHT){
                strokeplaneangle = strokeplaneangle-0.01;
                }
                if (keyCode == UP){
                yamp = yamp+.1;
                }
                if (keyCode == DOWN){
                yamp = yamp-.1;
                }
                if (keyCode == ALT){
                xamp = xamp+.1;
                }
                if (keyCode == CONTROL){
                xamp = xamp-.1;
                }
              }
          } 
          println("t = "+t +", heaveamp = "+ yamp +  ", strokeplaneangle = " + strokeplaneangle + ", phasesurge = " + phasesurge + ", xposm = " + xposm + ", yposm = " +yposm);
  }      
    
   
     
  void display() {
  // background(100, 200, 255, 10);
    ellipseMode(CENTER);
    
    noStroke();
    fill((ypos0*height-ypos)+random(50), ypos*200/height+random(50), 150+100*sin(t), 50);
    ellipse(xpos, ypos, chord, chord/4);
    
   // ellipse(xpos, ypos+5, chord/2, chord/8);
   // ellipse(xpos, ypos-5, chord/2, chord/8);
    
 
  }
 }
