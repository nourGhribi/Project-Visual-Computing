private static final float cylinderBaseSize = 20;
private static final float cylinderHeight = 80;
private static final int cylinderResolution = 40;
  
class Cylinder {
  
  private PShape openCylinder = new PShape();
  private PShape bottom = new PShape();
  private PShape top = new PShape();
  private PShape group = new PShape();

  Cylinder() {
    float angle;
    float[] x = new float[cylinderResolution + 1];
    float[] y = new float[cylinderResolution + 1];
    //get the x and y position on a circle for all the sides
    for (int i = 0; i < x.length; i++) {
      angle = (TWO_PI / cylinderResolution) * i;
      x[i] = sin(angle) * cylinderBaseSize;
      y[i] = cos(angle) * cylinderBaseSize;
    }

    group= createShape(GROUP);
    fill(0, 0, 205);
    openCylinder = createShape();
    openCylinder.beginShape(QUAD_STRIP);

    //draw the border of the cylinder
    for (int i = 0; i < x.length; i++) {
      openCylinder.vertex(x[i], y[i], 0);
      openCylinder.vertex(x[i], y[i], cylinderHeight);
    }
    openCylinder.endShape();

    bottom= createShape();
    bottom.beginShape(TRIANGLE_FAN);
    top.vertex(0, 0, cylinderHeight);
    //draw the bottom of the cylinder
    for (int j = 0; j < x.length-2; j++) {
      bottom.vertex(x[j], y[j], 0);
      bottom.vertex(x[j+2], y[j+2], 0);
    }
    bottom.endShape();

    top= createShape();
    top.beginShape(TRIANGLE_FAN);
    top.vertex(0, 0, cylinderHeight);

    //draw the top of the cylinder
    for (int i = 0; i < x.length-2; i++) {
      top.vertex(x[i], y[i], cylinderHeight);
      top.vertex(x[i+2], y[i+2], cylinderHeight);
    }

    top.endShape();
    group.addChild(openCylinder);
    group.addChild(top);
    group.addChild(bottom);
  }
}