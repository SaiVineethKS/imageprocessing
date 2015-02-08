//This is the code for the image processing
import gab.opencv.*;
import processing.video.*;
import java.awt.Point;
PImage img;
OpenCV opencv;
Histogram histogram;
Capture video;
int lowerb = 16;//18
int upperb = 30;//55
ArrayList<Line> lines;

void setup() {
  video = new Capture(this, 640, 480);
  img = loadImage("tote.jpg");
  //opencv = new OpenCV(this, img.width, img.height);
  opencv = new OpenCV(this, video.width, video.height);
  size(opencv.width, opencv.height);
  opencv.useColor(HSB);
  video.start();
}

void draw() {
  background(100);
  if (video.available()) {
    video.read();
  }

  // <2> Load the new frame of our movie in to OpenCV
  opencv.loadImage(video);
  //opencv.loadImage(img);
  //image(opencv.getSnapshot(), 0, 0); 
  // opencv.blur(100);  
  
  
  opencv.useColor(HSB);
  opencv.setGray(opencv.getH().clone());
  opencv.inRange(lowerb, upperb);
  
  opencv.blur(12);
  opencv.threshold(230);
  opencv.dilate();
  opencv.dilate();
  opencv.dilate();
  opencv.dilate();
  opencv.dilate();
  opencv.dilate();
  //image(img, 0, 0);
  image(video, 0, 0);
  image(opencv.getOutput(), 3*width/4, 3*height/4, width/4,height/4);
  opencv.findCannyEdges(2,10);//edge
  opencv.blur(2);//These clean 
  opencv.dilate();
  histogram = opencv.findHistogram(opencv.getH(), 255);
  lines = opencv.findLines(100, 40, 5);
  
    
  
  noStroke(); fill(45,23,12);
  histogram.draw(10, height - 230, 400, 200);
  noFill(); stroke(0);
  line(10, height-30, 410, height-30);

  text("Hue", 10, height - (textAscent() + textDescent()));

  float lb = map(lowerb, 0, 255, 0, 400);
  float ub = map(upperb, 0, 255, 0, 400);

  stroke(255, 0, 0); fill(255, 0, 0);
  strokeWeight(2);
  line(lb + 10, height-30, ub +10, height-30);
  ellipse(lb+10, height-30, 3, 3 );
  text(lowerb, lb-10, height-15);
  ellipse(ub+10, height-30, 3, 3 );
  text(upperb, ub+10, height-15);
  drawLines();
}

/*void mouseMoved() {
  if (keyPressed) {
    upperb += mouseX - pmouseX;
  } 
  else {
    if (upperb < 255 || (mouseX - pmouseX) < 0) {
      lowerb += mouseX - pmouseX;
    }
    if (lowerb > 0 || (mouseX - pmouseX) > 0) {
      upperb += mouseX - pmouseX;
    }
  }
  upperb = constrain(upperb, lowerb, 255);
  lowerb = constrain(lowerb, 0, upperb-1);
}*/

void mousePressed() {
    color c = get(mouseX, mouseY);
    int hue = int(map(hue(c), 0, 255, 0, 180));
    int range = 7;
    upperb = hue+range;
    lowerb = hue-range;
}



void drawLines(){
  Line twidth = null;
  Line theight = null;
  for (Line line : lines) {
    // lines include angle in radians, measured in double precision
    // so we can select out vertical and horizontal lines
    // They also include "start" and "end" PVectors with the position
    //println(degrees((float)line.angle));
    /*if (line.angle >= radians(0) && line.angle < radians(1)) {
      stroke(0, 255, 0);
      line(line.start.x, line.start.y, line.end.x, line.end.y);
    }
    if (line.angle > radians(89) && line.angle < radians(91)) {
      stroke(255, 0, 0);
      line(line.start.x, line.start.y, line.end.x, line.end.y);
    }*/
    
    if(inRange(errorAngle(degrees((float)line.angle), 0), -45, 45)){//width
      if(twidth == null) twidth = line;
      if(distance(line) > distance(twidth)) twidth = line;
      stroke(255, 0, 0);
    }
    else {//height
    if(theight == null) theight = line;
    if(distance(line) > distance(theight)) theight = line;
      stroke(0, 255, 0);
    }
    //line(line.start.x, line.start.y, line.end.x, line.end.y);
    //println(distance(line));
  }
  if(twidth != null){
    stroke(255, 0, 0);
    println(degrees((float)twidth.angle));
    line(twidth.start.x, twidth.start.y, twidth.end.x, twidth.end.y);
  }
  if(theight != null){
    stroke(0, 255, 0);
    //println(errorAngle(degrees((float)theight.angle), 0));
    line(theight.start.x, theight.start.y, theight.end.x, theight.end.y);
  }
}


float distance(Line line){
  return sqrt((line.start.x-line.end.x)*(line.start.x-line.end.x)+(line.start.y-line.end.y)*(line.start.y-line.end.y));
}

boolean inRange(double num, double lower, double upper){
 return num <= upper && num >= lower ;
}

double errorAngle(float angle1, float angle2){
 while(abs(angle1-angle2) > abs(angle1-180-angle2)) {
  angle1 -= 180; 
 }
 return angle2-angle1;
}

