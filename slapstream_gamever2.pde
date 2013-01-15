// Slapstream
// By Andrew Cerrito
// Stars and parallax motion modified very slightly from William Smith's sketch on OpenProcessing:
// http://www.openprocessing.org/sketch/63495
// Kinect code adapted from examples from Making Things See by Greg Borenstein
// Thanks to:
// Dan Shiffman, who helped me rework some code into cleaner, more usable code
// Mark Kleback, for helping me with array lists
// Genevieve Hoffman, for trying to help me with the lives issue

import SimpleOpenNI.*;
SimpleOpenNI kinect;

Hero hero;
ArrayList<Obstacle> obstacles = new ArrayList();
Star[] stars;

PVector rhand = new PVector(width/2, height/2);
PVector prhand = new PVector(width/2, height/2);
PVector rhandvel = new PVector(0, 0);

PVector lhand = new PVector(width/2, height/2);
PVector plhand = new PVector(width/2, height/2);
PVector lhandvel = new PVector(0, 0);

// For the star movement:
PVector offset;

// These probably shouldn't be global but they're going to be
float leftHandMagnitude, rightHandMagnitude;

int heroLives = 5;
int randX = 10;

color c1 = color(0, 0, 0);
PFont pixelFont;
PFont defaultFont;
PImage psipose;

// Boolean relating to title screen, will turn false and start game when
// Kinect detects user pose
boolean titleScreen = true;

// booleans relating to hero lives and collision detection
boolean heroHit = false;
// int hitCount = 0;

void setup() {
  size((600+640), 850);
  smooth();
  randX = (int) random(0, 600); // SET TO 600 - CHANGE BACK LATER
  background(c1);
  psipose = loadImage("Psiyellow.png");
  pixelFont = createFont("C64Pro-Style", 24, true);
  defaultFont = createFont("SansSerif", 12, true);


  // define hero, obstacle, and stars
  hero = new Hero(600/2, height-80, 70); //SET TO 600 - CHANGE BACK LATER

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
    
  }

// if user poses, game begins
  if (!titleScreen) {
    fill(255);
    pushStyle();
    textFont(pixelFont, 24); 
    text("Lives: " + heroLives, 10, 30);
    popStyle();
    textFont(defaultFont);
    text (frameRate, width-60, height-60);
    //  text (topSpeed, width-60, height-100);


    if (heroLives > 0) {
      speedCalc();
      kinectDraw();
      hero.display();
      hero.moveCheck();

      for (int i = 0; i < obstacles.size(); i++) {
        Obstacle obst = obstacles.get(i);
        obst.display();
        obst.move();
        hero.collideDetect(obst.x, obst.y, obst.rad);
        //println("obst.x " + obst.x + "obst.y " + obst.y);
      }

//      if (heroHit == true && hitCount<=5) {
//        heroLives--;
//        heroHit = false;
//      }


      if (obstacles.size() > 20) {
        obstacles.remove(0);
      }

      speedVectorDraw();
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

void speedCalc() {
  // Calculates velocity of hands and interpolates it for smoothness
  PVector rvelocity = PVector.sub(rhand, prhand);
  rhandvel.x = lerp(rhandvel.x, rvelocity.x, 0.4);
  rhandvel.y = lerp(rhandvel.y, rvelocity.y, 0.4);
  PVector lvelocity = PVector.sub(lhand, plhand);
  lhandvel.x = lerp(lhandvel.x, lvelocity.x, 0.4);
  lhandvel.y = lerp(lhandvel.y, lvelocity.y, 0.4);
}

void speedVectorDraw() {
  strokeWeight(1);
  stroke(0, 255, 0);
  pushMatrix();
  translate(width/2, height/2);
  scale(10);

  stroke(0, 255, 0);
  line(0, 0, rhandvel.x, rhandvel.y);
  text (rhandvel.mag(), 0, 40);

  stroke(255, 0, 0);
  line(0, 0, lhandvel.x, lhandvel.y);
  text (lhandvel.mag(), 0, 30);

  popMatrix();
}



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


// tracks top speeds - for testing only
//void topSpeedCheck() {
//  if (leftSpeed > topSpeed && leftSpeed <=150) topSpeed = leftSpeed;
//  if (rightSpeed > topSpeed && rightSpeed <=150) topSpeed = rightSpeed;
//  println(topSpeed);
//}

