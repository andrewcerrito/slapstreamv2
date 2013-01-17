
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

// User tracking:
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
