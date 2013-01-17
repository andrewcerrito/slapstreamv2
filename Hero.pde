class Hero {
  float x, y, w;
  color playerColor;
  float rad;

  //collision detection booleans  
  boolean collideState = false;
  boolean prevState = false;
  int hitCount = 0;
  float timeWhenHit = 0;



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

