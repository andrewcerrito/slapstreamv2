// Slapstream
// By Andrew Cerrito
// Stars and parallax motion modified very slightly from William Smith's sketch on OpenProcessing:
// http://www.openprocessing.org/sketch/63495
// Kinect code adapted from examples from Making Things See by Greg Borenstein
// Thanks to:
// Dan Shiffman, who helped me rework some code into cleaner, more usable code
// Mark Kleback, for helping me with array lists
// Genevieve Hoffman, for trying to help me with the lives issue
// Ben Smith, for helping me finally solve the lives thing

import SimpleOpenNI.*;
SimpleOpenNI kinect;

Hero hero;
Hero hero2;
ArrayList<Obstacle> obstacles = new ArrayList();
Star[] stars;


// For the star movement:
PVector offset;

// These probably shouldn't be global but they're going to be
float leftHandMagnitude, rightHandMagnitude;

int heroLives = 5;
int hero2Lives = 5;
int randX = 10;

// Style-related variables
color c1 = color(0, 0, 0);
color green = color(0, 255, 0);
color blue = color(0, 0, 255);
PFont pixelFont;
PFont defaultFont;
PImage psipose;

// Boolean relating to title screen, will turn false and start game when
// Kinect detects user pose
boolean titleScreen = true;
boolean p1ready = false;    
boolean p2ready = false;

//Frame counter to give a short delay after detecting 1P to detect 2P
int frameCounter = 0;

void setup() {
  size((600+640), 850);
  smooth();
  randX = (int) random(0, 600); // SET TO 600 - CHANGE BACK LATER
  background(c1);
  psipose = loadImage("Psiyellow.png");
  pixelFont = createFont("C64Pro-Style", 24, true);
  defaultFont = createFont("SansSerif", 12, true);


  // define hero, obstacle, and stars
  hero = new Hero(600/2, height-80, 70, green); //SET TO 600 - CHANGE BACK LATER
  hero2 = new Hero(600/2 + 50, height-80, 70, blue);

  for (int i =0; i < 5; i++) {
    Obstacle obst = new Obstacle(randX, 10);
    obstacles.add(obst);
  }

  stars = new Star[width];
  for (int i = 0; i < stars.length; i ++) stars[i] = new Star();
  offset = new PVector(width / 2, height / 2);

  //Kinect initialization
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  kinect.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);
}

void draw() {
  background(c1);
  c1 = color(0, 0, 0);
  starField();

  // displays title screen until user does Psi pose
  if (titleScreen) {
    kinectDraw();
    pushStyle();
    fill(255, 255, 0);
    textFont(pixelFont, 60);
    text("Slapstream", 40, height/2-150);
    imageMode(CENTER);
    textFont(pixelFont, 18);
    text("Do this pose to begin:", 165, height/2);
    image(psipose, width/4, (height/2+150));
    popStyle();

    // If both players detected, start game immediately.
    // If only one player detected, wait a short while to try to detect add'l player.
    // If no 2P detected, start game.
    if (p1ready && p2ready) {
      titleScreen = false;
    }
    else if (p1ready &! p2ready) {
      pushStyle();
      fill(green);
      textFont(pixelFont, 18);
      text("1 player detected - starting game shortly", 165, height-50);
      popStyle();
      frameCounter++;
      println(frameCounter);
    }
    if (frameCounter > 125) {
      titleScreen = false;
    }
  }


  // if user poses, game begins
  if (!titleScreen) {
    fill(255);
    pushStyle();
    textFont(pixelFont, 24); 
    text("Lives: " + heroLives, 10, 30);
    if (p2ready) {
      text("P2 Lives: " + hero2Lives, 500, 30);
    }
    popStyle();
    textFont(defaultFont);
    text (frameRate, width-60, height-60);
    //  text (topSpeed, width-60, height-100);

    // Right now, game is set to end if either player loses all lives. Change this later.
    if (heroLives > 0 && hero2Lives > 0) {
      hero.speedCalc();
      if (p2ready) {
        hero2.speedCalc();
      }
      kinectDraw();
      hero.display();
      hero.moveCheck();
      if (p2ready) {
        hero2.display();
        hero2.moveCheck();
      }

      for (int i = 0; i < obstacles.size(); i++) {
        Obstacle obst = obstacles.get(i);
        obst.display();
        obst.move();
        hero.collideDetect(obst.x, obst.y, obst.rad);
        if (p2ready) {
          hero.collideDetect(obst.x, obst.y, obst.rad);
        }
      }

      if (obstacles.size() > 20) {
        obstacles.remove(0);
      }

      hero.speedVectorDraw(); // Visualize vectors onscreen for P1 only
    } 

    else {  // if zero lives remaining:
      background(0);
      starField();
      fill(255, 255, 0);
      textFont(pixelFont, 48);
      text("GAME OVER", 125, height/2);
    }
  }
}





