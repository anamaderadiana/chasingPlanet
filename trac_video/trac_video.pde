// COLOR TRACKING + VIDEO
 
import gab.opencv.*;
import processing.video.*;
import java.awt.Rectangle;
import processing.video.*;

Capture video;
OpenCV opencv;
PImage src, colorFilteredImage;
ArrayList<Contour> contours;

Movie movie;

// <1> Set the range of Hue values for our filter
int rangeLow = 20;
int rangeHigh = 35;

float posAnteriorX = 0;
float posAnteriorY = 0;
boolean pintaelrastre = false;
boolean socelprimertrac = true;

int pos = 0;
float[] posicionsX = new float[10000];
float[] posicionsY = new float[10000];

void setup() {
  video = new Capture(this, 640, 480, "Cámara Logitech #2");
  video.start();
  
  opencv = new OpenCV(this, video.width, video.height);
  contours = new ArrayList<Contour>();
  
  // Load and play the video in a loop
  movie = new Movie(this, "Space_Fly_Through_1.mov");
  movie.loop();
  
  size(3*opencv.width, opencv.height, P2D);
  background(255);
}

void movieEvent(Movie m) {
  m.read();
}

void draw() {
  
  // Read last captured frame
  if (video.available()) {
    video.read();
  }

  // <2> Load the new frame of our movie in to OpenCV
  opencv.loadImage(video);
  
  // Tell OpenCV to use color information
  opencv.useColor();
  src = opencv.getSnapshot();
  
  // <3> Tell OpenCV to work in HSV color space.
  opencv.useColor(HSB);
  
  // <4> Copy the Hue channel of our image into 
  //     the gray channel, which we process.
  opencv.setGray(opencv.getH().clone());
  
  // <5> Filter the image based on the range of 
  //     hue values that match the object we want to track.
  opencv.inRange(rangeLow, rangeHigh);
  
  // <6> Get the processed image for reference.
  colorFilteredImage = opencv.getSnapshot();
  
  ///////////////////////////////////////////
  // We could process our image here!
  // See ImageFiltering.pde
  ///////////////////////////////////////////
  
  // <7> Find contours in our range image.
  //     Passing 'true' sorts them by descending area.
  contours = opencv.findContours(true, true);
  
  // <8> Display background images
  image(src, 0, 0);
  image(colorFilteredImage, src.width, 0);
  
  // <9> Check to make sure we've found any contours
  if (contours.size() > 0) {
    // <9> Get the first contour, which will be the largest one
    Contour biggestContour = contours.get(0);
    
    // <10> Find the bounding box of the largest contour,
    //      and hence our object.
    Rectangle r = biggestContour.getBoundingBox();
    
    // <11> Draw the bounding box of our object
    noFill(); 
    strokeWeight(2); 
    stroke(255, 0, 0);
    rect(r.x, r.y, r.width, r.height);
    
    // <12> Draw a dot in the middle of the bounding box, on the object.
    noStroke(); 
    fill(255, 0, 0);
    ellipse(r.x + r.width/2, r.y + r.height/2, 30, 30);
    
    // video
    image(movie, 2*opencv.width, 0, opencv.width, opencv.height);
    
    // pinta el rastre
    if(pintaelrastre == true){
      if(pos < 10000){
        posicionsX[pos] = r.x + r.width/2;
        posicionsY[pos] = r.y + r.height/2;
        
        if(socelprimertrac == false){
          // es podria filtrar per distancia
          stroke(255,100);
          strokeWeight(5);
          //line(2*opencv.width + posAnteriorX, posAnteriorY, 2*opencv.width + r.x + r.width/2, r.y + r.height/2);
          for(int i=1; i<pos; i=i+1){
            line(2*opencv.width + posicionsX[i-1], posicionsY[i-1],2*opencv.width + posicionsX[i], posicionsY[i]);
          }
        }
        
        fill(255, random(120,200));
        noStroke();
        //ellipse(2*opencv.width + posAnteriorX, posAnteriorY, 5, 5);
        for(int i=0; i<pos; i=i+1){
          for(int p=0; p<10; p=p+1){
            ellipse(2*opencv.width + posicionsX[i] + random(-5,5), posicionsY[i] + random(-5,5), 2, 2);
          }
        }
        //posAnteriorX = r.x + r.width/2;
        //posAnteriorY = r.y + r.height/2;
        socelprimertrac = false;
        pos = pos + 1;
      }
    }
  }
}

void mousePressed() {
  color c = get(mouseX, mouseY);
  println("r: " + red(c) + " g: " + green(c) + " b: " + blue(c));
   
  int hue = int(map(hue(c), 0, 255, 0, 180));
  println("hue to detect: " + hue);
  
  rangeLow = hue - 2;
  rangeHigh = hue + 2;
  
  pintaelrastre = true;
}

void keyPressed(){
  pos = 0;  
}
