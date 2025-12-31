import 'dart:math' as math;
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PoseEvaluation {
  final bool isCorrect;
  final String feedback;
  PoseEvaluation(this.isCorrect, this.feedback);
}

class PoseMatcher {
  static PoseEvaluation evaluate(Pose pose, String targetPoseName) {
    // 1. Global Visibility Check
    if (!_isBodyVisible(pose)) {
      return PoseEvaluation(false, "Step back. Show full body.");
    }

    switch (targetPoseName) {
      case "Mountain Pose": return _checkMountainPose(pose);
      case "Tree Pose":     return _checkTreePose(pose);
      case "Warrior Pose":  return _checkWarriorPose(pose);
      case "Bridge Pose":   return _checkBridgePose(pose);
      case "Chair Pose":    return _checkChairPose(pose);
      case "Cobra Pose":    return _checkCobraPose(pose);
      case "Triangle Pose": return _checkTrianglePose(pose);
      case "Forward Bend":  return _checkForwardBend(pose);
      case "Side Stretch":  return _checkSideStretch(pose);
      default: return PoseEvaluation(false, "Unknown Pose");
    }
  }

  static bool _isBodyVisible(Pose pose) {
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final rightHip = pose.landmarks[PoseLandmarkType.rightHip];
    if (leftHip == null || leftHip.likelihood < 0.5 || rightHip == null) return false;
    return true;
  }

  // --- HELPER: Simple Check for Lying Down vs Standing ---
  static bool _isLyingDown(Pose pose) {
    final shoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final hip = pose.landmarks[PoseLandmarkType.leftHip];
    if (shoulder == null || hip == null) return false;
    
    // If vertical distance is less than horizontal, likely lying down
    return (shoulder.y - hip.y).abs() < (shoulder.x - hip.x).abs();
  }

  // ================= POSES =================

  // 1. MOUNTAIN POSE (Relaxed)
  static PoseEvaluation _checkMountainPose(Pose pose) {
    // Removed strict vertical check that was failing you.
    // Just checks straight body and arms down.
    
    double hipAngle = _getAngle(pose, PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee);
    if (hipAngle < 160) return PoseEvaluation(false, "Stand tall. Don't bend.");
    
    final lWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final lHip = pose.landmarks[PoseLandmarkType.leftHip];
    // Check if hands are roughly below hips
    if (lWrist != null && lHip != null && lWrist.y < lHip.y - 40) {
       return PoseEvaluation(false, "Lower your arms.");
    }
    return PoseEvaluation(true, "Perfect Mountain Pose!");
  }

  // 2. TREE POSE (Fixed: Added Sequence Foot -> Hands Up -> Join Hands)
  static PoseEvaluation _checkTreePose(Pose pose) {
    final lAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
    final rAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];
    
    // Step 1: Foot Raised
    if (lAnkle != null && rAnkle != null) {
      double yDiff = (lAnkle.y - rAnkle.y).abs();
      if (yDiff < 40) return PoseEvaluation(false, "Lift your foot higher.");
    }

    // Step 2: Hands Overhead
    final nose = pose.landmarks[PoseLandmarkType.nose];
    final lWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final rWrist = pose.landmarks[PoseLandmarkType.rightWrist];

    bool handsUp = (lWrist != null && nose != null && lWrist.y < nose.y) &&
                   (rWrist != null && nose != null && rWrist.y < nose.y);
                   
    if (!handsUp) {
      return PoseEvaluation(false, "Raise arms overhead.");
    }

    // Step 3: Hands Joined (Prayer) -- RESTORED THIS CHECK
    double wristDist = (lWrist.x - rWrist!.x).abs();
    if (wristDist > 120) {
      return PoseEvaluation(false, "Join your hands.");
    }

