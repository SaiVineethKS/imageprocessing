//This is the code for the image processing
import gab.opencv.*;
import processing.video.*;
import java.awt.Point;
import java.awt.Rectangle;
PImage img;
OpenCV opencv;
Histogram histogram;
Capture video;
int lowerb = 116;//18 
int upperb = 124;//55 //124
ArrayList<Line> lines;
ArrayList<Contour> contours;

PImage ncc(PImage img){
  img.loadPixels();
  float avgR = 0;
  float avgG = 0;
  float avgB = 0;
  for(int i =0; i < img.width * img.height; i++){
   color c = img.pixels[i];
   float red = red(c);
   float green = green(c);
   float blue = blue(c);
   avgR+=red;
   avgG+=green;
   avgB+=blue;  
  }
  avgR/=img.width * img.height;
  avgG/=img.width * img.height;
  avgB/=img.width * img.height;
  float stdR = 0;
  float stdG = 0;
  float stdB = 0;
  for(int i =0; i < img.width * img.height; i++){
    color c = img.pixels[i];
   float red = red(c);
   float green = green(c);
   float blue = blue(c);
   stdR += (red-avgR)*(red-avgR);
   stdG += (green-avgG)*(green-avgG);
   stdB += (blue-avgB)*(blue-avgB);
  }
  stdR/=(img.width * img.height)*(img.width * img.height);
  stdG/=(img.width * img.height)*(img.width * img.height);
  stdB/=(img.width * img.height)*(img.width * img.height);
  PImage result = createImage(img.width, img.height, RGB);
  for(int i =0; i < img.width * img.height; i++){
    color c = img.pixels[i];
   float red = (red(c)-avgR)/stdR;
   float green = (green(c)-avgG)/stdG;
   float blue = (blue(c)-avgB)/stdB;
   red = constrain(red, 0, 255);
   green = constrain(green, 0, 255);
   blue = constrain(blue, 0, 255);
   result.pixels[i] = color(red, green, blue);
  }
  result.updatePixels();
  return result;
}

void setup() {
  frameRate(20);
  video = new Capture(this, 640, 480);
  img = loadImage("tote.jpg");
  //opencv = new OpenCV(this, img.width, img.height);
  opencv = new OpenCV(this, video.width, video.height);
  size(opencv.width, opencv.height);
  opencv.useColor(HSB);
  video.start();
}

void draw() {
  
  if (video.available()) {
    background(100);
    video.read();
  img = ncc(video);
  // <2> Load the new frame of our movie in to OpenCV
  opencv.loadImage(img);
  //opencv.loadImage(img);
  //image(opencv.getSnapshot(), 0, 0); 
  // opencv.blur(100);  
  
  
  opencv.useColor(HSB);
  opencv.setGray(opencv.getH().clone());
  opencv.inRange(lowerb, upperb);
  
  opencv.blur(12);
  opencv.threshold(230);//230
  opencv.dilate();
  opencv.dilate();
  opencv.dilate();//wtf
  opencv.dilate();
  opencv.dilate();
  opencv.dilate();
  image(img, 0, 0);
  
  image(opencv.getOutput(), 3*width/4, 3*height/4, width/4,height/4);
  opencv.findCannyEdges(2,10);//edge
    opencv.blur(2);//These clean 
    opencv.dilate();
  //image(img, 0, 0);
  
  
  contours = opencv.findContours(true,true);
  if(contours.size() != 0){
  Rectangle rect = contours.get(0).getBoundingBox();
  for (int i=0; i<contours.size(); i++) {
    Contour contour = contours.get(i);
    Rectangle r = contour.getBoundingBox();
    if (r.width < 20 || r.height < 20)
      continue;
    if(r.getHeight()*r.getWidth() > rect.getHeight()*rect.getWidth()) rect = r;
  }
    stroke(255, 0, 0);
    fill(255, 0, 0, 150);
    strokeWeight(2);
    //println("RECT"+rect.width);
    
    float ratio = 0.2;
    int x = (int)constrain(rect.x - rect.width*ratio/2, 0, width);
    int rectWidth = (int)constrain(rect.width+rect.width*ratio, 0, width);
    int y = (int)constrain(rect.y - rect.height*ratio/2, 0, height);
    int rectHeight = (int)constrain(rect.height+rect.height*ratio, 0, height);
    
    //println(rectWidth);
    //rect(x, y, rectWidth, rectHeight);
    //PImage tote = img.get(x, y, rectWidth, rectHeight);
    //tote = ncc(tote);
    /*image(tote, x, y);
    opencv.loadImage(tote);
    opencv.useColor(RGB);
  opencv.setGray(opencv.getB().clone());
  int nlowerb = mouseX-7;
  int nupperb = mouseX+7;
  opencv.inRange(lowerb, lowerb);
  println(mouseX);  
  opencv.blur(12);
  opencv.threshold(5);//230
  opencv.dilate();
  opencv.dilate();
  opencv.dilate();//wtf
  opencv.dilate();
  opencv.dilate();
  opencv.dilate();
  image(opencv.getOutput(), 3*tote.width/4, 3*tote.height/4, tote.width/4,tote.height/4);
    //println(tote.width);
    opencv.findCannyEdges(2,10);//edge
    opencv.blur(2);//These clean 
    opencv.dilate();*/
    
    lines = opencv.findLines(100, 40, 50);
    histogram = opencv.findHistogram(opencv.getH(), 255);
    drawHistogram();
    drawLines();
  }
  }
  
  
  
  
    
  
  
} //End of draw

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

