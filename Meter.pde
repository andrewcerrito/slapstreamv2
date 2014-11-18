class Meter extends Hero {
  int x, y, w, h;
  String label;
 
  Meter(int tx, int ty, int tw, int th, String t_label) {
    x = tx;
    y= ty;
    w = tw;
    h = th;
    label =(t_label);
  }
  
  void display() {
    pushStyle();
    stroke(255);
    noFill();
    rect(x,y,w,h);
    noStroke();
    fill(0,1);
    rect(x,y,w,h);
    fill(255,255,0);
    textAlign(CENTER);
    textFont(pixelFont, 18);
    text(label, x+(w/2),y-20);
    popStyle();
    
  }
  
  void updatePower(float powerValue) {
    map(powerValue, 0, 300, 0, h);
    fill(0,255,0);
    rect(x,y+h,w,-powerValue);
  }
  
}

