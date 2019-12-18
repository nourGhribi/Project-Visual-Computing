private double total_score = 0;
private double last_score = 0;
private float negligeable_velocity = 0.2f;
private PVector velocity;
private float sphere_radius = 12;

class Mover {
  private PVector location;
  private PVector friction;
  private PVector gravity_force = new PVector();
  private static final float gravityConstant = 0.2;
  private static final float normalForce = 1;
  private static final float mu = 0.01;
  private static final float frictionMagnitude = normalForce * mu;
  private float limit=BOX_WIDTH/2-sphere_radius;


  Mover() {
    location= new PVector(0, 0, 0);
    velocity = new PVector(0, 0, 0);
    friction = new PVector(0, 0, 0);
    gravity_force = new PVector(0, 0, 0);
  }

  void update() {
    gravity_force.x = sin(rz) * gravityConstant;
    gravity_force.z = -sin(rx) * gravityConstant;
    friction = velocity.get();
    friction.mult(-1);
    friction.normalize();
    friction.mult(frictionMagnitude);
    velocity.add(friction);
    velocity.add(gravity_force);
    location.add(new PVector(velocity.x/2, velocity.y/2, velocity.z/2));
    checkCylinderCollision(cylinders);
  }

  void display() {
    noStroke();
    if (pause==false) {
      lights();
      fill(254, 27, 0);
    } else {
      fill(198, 8, 0);
    }
    translate(location.x, location.y, location.z);
    translate(0, -sphere_radius-BOX_HEIGHT/2, 0);
    sphere(sphere_radius);
  }

  void checkEdges() {
    if ((location.x<= -limit)||(location.x>= limit)) {
      velocity.x = velocity.x *-0.5f;
      location.x=Math.signum(location.x)*limit;
      last_score=total_score;
      total_score=total_score-fix_velocity(velocity);
    }
    if ((location.z<= -limit)||(location.z>= limit)) {
      velocity.z = velocity.z *-0.5f;
      location.z=Math.signum(location.z)*limit;
      last_score=total_score;
      total_score=total_score-fix_velocity(velocity);
    }
  }

  void checkCylinderCollision(ArrayList<PVector> cylinders) {
    
    for (int i=0; i< cylinders.size (); i++) {
      PVector cyl = cylinders.get(i);
      PVector dist = new PVector(location.x - cyl.x, location.z - cyl.z);
      float distance = dist.mag();
      
      if (distance <= sphere_radius+ cylinderBaseSize) {
        location.x = location.x + dist.x  / (sphere_radius+cylinderBaseSize);
        location.z = location.z + dist.z / (sphere_radius+cylinderBaseSize);
        PVector normal = new PVector(location.x - cyl.x, 0, 
          location.z - cyl.z).normalize();
        velocity = PVector.sub(velocity, normal.mult(PVector.dot(velocity, normal) * 2));
        last_score=total_score;
        total_score=total_score+fix_velocity(velocity);
      }
    }
  }

  double fix_velocity(PVector velocity) {
    if (Float.compare(velocity.mag(), negligeable_velocity)<0) {
      return 0.0f;
    } else return velocity.mag();
  }
}