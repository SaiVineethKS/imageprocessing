/*
Todo List:

Problems:
1. Distance from center ossilating - 10 to 40 , blue line moving.
instead of tsides for center distance - twidth.

2. Main noise reduction.

*/



//This is the code for the image processing
import gab.opencv.*;
import processing.video.*;
import java.awt.Point;
import java.awt.Rectangle;
PImage img;
OpenCV opencv;
Histogram histogram;
Capture video;
int lowerb = 109;//18 
int upperb = 121;//55 //124
ArrayList<Line> lines;
ArrayList<Contour> contours;
float angles[] = new float[5];



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
  
  opencv.blur(12);//12
  opencv.threshold(230);//230
  opencv.dilate();
  opencv.dilate();
  opencv.dilate();//wtf
  opencv.dilate();
  opencv.dilate();
  opencv.dilate();
  image(img, 0, 0);
  
  image(opencv.getOutput(), 3*width/4, 0*height/4, width/4,height/4);
  
  try{
    image(getBounds(opencv.getOutput(),0.1),0,0,width/5,height/5);//small - only tote
    
    //
    
    
    //println(highest(getBounds(opencv.getOutput(),0.1)));
    /*
    Point highest = highest(getBounds(opencv.getOutput(),0.1));
    Point lowest = lowest(getBounds(opencv.getOutput(),0.1));
    
    stroke(255,0,0);
    rect(highest.x-10,highest.y-10,20,20);
    
    rect(lowest.x-10,lowest.y-10,20,20);
    stroke(255,255,0);
    line(highest.x,highest.y,lowest.x,lowest.y);
    */
  }
  catch(NullPointerException npe){
  }
  
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
    PImage tote = img.get(x, y, rectWidth, rectHeight);
    //tote = ncc(tote);
    
    
    lines = opencv.findLines(100, 1, 50);
    histogram = opencv.findHistogram(opencv.getH(), 255);
    drawHistogram();
    drawLines();
    
    
    text((int)frameRate+"FPS",400,50);
  }
  }
  
  
  
  //getLogo(getBounds(opencv),opencv);
    
  
  
} //End of draw



void mousePressed() {
    //color c = get(mouseX, mouseY);
    color c = img.get(mouseX, mouseY);
    int hue = int(map(hue(c), 0, 255, 0, 180));
    int range = 6;
    upperb = hue+range;
    lowerb = hue-range;
}




//float avg


void drawLines(){
  
  
  
  Line longestWidth = longestWidth(lines);//eXcEpTiOn
  Line longestHeight = longestHeight(lines);
  
  
  try{
  line(longestWidth.start.x, longestWidth.start.y, longestWidth.end.x, longestWidth.end.y);
  stroke(0,255,0);
  line(longestHeight.start.x, longestHeight.start.y, longestHeight.end.x, longestHeight.end.y);
  textSize(32);
  text(degrees((float)longestWidth.angle)+"°",50,50);//Angle
  text(abs(getSlope(longestHeight)),50,125);//Distance
  }
  catch(NullPointerException npe){
    println("eXcEpTiOn");
  }
  
  
  
  
  //println(maxY);
} //End of draw lines

PVector getLeftPoint(Line line){
  if(line.end.x < line.start.x)
    return line.end;
  else
    return line.start;
}

