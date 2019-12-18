import java.util.ArrayList;
import java.util.List;
import java.util.TreeSet;
import gab.opencv.*;
import processing.video.*;
OpenCV opencv;

class ImageProcessing extends PApplet {
private PImage threshIm;
private PImage blurrIm;
private PImage cleanIm;
private PImage scharrIm;
private PImage blobDetectedIm;
private PImage img;
private QuadGraph QG;
private TwoDThreeD TDTD;
private BlobDetection BlobDetector;
private List <PVector> lines;
private List<PVector> corners;
Movie cam;

void settings() {
  size(1200 , 1200);
}
void setup() {
  QG=new QuadGraph();
  opencv = new OpenCV(this, 100, 100);
  BlobDetector = new BlobDetection();
  cam = new Movie(this, "/Users/liliakanoun/Desktop/TangibleGame/data/testvideo.avi");
  cam.loop();
  TDTD=new TwoDThreeD(width,height,0);
  corners=new ArrayList<PVector>();
  
}
void draw() {
  
  if (cam.available() == true) {
  cam.read();
  }
  img = cam.get();
  
  //HSB thresholded image 
  threshIm = thresholdHSB(img,100,135, 35, 255, 17, 175);
  
  //Blurr the thresholded image
  blurrIm = gaussianBlur(threshIm);
  
  //Brightness threshold
  cleanIm = brightnessThreshold(blurrIm, 5);
 
  //Blob detection of the image
  blobDetectedIm=BlobDetector.findConnectedComponents(cleanIm,true);
  
  //edge detecting
  scharrIm = scharr(blobDetectedIm);
  
  image(img, 0, 0);
  
  //Hough transform
  lines=hough(scharrIm,10);
  
  corners = QG.findBestQuad(lines, img.width, img.height, img.width*img.height, img.width*img.height/64, false);
  
  for(int i=0;i<corners.size();i++){
    corners.get(i).z=1;
  }
  //QG.displayCorners(corners);
  //QG.displayQuadLines(corners);
}

  PVector getRotation(){
    return TDTD.get3DRotations(corners);
  }

PImage gaussianBlur(PImage img) {
  float kernel[][] = {{9, 12, 9}, 
                      {12, 15, 12}, 
                      {9, 12, 9}};
  return convolute(img, kernel, 99);
}

PImage brightnessThreshold(PImage img, int threshold) {
  PImage result = createImage(img.width, img.height, RGB);
  img.loadPixels();// load pixels
  for (int i = 0; i < img.width * img.height; i++) {
    if (brightness(img.pixels[i])>threshold) {
      result.pixels[i]= color(img.pixels[i]);
    } else {
      result.pixels[i]=color(0);
    }
  }
  result.updatePixels();//update pixels
  return result;
}

PImage brightnessThresholdInverse(PImage img, int threshold) {
  PImage result = createImage(img.width, img.height, RGB);
  img.loadPixels();
  for (int i = 0; i < img.width * img.height; i++) {
    if (brightness(img.pixels[i])>threshold) {
      result.pixels[i]= color(0);
    } else {
      result.pixels[i]=color(img.pixels[i]);
    }
  }
  result.updatePixels();//update pixels
  return result;
}

PImage thresholdHSB(PImage img, int minH, int maxH, int minS, int maxS, int minB, int maxB) {
  PImage result = createImage(img.width, img.height, RGB);
  img.loadPixels();
  for (int i = 0; i < result.width*result.height; ++i) {
    float s = saturation(img.pixels[i]);
    float b = brightness(img.pixels[i]);
    float h = hue(img.pixels[i]);
    if (s >= minS && s <= maxS && h >= minH && h <= maxH && b >= minB && b <= maxB) {
      result.pixels[i] = color(255);
    } else {
      result.pixels[i] = color(0);
    }
  }
  result.updatePixels();
  return result;
}
PImage convolute(PImage img, float[][] kernel, float normFactor) {

  // create a greyscale image (type: ALPHA) for output
  PImage result = createImage(img.width, img.height, ALPHA);
  img.loadPixels();
  for (int i = 1; i < img.height-1; i++) {
    for (int j = 1; j < img.width-1; j++) {
      float val = 0;
      // we assume here that the kernel matrix is 3x3
      for (int row = 0; row < 3; row++) {
        for (int column = 0; column < 3; column++) {
          //control to keep a one-pixel wide border around the image
          int x_pixel = (j + column) - 1;
          int y_pixel = (i + row) -1;
          if (x_pixel < 0) x_pixel=0;
          if (x_pixel > img.width-1) x_pixel=img.width-1;
          if (y_pixel < 0) y_pixel=0;
          if (y_pixel > img.height-1) y_pixel=img.height-1;
          val += brightness(img.pixels[y_pixel * img.width + x_pixel]) * kernel[row][column];
        }
      }
      result.pixels[i * img.width + j] = color(val / normFactor);
    }
  }
  result.updatePixels();
  return result;
}

PImage scharr(PImage img) {

  float[][] vKernel = {
    { 3, 0, -3 }, 
    { 10, 0, -10 }, 
    { 3, 0, -3 } };
  float[][] hKernel = {
    { 3, 10, 3 }, 
    { 0, 0, 0 }, 
    { -3, -10, -3 } };

  PImage result = createImage(img.width, img.height, ALPHA);
  // clear the image
  for (int i = 0; i < img.width * img.height; i++) {
    result.pixels[i] = color(0);
  }

  float max=0;
  float[] buffer = new float[img.width * img.height];

  float sum_h = 0;
  float sum_v = 0;
  float sum = 0;
  for (int i = 0; i < img.height-1; ++i) {
    for (int j = 0; j < img.width-1; ++j) {
      sum_h  = 0;
      sum_v = 0;
      // we assume here that the kernel matrix is 3x3
      for (int row = 0; row < 3; row++) {
        for (int column = 0; column < 3; column++) {
          //control to keep a one-pixel wide border around the image
          int x_pixel = (j + column) - 1;
          int y_pixel = (i + row) -1;
          if (x_pixel < 0) x_pixel=0;
          if (x_pixel > img.width-1) x_pixel=img.width-1;
          if (y_pixel < 0) y_pixel=0;
          if (y_pixel > img.height-1) y_pixel=img.height-1;
          sum_h += brightness(img.get(x_pixel, y_pixel))*hKernel[row][column];
          sum_v += brightness(img.get(x_pixel, y_pixel))*vKernel[row][column];
        }
      }
      sum = sqrt(pow(sum_h, 2) + pow(sum_v, 2));
      buffer[i*result.width+j] = sum;
      
      if (sum > max) {
        max = sum;
      }   
    }
  } 
  
  for (int y = 2; y < img.height - 2; y++) { // Skip top and bottom edges
    for (int x = 2; x < img.width - 2; x++) { // Skip left and right
      int val=(int) ((buffer[y * img.width + x] / max)*255);
      result.pixels[y * img.width + x]=color(val);
    }
  } 
  return result;
}

boolean imagesEqual(PImage img1, PImage img2) {
  if (img1.width != img2.width || img1.height != img2.height)
    return false;
  for (int i = 0; i < img1.width*img1.height; i++)
    //assuming that all the three channels have the same value
    if (red(img1.pixels[i]) != red(img2.pixels[i])) return false;
  return true;
}
}