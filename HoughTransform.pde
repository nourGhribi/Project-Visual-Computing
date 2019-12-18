import java.util.List;
import java.util.Comparator;
import java.util.Collections;

class HoughComparator implements java.util.Comparator<Integer> {
int[] accumulator;
public HoughComparator(int[] accumulator) {
this.accumulator = accumulator;
}
@Override
public int compare(Integer l1, Integer l2) {
if (accumulator[l1] > accumulator[l2]
|| (accumulator[l1] == accumulator[l2] && l1 < l2)) return -1;
return 1;
}
}

List<PVector> hough(PImage edgeImg,int nLines) {

  float discretizationStepsPhi = 0.06f;
  float discretizationStepsR = 2.5f;
  int minVotes=150;
  // dimensions of the accumulator
  int phiDim = (int) (Math.PI / discretizationStepsPhi+1);
  //The max radius is the image diagonal, but it can be also negative
  int rDim = (int) ((sqrt(edgeImg.width*edgeImg.width + edgeImg.height*edgeImg.height) * 2) 
  / discretizationStepsR +1);
  // our accumulator
  int[] accumulator = new int[phiDim * rDim];

  // pre-compute the sin and cos values
  float[] tabSin = new float[phiDim];
  float[] tabCos = new float[phiDim];
  float ang = 0;
  float inverseR = 1.f / discretizationStepsR;
  for (int accPhi = 0; accPhi < phiDim; ang += discretizationStepsPhi, accPhi++) {
  // we can also pre-multiply by (1/discretizationStepsR) since we need it in the Hough loop
  tabSin[accPhi] = (float) (Math.sin(ang) * inverseR);
  tabCos[accPhi] = (float) (Math.cos(ang) * inverseR);
  }


  // Fill the accumulator: on edge points (ie, white pixels of the edge
  // image), store all possible (r, phi) pairs describing lines going
  // through the point.
  for (int y = 0; y < edgeImg.height; y++) {
    for (int x = 0; x < edgeImg.width; x++) {
      // Are we on an edge?
      if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {
       // ...determine here all the lines (r, phi) passing through
       // pixel (x,y), convert (r,phi) to coordinates in the
       // accumulator, and increment accordingly the accumulator.
       // Be careful: r may be negative, so you may want to center onto
       // the accumulator: r += rDim / 2
        for (int phi = 0; phi < phiDim; phi += 1) {
          float r = (x * tabCos[phi] + y * tabSin[phi]);
          r += rDim/2;
          accumulator[phi*rDim+ (int)(r)]++;
        }
      }
    }
  }
  //draw the test image test = displayHoughAcc(accumulator,phiDim,rDim);
  
   /* In this part we look for pairs of  (r, ϕ)  that get more than 50 votes */
   ArrayList<Integer> bestCandidates = new ArrayList<Integer>();
  // we chose size 10 for the region where we search for a local maximum
  int neighbourhood = 10;

  // only search around lines with more that a certain amount of votes
  for (int accR = 0; accR < rDim; accR++) {
    for (int accPhi = 0; accPhi < phiDim; accPhi++) {
      // compute current index in the accumulator
      int idx = accPhi*rDim+accR;
     
      if (accumulator[idx] > minVotes) {
        boolean bestCandidate = true;
        // iterate over the neighbourhood
        for(int dPhi=-neighbourhood/2; dPhi < neighbourhood/2+1; dPhi++) {
          // check we are not outside the image
          if( accPhi+dPhi < 0 || accPhi+dPhi >= phiDim) continue;
          for(int dR=-neighbourhood/2; dR < neighbourhood/2 +1; dR++) {
            // check we are not outside the image
            if(accR+dR < 0 || accR+dR >= rDim) continue;
            int neighbourIdx = (accPhi + dPhi) * (rDim) + accR + dR;
            if(accumulator[idx] < accumulator[neighbourIdx]) {
              // the current idx is not a local maximum
              bestCandidate=false;
              break;
            }
          }
          if(!bestCandidate) break;
        }
        if(bestCandidate) {
          // the current idx is a local maximum so we add it to the list
          bestCandidates.add(idx);
        }
      }
    }
  }
  Collections.sort(bestCandidates, new HoughComparator(accumulator));
  
  /* In this part we obtain the lines from the computation of bestCandidates */
  
  ArrayList<PVector> lines = new ArrayList<PVector>();
  for(int idx : bestCandidates.subList(0, min(nLines, bestCandidates.size()))) {
    // first, compute back the (r, phi) polar coordinates:
    int accPhi = (int) (idx / rDim);
    int accR = idx - (accPhi) * (rDim);
    float r = (accR - (rDim) * 0.5f) * discretizationStepsR;
    float phi = accPhi * discretizationStepsPhi;
    PVector line = new PVector(r, phi);
    lines.add(line);
  }
  return lines;
}

PImage displayHoughAcc(int[] accumulator, int phiDim,  int rDim) {
  PImage houghImg = createImage(rDim, phiDim, ALPHA);
  for (int i = 0; i < accumulator.length; i++) {
  houghImg.pixels[i] = color(min(255, accumulator[i]));
  }
  // You may want to resize the accumulator to make it easier to see:
  houghImg.resize(400, 400);
  houghImg.updatePixels();
  return houghImg;
}

void plotLines(PImage edgeImg, List<PVector> lines) {
  for (int idx = 0; idx < lines.size(); idx++) {
    PVector line=lines.get(idx);
    float r = line.x;
    float phi = line.y;
    // Cartesian equation of a line: y = ax + b
    // in polar, y = (-cos(phi)/sin(phi))x + (r/sin(phi))
    // => y = 0 : x = r / cos(phi)
    // => x = 0 : y = r / sin(phi)
    // compute the intersection of this line with the 4 borders of
    // the image
    int x0 = 0;
    int y0 = (int) (r / sin(phi));
    int x1 = (int) (r / cos(phi));
    int y1 = 0;
    int x2 = edgeImg.width;
    int y2 = (int) (-cos(phi) / sin(phi) * x2 + r / sin(phi));
    int y3 = edgeImg.width;
    int x3 = (int) (-(y3 - r / sin(phi)) * (sin(phi) / cos(phi)));
    // Finally, plot the lines
    stroke(204,102,0);
    if (y0 > 0) {
      if (x1 > 0)
        line(x0, y0, x1, y1);
      else if (y2 > 0)
        line(x0, y0, x2, y2);
      else
        line(x0, y0, x3, y3);
      } else {
        if (x1 > 0) {
          if (y2 > 0)
            line(x1, y1, x2, y2);
          else
            line(x1, y1, x3, y3);
        } else
          line(x2, y2, x3, y3);
    }
  }
}

  