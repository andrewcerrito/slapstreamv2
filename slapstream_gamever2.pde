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

PImage ship;
PImage[] asteroids;


// For the star movement:
PVector offset;

float leftHandMagnitude, rightHandMagnitude;

int heroLives, hero2Lives, randX;

// Style-related variables
color c1 = color(0, 0, 0);
color green = color(0, 255, 0);
color blue = color(0, 0, 255);
PFont pixelFont;
PFont defaultFont;
PImage psipose;

boolean titleScreen, p1ready, p2ready, restartOK;

//Frame counter to give a short delay after detecting 1P to detect 2P
int frameCounter;

void setup() {
  size((600+640), 850, P2D);
  //smooth();
  frameRate(30);
  background(c1);


  //load assets & fonts
  psipose = loadImage("Psiyellow.png");
  pixelFont = createFont("C64Pro-Style", 24, true);
  defaultFont = createFont("SansSerif", 12, true);

  // initialize variables in setup loop for easy restart (feature not implemented yet)
  heroLives = 5;
  hero2Lives = 5;
  randX = 10;
  titleScreen = true;
  p1ready = false;
  p2ready = false;
  restartOK = false;
  frameCounter = 0;

  // define hero, obstacle, and stars
  hero = new Hero(600/2, height-80, 85, green); //SET TO 600 - CHANGE BACK LATER
  hero2 = new Hero(600/2 + 50, height-80, 70, blue);

  // load ship image
  ship = loadImage("orangeship.png");
  ship.resize(int(hero.w*1.4), int(hero.w*1.4));


  // create obstacles
  for (int i =0; i < 5; i++) {
    int randX = (int) random (0, 600);
    Obstacle obst = new Obstacle(randX, 10);
    obst.imageInit();
    obst.imageSelect();
    obstacles.add(obst);
    println("Obstacle " + i + " loaded");
  }

  stars = new Star[width];
  for (int i = 0; i < stars.length; i ++) stars[i] = new Star();
  offset = new PVector(width / 2, height / 2);

  //Kinect initialization
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  kinect.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);
}

void restart() {
  heroLives = 5;
  hero2Lives = 5;
  randX = 10;
  titleScreen = true;
  p1ready = false;
  p2ready = false;
  restartOK = false;
  frameCounter = 0;

  hero = new Hero(600/2, height-80, 85, green); //SET TO 600 - CHANGE BACK LATER
  hero2 = new Hero(600/2 + 50, height-80, 70, blue);

  // load ship image
  ship = loadImage("orangeship.png");
  ship.resize(int(hero.w*1.4), int(hero.w*1.4));

  // reset obstacle parameters 
  for (int i = 0; i < obstacles.size (); i++) {
    Obstacle obst = obstacles.get(i);
    obst.obstSpeed = 0;
    obst.speedModifier = random(-2,2);
  }
  stars = new Star[width];
  for (int i = 0; i < stars.length; i ++) stars[i] = new Star();
  offset = new PVector(width / 2, height / 2);
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
    textAlign(CENTER);
    text("Slapstream", 300, height/2-150);
    textFont(pixelFont, 24);
    text("Match this pose to begin:", 300, height/2);
    PImage depth = kinect.depthImage();
    PImage depth2 = depth.get();
    depth2.resize(int(640*.48),int(480*.48));
    imageMode(CENTER);
    image(depth2, 410, height/2+150);
    image(psipose, 115, (height/2+150));
    popStyle();

    // If both players detected, start game immediately.
    // If only one player detected, wait a short while to try to detect add'l player.
    // If no 2P detected, start game.
    if (p1ready && p2ready) {
      titleScreen = false;
    } else if (p1ready &! p2ready) {
      pushStyle();
      fill(green);
      textAlign(CENTER);
      textFont(pixelFont, 18);
      text("Player detected - beginning game...", 300, height-50);
      popStyle();
      frameCounter++;
    }
    if (frameCounter > 100) {
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
      // text("P2 Lives: " + hero2Lives, 500, 30);
    }
    textFont(defaultFont, 36);
    text (frameRate, width-150, height-90);
    //  text (topSpeed, width-60, height-100);
    popStyle();

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

      for (int i = 0; i < obstacles.size (); i++) {
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
    } else {  // if zero lives remaining:
      kinectDraw();
      background(0);
      starField();
      fill(255, 255, 0);
      textFont(pixelFont, 48);
      text("GAME OVER", 125, height/2);
      textFont(pixelFont, 24);

      //IntVector userList = new IntVector();rr
      //kinect.getUsers(userList);
      //println(userList.size());

      if (keyPressed && key == 'r') {
        restart();
      }
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
  pushStyle();
  kinect.update();
  imageMode(CORNER);
  //image(kinect.depthImage(), 600, 100);
  popStyle();

  IntVector userList = new IntVector();
  kinect.getUsers(userList);

  // disabling 2nd player detection for now until base 1p game is smoothed out  
  /*
  if (userList.size() > 1) {
   int user1 = userList.get(0);
   int user2 = userList.get(1);
   if (kinect.isTrackingSkeleton(user1)) {
   hero.drawSkeleton(user1);
   p1ready = true;
   }
   if (kinect.isTrackingSkeleton(user2)) {
   hero2.drawSkeleton(user2);
   p2ready = true;
   }
   }
   else if (userList.size() > 0) {
   int userId = userList.get(0);
   if (kinect.isTrackingSkeleton(userId)) {
   hero.drawSkeleton(userId);
   p1ready = true;
   }
   }
   */

  if (userList.size() > 0) {
    int userId = userList.get(0);
    if (kinect.isTrackingSkeleton(userId)) {
      hero.drawSkeleton(userId);
      p1ready = true;
    }
  }
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
  } else {
    println("  Failed to calibrate " + userId + " !!!");
    kinect.startPoseDetection("Psi", userId);
  }
}

void onStartPose(String pose, int userId) {
  println("Started pose for user " + userId);
  kinect.stopPoseDetection(userId);
  kinect.requestCalibrationSkeleton(userId, true);
}

void onLostUser(int userId)
{
  println("User Lost - userId: " + userId);
  println("RESTART OK");
  restartOK = true;
}

