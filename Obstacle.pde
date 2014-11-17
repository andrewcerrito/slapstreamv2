class Obstacle {

  PImage currentGraphic;
  int maxSize = 150; //dictates maximum size of obstacle
  int x; 
  float y;
  int w = (int) random(30, maxSize);
  float rad;
  float obstSpeed = 0;
  float speedModifier = random(-2,2); // makes the obstacles fall at slightly different speed, less staggered
  boolean graphicSelected = false;

  Obstacle (int tx, float ty) {
    x = tx;
    y = ty;
    rad = w/2;
  }

void imageSelect() {
  if (graphicSelected == false) {
  int imageSelector = (int)random(0,8);
//  pushStyle();
//  imageMode(CENTER);
  switch(imageSelector) {
      case 1:
//    image(asteroids[0], x, y);
      asteroids[0].resize(int(w*1.4),int(w*1.4));
      currentGraphic = loadImage(asteroids[0]);
      break;
      case 2:
//      image(asteroids[1], x, y);
      asteroids[1].resize(int(w*1.3),int(w*1.3));
      currentGraphic = loadImage(asteroids[1]);
      break;
      case 3:
//      image(asteroids[2], x, y);
      asteroids[2].resize(int(w*1.1),int(w*1.1));
      currentGraphic = loadImage(asteroids[2]);
      break;
      case 4:
//      image(asteroids[3], x, y);
      asteroids[3].resize(int(w*1.1),int(w*1.1));
      currentGraphic = loadImage(asteroids[3]);
      break;
      case 5:
//      image(asteroids[4], x, y);
      asteroids[4].resize(int(w*1.2),int(w*1.2));
      currentGraphic = loadImage(asteroids[4]);
      break;
      case 6:
//      image(asteroids[5], x, y);
      asteroids[5].resize(int(w*1.1),int(w*1.1));
      currentGraphic = loadImage(asteroids[5]);
      break;
      case 7:
//      image(asteroids[6], x, y);
      asteroids[6].resize(int(w*1.1),int(w*1.1));
      currentGraphic = loadImage(asteroids[6]);
      break;
    }   
  }
  graphicSelected = true;
  println("asteroid image selected!");
//  popStyle();
  
}


  void display() {
    fill(255, 0, 0, 100);
    stroke(255);
    imageMode(CENTER);
    image(currentGraphic,x,y);
    ellipse(x, y, w, w);
  }

  void move() {
    obstSpeed = (float) millis()/11000; // make speed increase the longer the game goes on
    //println(obstSpeed);
    y= y + 4 + obstSpeed + speedModifier; // move down the screen
    if (y >= height + rad) { // if circle leaves bottom of screen:
      y = (int) -rad; // reset to top of screen
      x = (int) random(0, 600); // get a new random width - SET TO 600 FOR NOW, CHANGE BACK LATER
      w = (int) random(30, maxSize); // get a new random size
      graphicSelected = false; // get a new asteroid graphic
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

