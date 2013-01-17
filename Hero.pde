class Hero {
  float x, y, w;
  color playerColor;
  float rad;

  //collision detection booleans  
  boolean collideState = false;
  boolean prevState = false;
  int hitCount = 0;
  float timeWhenHit = 0;

// Vectors to track hand positions and velocity  
PVector rhand = new PVector(width/2, height/2);
PVector prhand = new PVector(width/2, height/2);
PVector rhandvel = new PVector(0, 0);

PVector lhand = new PVector(width/2, height/2);
PVector plhand = new PVector(width/2, height/2);
PVector lhandvel = new PVector(0, 0);




  Hero (float tx, float ty, float tw, color tplayerColor) {
    x = tx;
    y = ty;
    w = tw;
    rad = w/2;
    playerColor = tplayerColor;
  }

  void display() {
    stroke(255);
    fill(playerColor);
    ellipse(x, y, w, w);
  }
  
  
  // Calculates velocity of hands and interpolates it for smoothness
  void speedCalc() {
  PVector rvelocity = PVector.sub(rhand, prhand);
  rhandvel.x = lerp(rhandvel.x, rvelocity.x, 0.4);
  rhandvel.y = lerp(rhandvel.y, rvelocity.y, 0.4);
  PVector lvelocity = PVector.sub(lhand, plhand);
  lhandvel.x = lerp(lhandvel.x, lvelocity.x, 0.4);
  lhandvel.y = lerp(lhandvel.y, lvelocity.y, 0.4);
}

// Draws represention of speed vectors onscreen
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


  // move hero if user is slapping and sprite is within bounds
  // inverted movement enabled: 
  // change x >,< direction and +,- operator for non-inverted
  void moveCheck() {
    if (leftHandMagnitude <= 300 && x<=600) {
      x = (x +(lhandvel.mag()/3));
      pushStyle();
      textSize(65);
      popStyle();
    }
    if (rightHandMagnitude <= 300 && x>=0) {
      x = int (x-(rhandvel.mag()/3));
      pushStyle();
      textSize(65);
      popStyle();
    }
  }

  void collideDetect (float obstX, float obstY, float obstRad) {
    // time based approach: when hit, take a life away, but
    // make hero invulnerable for 2 seconds after hit.
    float distFromObst = dist(x, y, obstX, obstY);
    if (distFromObst < rad + obstRad) {
      c1 = color(255, 0, 0);
      if (millis() - timeWhenHit > 2000) {
        heroLives--;
        timeWhenHit = millis();
      }
    }
  }
  
  
  
}