PVector getRightPoint(Line line){
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
//middle y can't be larger than a*height. a<=1
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



//Nir's functions
int x, rectWidth, y, rectHeight;
PImage getBounds(PImage pi,float ratio) { //Return rectangle with edges of tote
  PImage tote = null;
  //PI
  
  contours = opencv.findContours(true,true);
  Rectangle rect = null;
  if(contours.size() != 0){
  rect = contours.get(0).getBoundingBox();
  for (int i=0; i<contours.size(); i++) {
    Contour contour = contours.get(i);
    Rectangle r = contour.getBoundingBox();
    if (r.width < 20 || r.height < 20)
      continue;
    if(r.getHeight()*r.getWidth() > rect.getHeight()*rect.getWidth()) rect = r;
  }
    
    //println("RECT"+rect.width);
    
    //float ratio = 0.2;
    x = (int)constrain(rect.x - rect.width * ratio/2, 0, width);
    rectWidth = (int)constrain(rect.width + rect.width * ratio, 0, width);
    y = (int)constrain(rect.y - rect.height * ratio/2 , 0, height);
    rectHeight = (int)constrain(rect.height + rect.height * ratio, 0, height);
    
    rect = new Rectangle(x, y, rectWidth, rectHeight);
    fill(255,0,0,0);
    rect(x,y,rectWidth,rectHeight);
    
    //println(rect.width);
    //println(rect.width());
    
    //tote = img.get(x, y, rectWidth, rectHeight);
    
    //tote = opencv.getOutput().get(x, y, rectWidth, rectHeight);
    tote = pi.get(x, y, rectWidth, rectHeight);
    
    //getLogo(getBounds(opencv),opencv);
  }
  //return rect;
  
  return tote;
  
  
}

//opencv.getOutput()
Point highest(PImage pi){
  for(int i = 0; i<pi.width*pi.height; i++)
  {
    color c = pi.pixels[i];
    if(red(c) != 0 && green(c) != 0 && blue(c) != 0)
    {
      println(i+"White " + red(c) + " " + green(c) + " " + blue(c));
      int highy = i / pi.width;
      int highx = i % pi.width;
      println("X: " + highx);
      println("Y: " + highy);
      
      return new Point(x + highx , y + highy);
    }
  }
  
  return null;
}

Point lowest(PImage pi){
  for(int i = pi.width*pi.height-1; i>=0; i--)
  {
    color c = pi.pixels[i];
    if(red(c) != 0 && green(c) != 0 && blue(c) != 0)
    {
      println(i+"White " + red(c) + " " + green(c) + " " + blue(c));
      int highy = i / pi.width;
      int highx = i % pi.width;
      println("X: " + highx);
      println("Y: " + highy);
      return new Point(x +highx,y+ highy);
    }
    
  }
  
  return null;
}


//Noise reduction on height line
//Find if logo is right of blue line
//Slope of red line for angle
//For logo find black blobe mabye add filters to make it more "binary"

Rectangle getLogo(PImage tote, OpenCV opencv){//Find First logo within the tote rectangle
  //final float black = 10;//constant
  //for(int i = 0; i>
  
  //crop rectangle out of image and then afterwards crop logo out of it
  
  tote.loadPixels();
  
  
  
  for(int i = 0; i<tote.width*tote.height; i++)
  {
    color c = img.pixels[i];
    // < black && green(c) < black && blue(c) < black
    //println("hello");
  }
  
  //if(red(c) > 
  
  //println(img.pixels[0]);
  
  return null;
}


//int avgDistance = 0;
Line longestWidth(ArrayList<Line> lines){
  
  float maxY = 0;//I don't wanna confuse but it's acctually the lowest
  Line lowestLine = null;
  
  for (Line line : lines) {
    //Find angle from horizon
    println(line.angle);
    //Angles and distance
    if(maxY<line.start.y){
      maxY = line.start.y;
      lowestLine = line;
    }
    
    //line(line.start.x, line.start.y, line.end.x, line.end.y);
    //Y is lowest and line is longest
  }
  
  return lowestLine;
}



Line longestHeight(ArrayList<Line> lines){
  
  float maxY = 0;//I don't wanna confuse but it's acctually the lowest
  Line lowestLine = null;
  Line theight = null;
  
  for (Line line : lines) {
    //Find angle from horizon
    
    if(inRange(errorAngle(degrees((float)line.angle),0) , -12, 12)){//height
      if(theight == null)
        theight = line;
      if(distance(line) > distance(theight))
        theight = line;
    }
    
    //Y is lowest and line is longest
  }
  return theight;
}








float getSlope(Line l){
  //y2 - y1 / x2 - x1
  return ((l.end.y - l.start.y) / (l.end.x - l.start.x))*90;
}


















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
  float minR = 255, maxR = -255;
  float minG = 255, maxG = -255;
  float minB = 255, maxB = -255;
  for(int i =0; i < img.width * img.height; i++){
    color c = img.pixels[i];
   float red = (red(c)-avgR)/stdR;
   float green = (green(c)-avgG)/stdG;
   float blue = (blue(c)-avgB)/stdB;
   minR = min(minR, red);
     maxR = max(maxR, red);
     minG = min(minG, red);
     maxG = max(maxG, red);
     minB = min(minB, red);
     maxB = max(maxB, red);
  }
  for(int i =0; i < img.width * img.height; i++){
    color c = img.pixels[i];
   float red = (red(c)-avgR)/stdR;
   float green = (green(c)-avgG)/stdG;
   float blue = (blue(c)-avgB)/stdB;
   float newR = map(red, minR, maxR, 0, 255);
   float newG = map(green, minG, maxG, 0, 255);
   float newB = map(blue, minB, maxB, 0, 255);
    result.pixels[i] = color(newR, newG, newB);
  }
  result.updatePixels();
  return result;
}



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



