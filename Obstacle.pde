class Obstacle {

  int maxSize = 150; //dictates maximum size of obstacle
  int x; 
  float y;
  int w = (int) random(30, maxSize);
  float rad;
  float obstSpeed = 0;

  Obstacle (int tx, float ty) {
    x = tx;
    y = ty;
    rad = w/2;
  }

  void display() {
    fill(255, 0, 0);
    stroke(255);
    ellipse(x, y, w, w);
  }

  void move() {
    obstSpeed = (float) millis()/11000; // make speed increase the longer the game goes on
    //println(obstSpeed);
    y= y + 4 + obstSpeed; // move down the screen
    if (y >= height + rad) { // if circle leaves bottom of screen:
      y = (int) -rad; // reset to top of screen
      x = (int) random(0, 600); // get a new random width - SET TO 600 FOR NOW, CHANGE BACK LATER
      w = (int) random(30, maxSize); // get a new random size
      rad = w/2; // correct the radius variable with the new width
    }
  }

  // Moved collision detection to hero class - kept this here for reference

  //  void collideDetect (float heroX, float heroY, float heroRad) {
  //    float distFromHero = dist(x, y, heroX, heroY);
  //    if (distFromHero < rad + heroRad) {
  //      c1 = color(0, 0, 255);
  ////      println("Hit!");
  //    } 
  //    else {
  //      c1 = color(0, 0, 0);
  //    }
  //  }
}