    return PoseEvaluation(true, "Perfect Tree Pose!");
  }

  // 3. WARRIOR POSE (Fixed: Added Arm T-Shape Check)
  static PoseEvaluation _checkWarriorPose(Pose pose) {
    final lAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
    final rAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];
    
    // Step 1: Wide Stance
    if (lAnkle != null && rAnkle != null) {
      double width = (lAnkle.x - rAnkle.x).abs();
      if (width < 80) return PoseEvaluation(false, "Step feet wider.");
    }

    // Step 2: Knee Bend
    double lKneeAngle = _getAngle(pose, PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle);
    double rKneeAngle = _getAngle(pose, PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle);
    
    bool isLeftBent = lKneeAngle < 150; 
    bool isRightBent = rKneeAngle < 150;
    
    if (!isLeftBent && !isRightBent) return PoseEvaluation(false, "Bend your front knee.");

    // Step 3: Arms T-Shape -- RESTORED THIS CHECK
    final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final lWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final rWrist = pose.landmarks[PoseLandmarkType.rightWrist];

    if (lShoulder != null && lWrist != null) {
      if ((lWrist.y - lShoulder.y).abs() > 60) return PoseEvaluation(false, "Raise arms to shoulder level.");
    }
    if (rShoulder != null && rWrist != null) {
      if ((rWrist.y - rShoulder.y).abs() > 60) return PoseEvaluation(false, "Raise arms to shoulder level.");
    }

    return PoseEvaluation(true, "Perfect Warrior Pose!");
  }

  // 4. BRIDGE POSE (Fixed: Removed Vertical Check, Tuned Hips)
  static PoseEvaluation _checkBridgePose(Pose pose) {
    // Removed strict vertical check because arching back can confuse it.
    
    final hip = pose.landmarks[PoseLandmarkType.leftHip];
    final shoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    
    if (hip == null || shoulder == null) return PoseEvaluation(false, "Side view needed.");

    // Hips should be HIGHER (smaller Y) than shoulders.
    // Added 20px buffer. If hip is lower (bigger Y) than shoulder - 20, fail.
    if (hip.y > shoulder.y - 20) {
      return PoseEvaluation(false, "Lift hips higher.");
    }
    
    return PoseEvaluation(true, "Perfect Bridge Pose!");
  }

  // 5. CHAIR POSE
  static PoseEvaluation _checkChairPose(Pose pose) {
    double kneeAngle = _getAngle(pose, PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle);
    if (kneeAngle > 165) return PoseEvaluation(false, "Bend knees like sitting.");
    if (kneeAngle < 70) return PoseEvaluation(false, "Don't squat too low.");

    final wrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final shoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    // Arms up check
    if (wrist != null && shoulder != null && wrist.y > shoulder.y) {
      return PoseEvaluation(false, "Raise arms overhead.");
    }
    return PoseEvaluation(true, "Perfect Chair Pose!");
  }

  // 6. COBRA POSE (Added Horizontal Check)
  static PoseEvaluation _checkCobraPose(Pose pose) {
    // If user is clearly standing, warn them
    if (!_isLyingDown(pose)) return PoseEvaluation(false, "Lie on your stomach.");

    final hip = pose.landmarks[PoseLandmarkType.leftHip];
    final shoulder = pose.landmarks[PoseLandmarkType.leftShoulder];

    // Chest Lift: Shoulder Y should be SMALLER (Higher) than Hip Y
    if (hip != null && shoulder != null) {
       // If shoulder is below or equal to hip level (flat), fail
       if (shoulder.y > hip.y - 10) return PoseEvaluation(false, "Lift your chest.");
    }

    return PoseEvaluation(true, "Perfect Cobra Pose!");
  }

  // 7. TRIANGLE POSE
  static PoseEvaluation _checkTrianglePose(Pose pose) {
    final lAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
    final rAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];
    
    if (lAnkle != null && rAnkle != null) {
      double width = (lAnkle.x - rAnkle.x).abs();
      if (width < 80) return PoseEvaluation(false, "Step feet wider.");
    }
    
    final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    double tilt = (lShoulder!.y - rShoulder!.y).abs();
    
    if (tilt < 20) return PoseEvaluation(false, "Tilt body to side.");

    return PoseEvaluation(true, "Perfect Triangle Pose!");
  }

  // 8. FORWARD BEND
  static PoseEvaluation _checkForwardBend(Pose pose) {
    final hip = pose.landmarks[PoseLandmarkType.leftHip];
    final shoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    
    // Hips should be HIGHER (smaller Y) than Shoulders
    if (hip != null && shoulder != null && hip.y > shoulder.y) {
      return PoseEvaluation(false, "Fold forward more.");
    }
    return PoseEvaluation(true, "Perfect Forward Bend!");
  }

  // 9. SIDE STRETCH
  static PoseEvaluation _checkSideStretch(Pose pose) {
    final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    double tilt = (lShoulder!.y - rShoulder!.y).abs();
    
    if (tilt < 15) return PoseEvaluation(false, "Lean to the side.");

    final nose = pose.landmarks[PoseLandmarkType.nose];
    final lWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final rWrist = pose.landmarks[PoseLandmarkType.rightWrist];
    
    bool armUp = (lWrist != null && nose != null && lWrist.y < nose.y) || 
                 (rWrist != null && nose != null && rWrist.y < nose.y);
                 
    if (!armUp) return PoseEvaluation(false, "Raise one arm.");

    return PoseEvaluation(true, "Great Side Stretch!");
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