// ******** STAR FIELD FUNCTION ********

void starField() {
  for (int i = 0; i < stars.length; i ++) stars[i].display();

  // Make stars float down from top of screen
  //  PVector angle = new PVector(mouseX - width / 2, mouseY - height / 2);
  PVector angle = new PVector(0, 0);
  angle.y--;
  angle.normalize();
  //angle.mult(dist(width / 2, height / 2, mouseX, mouseY) / 50);

  // this multiplier controls speed of stars
  angle.mult(5); 

  offset.add(angle);
}





// ******** KINECT FUNCTIONS ********

void kinectDraw() {
  kinect.update();
  image(kinect.depthImage(), 600, 100);

  IntVector userList = new IntVector();
  kinect.getUsers(userList);

  if (userList.size() > 1) {
    int user1 = userList.get(0);
    int user2 = userList.get(1);
    if (kinect.isTrackingSkeleton(user1)) {
      drawSkeleton(user1);
      p1ready = true;
    }
    if (kinect.isTrackingSkeleton(user2)) {
      drawSkeleton(user2);
      p2ready = true;
    }
  }
  else if (userList.size() > 0) {
    int userId = userList.get(0);
    if (kinect.isTrackingSkeleton(userId)) {
      drawSkeleton(userId);
      p1ready = true;
    }
  }
}


void drawSkeleton(int userId) {
  PVector leftHand = new PVector();
  PVector rightHand = new PVector();
  PVector head = new PVector();

  kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_HAND, rightHand);
  kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HAND, leftHand);
  kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_HEAD, head);

  // NEW: get current value for hand and store previous value
  prhand = rhand;
  rhand = rightHand;

  plhand = lhand;
  lhand = leftHand;

  // subtract hand vectors from head to get difference vectors
  PVector rightHandVector = PVector.sub(head, rightHand);
  PVector leftHandVector = PVector.sub(head, leftHand);

  // calculate the distance and direction of the difference vector
  rightHandMagnitude = rightHandVector.mag();
  leftHandMagnitude = leftHandVector.mag();
  // this is for unit vectors - uncomment it if you need to do something with direction
  //      rightHandVector.normalize();
  //      leftHandVector.normalize();


  // draw a line between the two hands
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_RIGHT_HAND);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_LEFT_HAND);

  // display info onscreen for testing
  pushMatrix();
  fill(255, 0, 0);
  text("left: " + leftHandMagnitude, 10, height-200);
  text("right: " + rightHandMagnitude, width-200, height-200);
  popMatrix();
}





// ******** KINECT USER TRACKING FUNCTIONS ********

void onNewUser(int userId) {
  println("start " + userId + " pose detection");
  kinect.startPoseDetection("Psi", userId);
}

void onEndCalibration(int userId, boolean successful) {
  if (successful) {
    println("User " + userId + " calibrated !!!");
    kinect.startTrackingSkeleton(userId);
  }
  else {
    println("  Failed to calibrate " + userId + " !!!");
    kinect.startPoseDetection("Psi", userId);
  }
}

void onStartPose(String pose, int userId) {
  println("Started pose for user " + userId);
  kinect.stopPoseDetection(userId);
  kinect.requestCalibrationSkeleton(userId, true);
}

