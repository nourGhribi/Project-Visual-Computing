private Mover mover;
private Cylinder cylinder;
private HScrollbar hs;
private float scoreLimit;
private float scoreBoxHeight;
private float scoreBoxWidth;
private PGraphics rectangle;
private PGraphics topView;
private ImageProcessing imgproc;
private PGraphics Score_board;
private PGraphics barChart;
private ArrayList<PVector> cylinders;
private ArrayList<Float> bars;
private float MAX_ANGLE=PI/3;
private static final float MIN_SPEED = 0.2;
private static final float MAX_SPEED = 1.5;
private static final int BOX_WIDTH = 250;
private static final int BOX_DEPTH = 250;
private static final int BOX_HEIGHT = 10;
private static final int surface_height = 150;

private float previousMouseY;
private float previousMouseX;
private float rx;
private float rz;
private float speed;
private float wheelAccumulator;
private boolean pause;
private int counter;

void settings() {
  size(850, 650, P3D);
}
void setup() {
  noStroke();
  mover = new Mover();
  cylinder = new Cylinder();
  
  cylinders=new ArrayList();
  bars = new ArrayList();
  
  rectangle = createGraphics(width, surface_height, P2D);
  topView = createGraphics(surface_height-10, surface_height - 10, P2D);
  Score_board = createGraphics(3* surface_height / 4, surface_height - 10);
  barChart = createGraphics(width - topView.width - Score_board.width - 25, 2*surface_height/3);
  
  hs = new HScrollbar( width/2, height-surface_height/6, barChart.width/3, 15);
  scoreBoxHeight = 5f;
  scoreBoxWidth = 5f;
  counter = 0;
  bars = new ArrayList();
  rx = 0;
  rz = 0;
  speed = 1;
  wheelAccumulator = 170;
  pause=false;
  
  imgproc = new ImageProcessing();
  String []args = {"Image processing window"};
  PApplet.runSketch(args, imgproc);
}

void draw() {
  background(255);
  
  drawRectangle();
  image(rectangle, 0, height-surface_height);

  drawTopView();
  image(topView, 5, height-surface_height+5);

  drawScoreBoard();
  image(Score_board, topView.width + 5, height - surface_height + 5);
  
  drawBarChart();
  image(barChart, topView.width + Score_board.width +10, height - surface_height + 10);
  scoreLimit = 1500/(hs.getPos()+0.2f);
  hs.update();
  hs.display();
  
  String game_parametres= "RotationX : "+(rx*180/PI)+"   RotationZ : "+rz*180/PI
    +"   Speed : "+speed;
  
  fill(0);
  textSize(10);
  
  if (pause==false) text(game_parametres, 8, 15);
  else text("SHIFT", width-BOX_WIDTH/3, height-BOX_WIDTH/1.5);
  
  pushMatrix();
  translate(width/2, height/2, 0);
   if(imgproc.corners.size()==4){
  PVector rot = imgproc.getRotation();
  println("rx is "+rx);
  println("ry is "+rz);
   if(rx <= MAX_ANGLE && rx >= -MAX_ANGLE){
        if(rot.x > rx){
          rx = min((rx+rot.x)/2.0, MAX_ANGLE);
        } else if(rot.x < rx){
          rx = max((rx+rot.x)/2.0, -MAX_ANGLE);
        }
    rotateX(rx);
    }
  if(rz <= MAX_ANGLE && rz >= -MAX_ANGLE){
        if(rot.z > rz){
          rz = min((rz+rot.z)/2.0, MAX_ANGLE);
        } else if(rot.z < rz){
          rz = max((rz+rot.z)/2.0, -MAX_ANGLE);
        }
    rotateZ(rz);
    }
  }
  noStroke();
  directionalLight(126, 126, 126, 0, 1, -1);
  ambientLight(102, 102, 102);
  fill(40, 150, 40);
  box(BOX_WIDTH, BOX_HEIGHT, BOX_DEPTH);
  
  for (int i = 0; i < cylinders.size (); i++) {
    PVector cylinder_position = cylinders.get(i);
    pushMatrix();
    translate(cylinder_position.x, -BOX_HEIGHT/2, cylinder_position.z);
    rotateX(PI/2);
    shape(cylinder.group);
    popMatrix();
  } 
  
  if (pause==false) {
    mover.update();
    mover.checkEdges();
  }
  
  mover.display();
  popMatrix();
}

void drawRectangle() {
  rectangle.beginDraw();
  rectangle.background(238, 223, 204);
  rectangle.endDraw();
}

void drawTopView() {
  topView.beginDraw();
  topView.background(40, 150, 40);

  float xPos = topView.width/2 + (mover.location.x * (topView.width*1.0 / BOX_WIDTH));
  float yPos = topView.height/2 + (mover.location.z * (topView.height*1.0 / BOX_WIDTH));
  topView.fill(254, 27, 0);
  topView.ellipse(xPos, yPos, sphere_radius/3, sphere_radius/3);

  for (PVector p : cylinders) {
    float cX = topView.width/2 + (p.x * (topView.width*1.0 / BOX_WIDTH));
    float cY = topView.height/2 + (p.z * (topView.height*1.0 / BOX_WIDTH));
    topView.fill(0,0,205);
    topView.ellipse(cX, cY, cylinderBaseSize/1.5, cylinderBaseSize/1.5);
  }

  topView.endDraw();
}

void drawScoreBoard() {
  Score_board.beginDraw();
  Score_board.background(238, 223, 204);

  Score_board.stroke(255);
  Score_board.strokeWeight(3);
  Score_board.line(5, 5, Score_board.width - 5, 5);
  Score_board.line(5, 5, 5, Score_board.height - 5);
  Score_board.line(5, Score_board.height - 5, Score_board.width - 5, Score_board.height - 5);
  Score_board.line(Score_board.width - 5,Score_board.height - 5, Score_board.width - 5, 5);

  Score_board.textSize(12);
  Score_board.fill(0);
  Score_board.text("Total Score:", 15, 30);
  Score_board.text((float)total_score, 20, 45);

  Score_board.text("Velocity:", 15, 65);
  Score_board.text((float)mover.fix_velocity(velocity), 20, 80);

  Score_board.text("Last Score:", 15, 100);
  Score_board.text((float)last_score, 20, 115);

  Score_board.endDraw();
}
void drawBarChart()
{
  barChart.beginDraw();

  barChart.background(242, 240, 209);
  barChart.line(0, barChart.height / 2, barChart.width, barChart.height/2);

  if (pause==false && ++counter > 20)
  {
    counter = 0;
    if (bars.size() == 0 || total_score != bars.get(bars.size() - 1))
      bars.add((float)total_score);
  }

  int boxNumber = 0;
  float height = 0;
  
  for (int i = 0; i < bars.size(); i++ ) {
  
    height = map(Math.abs(bars.get(i)), 0, scoreLimit, 0, barChart.height/2);
    boxNumber = Math.round(height / (scoreBoxHeight/10));
    for (int j = 0; j < boxNumber; j++) {
    
      barChart.fill(23, 101, 125);
      if(bars.get(i)<0) barChart.rect(i*scoreBoxWidth, barChart.height/2+j*scoreBoxHeight, scoreBoxWidth, scoreBoxHeight);
      else barChart.rect(i*scoreBoxWidth, barChart.height/2-scoreBoxHeight-j*scoreBoxHeight, scoreBoxWidth, scoreBoxHeight);
    }
  }
  barChart.endDraw();
}