class BlobDetection{
PImage findConnectedComponents(PImage input, boolean onlyBiggest) {

    PImage img = input.copy();
    img.loadPixels();
    int [] labels= new int [img.width*img.height];
    List<TreeSet<Integer>> labelsEquivalences= new ArrayList<TreeSet<Integer>>();
    int currentLabel=1;

    for (int i = 0; i < labels.length; ++i) {
      labels[i] = 0;
    }

    for (int j = 1; j < img.height-1; ++j) {
      for (int i = 1; i < img.width-1; ++i) {
        if (brightness(img.pixels[j*img.width+i]) != 0) {

          ArrayList<Integer> array = new ArrayList<Integer>();
          int value = currentLabel;

          for (int y = j-1; y <= j+1; ++y) {
            for (int x = i-1; x <= i+1; ++x) {
              if (labels[y*img.width+x]!=0) {
                array.add(labels[y*img.width+x]);
                value = (labels[y*img.width+x] < value) ? labels[y*img.width+x] : value;
              }
            }
          }

          if (value == currentLabel) {
            labelsEquivalences.add(new TreeSet<Integer>());
            labelsEquivalences.get(labelsEquivalences.size()-1).add(value);
            ++currentLabel;
          } else {
            for (int index = 0; index < array.size(); ++index) {
              labelsEquivalences.get(value-1).add(array.get(index));
            }
          }
          labels[j*img.width+i] = value;
        }
      }
    }

    int maxLabel = 0;
    for (int i = 0; i < labels.length; ++i) {
      labels[i] = (labels[i]!=0) ? labelsEquivalences.get(labels[i]-1).first() : labels[i];
      maxLabel = (maxLabel < labels[i]) ? labels[i] : maxLabel;
    }

    labelsEquivalences= new ArrayList<TreeSet<Integer>>();
    for (int i = 0; i < maxLabel; ++i) {
      labelsEquivalences.add(new TreeSet<Integer>());
    }

    for (int i = 1; i < img.width-1; ++i) {
      for (int j = 1; j < img.height-1; ++j) {

        if (labels[j*img.width+i]!=0) {
          for (int x = i-1; x <= i+1; ++x) {
            for (int y = j-1; y <= j+1; ++y) {
              if (labels[y*img.width+x]!=0) {
                labelsEquivalences.get(labels[j*img.width+i]-1).add(labels[y*img.width+x]);
              }
            }
          }
        }
      }
    }
    maxLabel = 0; 
    for (int i = 0; i < labels.length; ++i) {
      labels[i] = (labels[i]!=0) ? labelsEquivalences.get(labels[i]-1).first() : labels[i];
      maxLabel = (maxLabel < labels[i]) ? labels[i] : maxLabel;
    }

    if (onlyBiggest) {
      int[] numLabel = new int[maxLabel];
      int maxNumLabel = 0;
      int labelMax = 0;

      for (int i = 0; i < numLabel.length; ++i) {
        numLabel[i] = 0;
      } 

      for (int l : labels) {
        if (l != 0) numLabel[l-1]++;
      }
      
      for (int i = 0; i < numLabel.length; ++i) {
        if (maxNumLabel <= numLabel[i]) {
          maxNumLabel = numLabel[i];
          labelMax = i+1;
        }
      }

      for (int i = 0; i < labels.length; ++i) {
        img.pixels[i] = (labels[i] == labelMax) ? color(255) : color(0);
      }
    }
    
    else {
    
      for (int i = 0; i < labels.length; ++i) {
        if (labels[i]!=0) { 
          int color1 = 255/labels[i];
          int color2 = 255/(maxLabel-labels[i]+1);
          int color3 = 255/(maxLabel*labels[i]+1);
          img.pixels[i] = color(color1, color2, color3);
        } else {
          img.pixels[i] = color(255);
        }
      }
    }

    img.updatePixels();

    return img;
  }
}