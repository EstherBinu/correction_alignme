import 'dart:math' as math;
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PoseEvaluation {
  final bool isCorrect;
  final String feedback;

  PoseEvaluation(this.isCorrect, this.feedback);
}

class PoseMatcher {
  static PoseEvaluation evaluate(Pose pose, String targetPoseName) {
    // 1. GLOBAL CHECK: Is the body actually visible?
    if (!_isBodyVisible(pose)) {
      return PoseEvaluation(false, "Step back. Show your full body.");
    }

    // 2. Route to Specific Pose Logic
    if (targetPoseName == "Mountain Pose") {
      return _checkMountainPose(pose);
    } else if (targetPoseName == "Tree Pose") {
      return _checkTreePose(pose);
    } else if (targetPoseName == "Warrior Pose") {
      return _checkWarriorPose(pose);
    } else if (targetPoseName == "Bridge Pose") {
      return _checkBridgePose(pose);
    }
    return PoseEvaluation(false, "Unknown Pose");
  }

  // --- VISIBILITY CHECKER ---
  static bool _isBodyVisible(Pose pose) {
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final rightHip = pose.landmarks[PoseLandmarkType.rightHip];
    final leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
    final rightKnee = pose.landmarks[PoseLandmarkType.rightKnee];

    if (leftHip == null || leftHip.likelihood < 0.5 ||
        rightHip == null || rightHip.likelihood < 0.5 ||
        leftKnee == null || leftKnee.likelihood < 0.5 ||
        rightKnee == null || rightKnee.likelihood < 0.5) {
      return false;
    }
    return true;
  }

  // --- MOUNTAIN POSE ---
  static PoseEvaluation _checkMountainPose(Pose pose) {
    double hipAngle = _getAngle(pose, PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee);
    if (hipAngle < 165) return PoseEvaluation(false, "Stand tall. Don't bend forward.");

    double lArm = _getAngle(pose, PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist);
    double rArm = _getAngle(pose, PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist);
    if (lArm < 160 || rArm < 160) return PoseEvaluation(false, "Straighten your arms completely.");

    final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    if (leftWrist != null && leftHip != null && leftWrist.y < leftHip.y) {
       return PoseEvaluation(false, "Lower your arms by your sides.");
    }

    return PoseEvaluation(true, "Perfect Mountain Pose!");
  }

  // --- TREE POSE ---
  static PoseEvaluation _checkTreePose(Pose pose) {
    final leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
    final rightAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];
    final leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
    final rightKnee = pose.landmarks[PoseLandmarkType.rightKnee];
    final nose = pose.landmarks[PoseLandmarkType.nose];
    final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];

    if (leftAnkle == null || rightAnkle == null || leftKnee == null || rightKnee == null || nose == null || leftWrist == null || rightWrist == null) {
       return PoseEvaluation(false, "Full body not visible.");
    }

    // Phase 1: Legs
    bool isLeftStanding = leftAnkle.y > rightAnkle.y;
    PoseLandmark standingKnee = isLeftStanding ? leftKnee : rightKnee;
    PoseLandmark bentAnkle = isLeftStanding ? rightAnkle : leftAnkle;

    if (bentAnkle.y > standingKnee.y + 60) return PoseEvaluation(false, "Lift your foot higher.");

    // Phase 2: Arms
    bool handsUp = leftWrist.y < nose.y && rightWrist.y < nose.y;
    if (!handsUp) return PoseEvaluation(false, "Raise your arms overhead.");

    // Phase 3: Prayer
    double wristDistance = (leftWrist.x - rightWrist.x).abs();
    if (wristDistance > 120) return PoseEvaluation(false, "Join your hands together.");

    return PoseEvaluation(true, "Perfect Tree Pose!");
  }

  // --- WARRIOR II POSE ---
  static PoseEvaluation _checkWarriorPose(Pose pose) {
    final leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
    final rightAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];

    if (leftAnkle == null || rightAnkle == null || leftShoulder == null || rightShoulder == null || leftWrist == null || rightWrist == null) {
      return PoseEvaluation(false, "Full body not visible.");
    }

    // 1. Stance
    double footDist = (leftAnkle.x - rightAnkle.x).abs();
    double shoulderDist = (leftShoulder.x - rightShoulder.x).abs();
    if (footDist < shoulderDist * 2.0) return PoseEvaluation(false, "Step your feet wider apart.");

    // 2. Arms
    bool leftArmLevel = (leftWrist.y - leftShoulder.y).abs() < 60;
    bool rightArmLevel = (rightWrist.y - rightShoulder.y).abs() < 60;
    if (!leftArmLevel || !rightArmLevel) return PoseEvaluation(false, "Raise arms to shoulder level.");

    // 3. Lunge
    double leftKneeAngle = _getAngle(pose, PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle);
    double rightKneeAngle = _getAngle(pose, PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle);
    bool isLeftBent = leftKneeAngle < 135;
    bool isRightBent = rightKneeAngle < 135;
    bool isLeftStraight = leftKneeAngle > 150;
    bool isRightStraight = rightKneeAngle > 150;

    if ((isLeftBent && isRightStraight) || (isRightBent && isLeftStraight)) {
      return PoseEvaluation(true, "Perfect Warrior II!");
    }
    return PoseEvaluation(false, "Bend your front knee more.");
  }

  // --- BRIDGE POSE ---
  static PoseEvaluation _checkBridgePose(Pose pose) {
    // Ideally seen from the side.
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];

    if (leftHip == null || leftShoulder == null || leftKnee == null) {
      return PoseEvaluation(false, "Side view needed.");
    }

    // 1. Check Lift: Are Hips higher than Shoulders?
    // In screen coordinates (Y increases down), "Higher" means SMALLER Y value.
    bool hipsLifted = leftHip.y < leftShoulder.y; // Hips above shoulders
    
    // We can also check if hips are roughly inline with knees horizontally or above them
    // But mainly, hips must not be on the floor (similar Y to shoulder).
    // Let's require Hips to be at least 50 pixels higher (smaller Y) than shoulders.
    if (leftHip.y > leftShoulder.y - 30) {
      return PoseEvaluation(false, "Lift your hips higher.");
    }

    // 2. Check Knees: Should be bent, not flat.
    double kneeAngle = _getAngle(pose, PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle);
    
    // Bridge pose knee angle is usually acute or 90 degrees (~45-90).
    // If it's > 150, legs are straight on floor.
    if (kneeAngle > 150) {
      return PoseEvaluation(false, "Bend your knees.");
    }

    return PoseEvaluation(true, "Perfect Bridge Pose!");
  }

  // --- MATH HELPER ---
  static double _getAngle(Pose pose, PoseLandmarkType t1, PoseLandmarkType t2, PoseLandmarkType t3) {
    final first = pose.landmarks[t1];
    final mid = pose.landmarks[t2];
    final last = pose.landmarks[t3];
    
    if (first == null || mid == null || last == null) return 0.0;

    final double radians = math.atan2(last.y - mid.y, last.x - mid.x) -
                           math.atan2(first.y - mid.y, first.x - mid.x);
    double degrees = (radians * 180.0 / math.pi).abs();
    if (degrees > 180.0) degrees = 360.0 - degrees;
    return degrees;
  }
}