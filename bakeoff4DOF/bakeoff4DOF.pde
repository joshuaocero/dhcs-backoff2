import java.util.ArrayList;
import java.util.Collections;

float mouseOffsetX = 0.0;
float mouseOffsetY = 0.0;

int index = 0;

//your input code should modify these!!
float screenTransX = 0;
float screenTransY = 0;
float screenRotation = 0;
float screenZ = 50f;

int trialCount = 4; //this will be set higher for the bakeoff
float border = 0; //have some padding from the sides
int trialIndex = 0; //what trial are we on
int errorCount = 0;  //used to keep track of errors
float errorPenalty = 0.5f; //for every error, add this to mean time
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false;

//Size Slider properties
float s_sliderSize = 40;
float s_sliderX;
float s_sliderY;
boolean s_sliderSelected = false;
float s_sliderInitialX = s_sliderX;
float s_sliderInitialY = s_sliderY;

//Rotation slider properties
float r_sliderSize = 40;
float r_sliderX;
float r_sliderY;
boolean r_sliderSelected = false;
float r_sliderInitialX = r_sliderX;
float r_sliderInitialY = r_sliderY;

float s_distance = 0;
float r_distance = 0;
float t_roation_float = 0;
float scr_rotation_float = 0;

final int screenPPI = 120; //what is the DPI of the screen you are using
//Many phones listed here: https://en.wikipedia.org/wiki/Comparison_of_high-definition_smartphone_displays 

private class Target
{
  float x = 0;
  float y = 0;
  float rotation = 0;
  float z = 0;
}

ArrayList<Target> targets = new ArrayList<Target>();

float inchesToPixels(float inch)
{
  return inch*screenPPI;
}

void resetSliders() {
  // OJ:
  // This offsets the slider from the center depending on the difference between the two box.
  // All the user has to do is slide to the center
  Target t = targets.get(trialIndex);
  s_distance = screenZ - t.z;
  s_sliderX = (width / 2) - ((50f-screenZ)+inchesToPixels(.01f)) + s_distance;
  s_sliderY = height - s_sliderSize / 2;
  
  // OJ:
  // This is meant to do the same as above but still under testing
  println("trolation: "+t.rotation);
  println("screen rolation: "+screenRotation);
  float x_tloc = t.rotation;
  if (t.rotation>180) x_tloc = t.rotation - 180;
  t_roation_float = (x_tloc/360f) * (width/2);
  scr_rotation_float = (screenRotation/360f) * (width/2);
  println("t_roation_float: "+t_roation_float);
  println("scr_rotation_float: "+scr_rotation_float);
  r_distance = t_roation_float - scr_rotation_float;  
  println("r_distance: "+r_distance);
  r_sliderX = (width / 2) - r_distance;
  r_sliderY = 0 + r_sliderSize / 2;
}

void setup() {
  //size does not let you use variables, so you have to manually compute this
  size(400, 700); //set this, based on your sceen's PPI to be a 2x3.5" area.
  
  rectMode(CENTER);
  textFont(createFont("Arial", inchesToPixels(.15f))); //sets the font to Arial that is .3" tall
  textAlign(CENTER);

  //don't change this! 
  border = inchesToPixels(.2f); //padding of 0.2 inches

  for (int i=0; i<trialCount; i++) //don't change this! 
  {
    Target t = new Target();
    t.x = random(-width/2+border, width/2-border); //set a random x with some padding
    t.y = random(-height/2+border, height/2-border); //set a random y with some padding
    t.rotation = random(0, 360); //random rotation between 0 and 360
    t.z = ((i%20)+1)*inchesToPixels(.15f); //increasing size from .15 up to 3.0"
    targets.add(t);
    println("created target with " + t.x + "," + t.y + "," + t.rotation + "," + t.z);
  }
  
  Collections.shuffle(targets); // randomize the order of the button; don't change this.
  resetSliders();
}

void draw() {

  background(60); //background is dark grey
  fill(200);
  noStroke();

  if (startTime == 0)
    startTime = millis();

  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, inchesToPixels(.2f));
    text("User had " + errorCount + " error(s)", width/2, inchesToPixels(.2f)*2);
    text("User took " + (finishTime-startTime)/1000f/trialCount + " sec per target", width/2, inchesToPixels(.2f)*3);
    text("User took " + ((finishTime-startTime)/1000f/trialCount+(errorCount*errorPenalty)) + " sec per target inc. penalty", width/2, inchesToPixels(.2f)*4);
    return;
  }

  //===========DRAW TARGET SQUARE=================
  pushMatrix();
  translate(width/2, height/2); //center the drawing coordinates to the center of the screen

  Target t = targets.get(trialIndex);


  translate(t.x, t.y); //center the drawing coordinates to the center of the screen
  translate(screenTransX, screenTransY); //center the drawing coordinates to the center of the screen

  rotate(radians(t.rotation));

  fill(255, 0, 0); //set color to semi translucent
  rect(0, 0, t.z, t.z);

  popMatrix();

  //===========DRAW TARGETTING SQUARE=================
  pushMatrix();
  translate(width/2, height/2); //center the drawing coordinates to the center of the screen
  rotate(radians(screenRotation));

  boolean checkCloseDist = dist(t.x,t.y,-screenTransX,-screenTransY)<inchesToPixels(.05f);
  boolean checkCloseRotation = calculateDifferenceBetweenAngles(t.rotation,screenRotation)<=5;
  boolean checkCloseSize = abs(t.z - screenZ)<inchesToPixels(.05f);
  
  fill(255, 128); //set color to semi translucent
  rect(0, 0, screenZ, screenZ);
 
  popMatrix();
    
  if (s_sliderSelected && checkCloseSize) {
     stroke(193, 255, 55, 180);
     strokeWeight(2);
  } else if (r_sliderSelected && checkCloseRotation) {
     stroke(88, 180, 220, 180);
     strokeWeight(2);
  } else if (checkCloseDist){    
      stroke(0, 255, 0);
      strokeWeight(2);    
  } else {
      stroke(255);
  }
  
  // OJ:
  // This is where the marker lines on the screen are drawn
  line(0, height/2, width, height/2);
  stroke(0);
  line(width/2, (height/2)+10, width/2, (height/2)-10);
  stroke(193, 255, 55, 180);
  line(s_sliderX, (height/2)+10, s_sliderX, (height/2)-10);  
  stroke(88, 180, 220, 180);
  line(r_sliderX, (height/2)+10, r_sliderX, (height/2)-10);
  
  scaffoldControlLogic(); //you are going to want to replace this!

  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchesToPixels(.5f));
}