void drawHistogram(){
  noStroke(); fill(45,23,12);
  histogram.draw(10, height - 230, 400, 200);
  noFill(); stroke(0);
  line(10, height-30, 410, height-30);
  textSize(10);
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
  } 

void mousePressed() {
    //color c = get(mouseX, mouseY);
    color c = img.get(mouseX, mouseY);
    int hue = int(map(hue(c), 0, 255, 0, 180));
    int range = 2;
    upperb = hue+range;
    lowerb = hue-range;
}



void drawLines(){
  Line twidth = null;
  Line theight = null;
  Line tside = null;
  for (Line line : lines) {

  if(inRange(errorAngle(degrees((float)line.angle),0) , -12, 12)){//height
    if(theight == null)
      theight = line;
    if(distance(line) > distance(theight))
      theight = line;
  }
  /*else{//width
    if(twidth == null)
      twidth = line;
    if(distance(line) > distance(twidth))
      twidth = line;
  }*/
    
  }
  fill(0, 255, 0);
  textSize(32);
  if(theight != null)
  for(Line line: lines){
    if(!inRange(errorAngle(degrees((float)line.angle),0) , -12, 12) && middle(line).y>middle(theight).y){//width. bigger and not msaller because reverse starting point of cooardinates.
    if(twidth == null)
      twidth = line;
    if(distance(line) > distance(twidth))
      twidth = line;
    }
    //println("height: " + abs(theight.end.y-theight.start.y));
    float heightOfTote = abs(theight.end.y-theight.start.y);
    float distance = 10404*pow(heightOfTote, -0.88);
    text("Distance " + distance, 20, 40);
    //println(distance);
    
  }
  if(twidth != null && theight != null)
  for(Line line: lines){
     if(errorAngle(degrees((float)line.angle), degrees((float)twidth.angle)) > 20 && !inRange(errorAngle(degrees((float)line.angle),0) , -12, 12) && abs(middle(line).y-middle(twidth).y) < distance(theight)*0.8){
       if(tside == null)
         tside = line;
       if(distance(line) > distance(tside))
         tside = line;
     }
  }
  /*if(twidth != null && theight != null && tside != null){
  int leftX = (int)min(getLeftPoint(twidth).x, getLeftPoint(tside).x);
  int rightX = (int)max(getRightPoint(twidth).x, getRightPoint(tside).x);
  int lowY, highY;
  lowY = (int)max(theight.end.y, theight.start.y);
  highY = (int)min(theight.end.y, theight.start.y);
  PImage tote = video;
  tote.copy(leftX, highY, rightX-leftX, highY-lowY, 0, 0, rightX-leftX, highY-lowY);
  println(tote.width);
  }*/
  float angle = 0;
  if(twidth!=null&&tside!=null){
     
     float ratio = errorAngle(degrees((float)tside.angle), degrees((float)twidth.angle));
     angle = -0.083*ratio*ratio+2.666*ratio+40;
  }else if(twidth!=null & theight!=null){
      float ratio = distance(theight)/distance(twidth);
      if(ratio > 0.7) angle = 0;
      else angle = 90;
  }
  
  text("Angle " + angle, 20, 100);
  //draw
  if(twidth != null){
    stroke(255, 0, 0);
    //println(degrees((float)twidth.angle));
    line(twidth.start.x, twidth.start.y, twidth.end.x, twidth.end.y);
  }
  
  if(tside != null){
    stroke(0, 0, 255);
    //println(degrees((float)tside.angle));
    //println(errorAngle(degrees((float)twidth.angle), degrees((float)tside.angle)));
    line(tside.start.x, tside.start.y, tside.end.x, tside.end.y);
  }
  
  if(theight != null){
    stroke(0, 255, 0);
    //println(degrees((float)theight.angle));
    
    //println(errorAngle(degrees((float)theight.angle), 0));
    line(theight.start.x, theight.start.y, theight.end.x, theight.end.y);
  }
  
}

PVector getLeftPoint(Line line)
{
  if(line.end.x < line.start.x)
    return line.end;
  else
    return line.start;
}

PVector getRightPoint(Line line)
{
  if(line.end.x > line.start.x)
    return line.end;
  else
    return line.start;
}

float distance(Line line){
  return sqrt((line.start.x-line.end.x)*(line.start.x-line.end.x)+(line.start.y-line.end.y)*(line.start.y-line.end.y));
}

Point middle(Line line){
  return new Point((int)(line.start.x+line.end.x)/2, (int)(line.start.y+line.end.y)/2);
}
//middle y cant be largr than a*height. a<=1
float distance(Point p1, Point p2){
  return sqrt((p2.x-p1.x)*(p2.x-p1.x)+(p2.y-p1.y)*(p2.y-p1.y)); 
}

boolean inRange(double num, double lower, double upper){
 return num <= upper && num >= lower ;
}

float errorAngle(float angle1, float angle2){
  float minAngle = min(angle1, angle2);
  float maxAngle = max(angle1, angle2);
 while(abs(maxAngle-minAngle) > abs(maxAngle-180-minAngle)) {
  maxAngle -= 180; 
 }
 return minAngle-maxAngle;
}

boolean isLeft(Line l1, Line l2){
  return middle(l1).x < middle(l2).x; 
}

boolean isShorterX(Line l1, Line l2){
  return abs(l1.end.x-l1.start.x) < abs(l2.end.x-l2.start.x);
}

