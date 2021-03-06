
import org.openkinect.freenect.*;
import org.openkinect.freenect2.*;
import org.openkinect.processing.*;
import org.openkinect.tests.*;

Kinect2 kinect2;

// blob detection
import blobDetection.*;
import peasy.*;
PeasyCam cam;

float levels = 10;                    // number of contours
float factor = 0.75;                     // scale factor
float elevation = 70;                 // total height of the 3d model

float colorStart =  40;               // Starting degree of color range in HSB Mode (0-360)
float colorRange =  160;             // color range for screen viewing / can also be negative
//float colorRange =  360;             // color range for projection

// Array of BlobDetection Instances
BlobDetection[] theBlobDetection = new BlobDetection[int(levels)];

int [] newDepth;
int backgroundColor;
int backgroundColorChange;
  
void setup() {
  fullScreen(P3D);
  
  cam = new PeasyCam(this,200);
  colorMode(HSB);
  //colorMode(HSB,360,100,100);
 
  //init cameras
  kinect2 = new Kinect2(this);
  kinect2.initDepth();
  kinect2.initDevice();
  
  backgroundColor = 55;
  backgroundColorChange = 1;
}


void draw() {
  
  //BACKGROUND
  
  //earthy colors
  //background(backgroundColor, 100, 0);
    //background(0);
    
  //bright
  background(backgroundColor, 250, 50);
  
  //Increment the value of backgroundColor by the value of backgroundColorChange
  backgroundColor += backgroundColorChange;
  //The above line is equivalent to: backgroundColor = backgroundColor + backgroundColorChange;
  
  //Check if backgroundColor has surpassed our max or min
  // use 255 max for screen viewing, and 150 for projection
  if (backgroundColor > 150 || backgroundColor < 55){
    //Multiply the value of backgroundColorChange by -1, reversing the direction of change
    backgroundColorChange *= -1;
  }
  
  
  //DATA
  
  //read data in
  int [] rawDepth = kinect2.getRawDepth();
  
  
  //Computing Blobs with different thresholds 
  for (int l=0 ; l<levels ; l++) {
    theBlobDetection[l] = new BlobDetection(512, 424);
    theBlobDetection[l].setThreshold(l/levels);
    theBlobDetection[l].computeBlobs(rawDepth);
  }
  
  translate(-512*factor/2,-424*factor/2);

  for (int i=0 ; i<levels ; i++) {
    translate(0,0,elevation/levels);  
    drawContours(i);
  }
  
}

void drawContours(int i) {
  Blob b;
  EdgeVertex eA,eB;
  for (int n=0 ; n<theBlobDetection[i].getBlobNb() ; n++) {
    b=theBlobDetection[i].getBlob(n);
    if (b!=null) {
      //stroke(255);
      strokeWeight(1.5);
      //original color
      stroke((i/levels*colorRange)+colorStart,150,200); //projection
      //stroke((i/levels*colorRange)+colorStart,100,100); //screen viewing
      for (int m=0;m<b.getEdgeNb();m++) {
        eA = b.getEdgeVertexA(m);
        eB = b.getEdgeVertexB(m);
        if (eA !=null && eB !=null)
          line(
          eA.x*512*factor, eA.y*424*factor, 
          eB.x*512*factor, eB.y*424*factor 
            );
      }
    }
  }
}