void scaffoldControlLogic()
{
  noStroke();
  // Draw size slider
  fill(75, 75, 75, 240);
  rect(0, s_sliderY, 2 * width, s_sliderSize);
  fill(150, 150, 150, 255);
  textSize(30);
  text("SIZE", inchesToPixels(0.5f), s_sliderY + inchesToPixels(0.1f));
  fill(193, 255, 55, 180);
  rect(s_sliderX, s_sliderY, s_sliderSize, s_sliderSize);
  
  //Draw rotation slider
  fill(75, 75, 75, 240);
  rect(0, r_sliderY, 2 * width, r_sliderSize);
  fill(150, 150, 150, 255);
  textSize(30);
  text("ROTATION", inchesToPixels(0.8f), r_sliderY + inchesToPixels(0.1f));
  fill(88, 180, 220, 180);
  rect(r_sliderX, r_sliderY, r_sliderSize, r_sliderSize);
}

void mouseReleased()
{
  if (s_sliderSelected) {
    s_sliderSelected = false;
  }
  
  if (r_sliderSelected) {
    r_sliderSelected = false;
  }
  //check to see if user clicked middle of screen
  if (dist(width/2, height/2, mouseX, mouseY)<inchesToPixels(.5f))
  {
    if (userDone==false && !checkForSuccess())
      errorCount++;

    //and move on to next trial
    trialIndex++;
    try { 
      resetSliders(); 
    } catch (Exception e) {}

    screenTransX = 0;
    screenTransY = 0;

    if (trialIndex==trialCount && userDone==false)
    {
      userDone = true;
      finishTime = millis();
    }
  }
}

public boolean checkForSuccess()
{
	Target t = targets.get(trialIndex);	
	boolean closeDist = dist(t.x,t.y,-screenTransX,-screenTransY)<inchesToPixels(.05f); //has to be within .1"
  boolean closeRotation = calculateDifferenceBetweenAngles(t.rotation,screenRotation)<=5;
	boolean closeZ = abs(t.z - screenZ)<inchesToPixels(.05f); //has to be within .1"	
	
  println("Close Enough Distance: " + closeDist);
  println("Close Enough Rotation: " + closeRotation + "(dist="+calculateDifferenceBetweenAngles(t.rotation,screenRotation)+")");
	println("Close Enough Z: " + closeZ);
	
	return closeDist && closeRotation && closeZ;	
}

double calculateDifferenceBetweenAngles(float a1, float a2)
  {
     double diff=abs(a1-a2);
      diff%=90;
      if (diff>45)
        return 90-diff;
      else
        return diff;
 }
 
void mouseDragged() {
  if (s_sliderSelected) {
    float diffX = mouseX - s_sliderInitialX;
    //screenZ = max(0, screenZ + inchesToPixels(.01f) * diffX);
    println(width/2);
    if (diffX > 0) {
        screenZ++;
        s_sliderX = constrain(mouseX, 0, width);
        s_sliderInitialX = mouseX;
    }
    //if (screenZ > inchesToPixels(.1f)) {
        if (diffX < 0) {
            screenZ--;
            s_sliderX = constrain(mouseX, 0, width);
            s_sliderInitialX = mouseX;
        }
    //}
    
    
  } else if (r_sliderSelected) {
    float diffX = mouseX - r_sliderInitialX;
    //screenRotation = max(0, screenRotation + inchesToPixels(.01f) * diffX);
    if (diffX > 0) screenRotation++;
    if (diffX < 0) screenRotation--;
    r_sliderInitialX = mouseX;
    r_sliderX = constrain(mouseX, 0, width);
  } else {
    screenTransX=mouseX - mouseOffsetX;
    screenTransY=mouseY - mouseOffsetY;
  }
}

void mousePressed()
{
  if(mouseX >= s_sliderX - s_sliderSize && mouseX < s_sliderX + s_sliderSize && mouseY >= s_sliderY - s_sliderSize) { 
    s_sliderInitialX = mouseX;
    s_sliderSelected = true; 
  } else if (mouseX >= r_sliderX - r_sliderSize && mouseX < r_sliderX + r_sliderSize) {
    if (mouseY < r_sliderY + r_sliderSize) {
      r_sliderInitialX = mouseX;
      r_sliderSelected = true; 
    }
  } 
  
  mouseOffsetX = mouseX - screenTransX;
  mouseOffsetY = mouseY - screenTransY;  
}