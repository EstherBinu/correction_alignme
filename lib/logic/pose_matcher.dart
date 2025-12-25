import 'dart:math' as math;
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PoseMatcher {
  // Returns TRUE if the pose matches the target (Mountain Pose for now)
  static bool evaluate(Pose pose, String targetPoseName) {
    if (targetPoseName == "Mountain Pose") {
      return _checkMountainPose(pose);
    }
    // We will add other poses (Tree, Warrior, etc.) here in Stage 6
    return false;
  }

  static bool _checkMountainPose(Pose pose) {
    // 1. Get Landmarks
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
    final leftElbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final rightHip = pose.landmarks[PoseLandmarkType.rightHip];
    final rightElbow = pose.landmarks[PoseLandmarkType.rightElbow];
    final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];

    // Safety check
    if (leftShoulder == null || leftHip == null || leftKnee == null ||
        rightShoulder == null || rightHip == null || leftElbow == null ||
        leftWrist == null || rightElbow == null || rightWrist == null) {
      return false;
    }

    // 2. Check Conditions (Mountain Pose = Standing Straight, Arms Down)
    
    // A. Body Straight (Hip Angle ~180)
    double hipAngle = _getAngle(leftShoulder, leftHip, leftKnee);
    bool isBodyStraight = hipAngle > 150;

    // B. Arms Straight (Elbow Angle ~180)
    double lArmAngle = _getAngle(leftShoulder, leftElbow, leftWrist);
    double rArmAngle = _getAngle(rightShoulder, rightElbow, rightWrist);
    bool areArmsStraight = lArmAngle > 150 && rArmAngle > 150;

    // C. Arms Down (Wrist below Hip)
    bool areArmsDown = leftWrist.y > leftHip.y && rightWrist.y > rightHip.y;

    return isBodyStraight && areArmsStraight && areArmsDown;
  }

  static double _getAngle(PoseLandmark first, PoseLandmark mid, PoseLandmark last) {
    final double radians = math.atan2(last.y - mid.y, last.x - mid.x) -
                           math.atan2(first.y - mid.y, first.x - mid.x);
    double degrees = (radians * 180.0 / math.pi).abs();
    if (degrees > 180.0) degrees = 360.0 - degrees;
    return degrees;
  }
}