private float previous_rx;
private float previous_rz;

void mouseWheel(MouseEvent event) {
  wheelAccumulator = constrain(wheelAccumulator + event.getCount(), 0, 260);
  speed = map(wheelAccumulator, 0, 260, MIN_SPEED, MAX_SPEED);
}

void mouseDragged() {
  if (pause==false && !hs.locked) {
    previousMouseY=pmouseY;
    previousMouseX=pmouseX;

    rx += -map(mouseY - previousMouseY, -height/2, height/2, -PI/3, PI/3) * speed;
    rx = constrain(rx, -PI/3, PI/3);

    rz += map(mouseX - previousMouseX, -width/2, width/2, -PI/3, PI/3) * speed;
    rz = constrain(rz, -PI/3, PI/3);
  } else {
  }
}

void keyPressed()
{
  if (key==CODED) {
    pause=true;
    previous_rx=rx;
    previous_rz=rz;
    rx=-PI/2;
    rz=0;
  }
}

void keyReleased()
{
  if (key==CODED) {
    pause=false;
    rx=previous_rx;
    rz=previous_rz;
  }
}

void mouseClicked() {
  if (pause==true) {
    if ( (mouseX > ((width/2) - (BOX_WIDTH/2)+cylinderBaseSize)) && (mouseX < (width/2)+(BOX_WIDTH/2)-cylinderBaseSize)
      && (mouseY > ((height/2)-(BOX_DEPTH/2)+cylinderBaseSize)) && (mouseY < ((height/2)+(BOX_DEPTH/2)-cylinderBaseSize)))
    {
      if (allow_cylinder_draw(-(width/2-mouseX), 0, 0-(height/2-mouseY))) {
        cylinders.add(new PVector(-(width/2-mouseX), 0, -(height/2-mouseY)));
      }
    }
  }
}

boolean allow_cylinder_draw(int x, int y, int z) {
  for (PVector cylinder : cylinders) {
    if ((cylinder.dist(new PVector(x, y, z))<cylinderBaseSize*2) || 
      new PVector(mover.location.x, mover.location.y, mover.location.z).dist(new PVector(x, y, z))< cylinderBaseSize*2) {
      return false;
    }
  }
  return true;
}