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
      // --- EXISTING 9 POSES ---
      case "Mountain Pose": return _checkMountainPose(pose);
      case "Tree Pose":     return _checkTreePose(pose);
      case "Warrior Pose":  return _checkWarriorPose(pose);
      case "Bridge Pose":   return _checkBridgePose(pose);
      case "Chair Pose":    return _checkChairPose(pose);
      case "Cobra Pose":    return _checkCobraPose(pose);
      case "Triangle Pose": return _checkTrianglePose(pose);
      case "Forward Bend":  return _checkForwardBend(pose);
      case "Side Stretch":  return _checkSideStretch(pose);
      
      // --- NEW 6 POSES ---
      case "Plank Pose":    return _checkPlankPose(pose);
      case "Cat Pose":      return _checkCatPose(pose);
      case "Cow Pose":      return _checkCowPose(pose);
      case "Low Lunge":     return _checkLowLunge(pose);
      case "Boat Pose":     return _checkBoatPose(pose);
      case "Pigeon Pose":   return _checkPigeonPose(pose);
      case "Downward Dog":  return _checkDownwardDog(pose);
      
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

  // 2. TREE POSE (Fixed)
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

    // Step 3: Hands Joined (Prayer)
    double wristDist = (lWrist.x - rWrist!.x).abs();
    if (wristDist > 120) {
      return PoseEvaluation(false, "Join your hands.");
    }

    return PoseEvaluation(true, "Perfect Tree Pose!");
  }

  // 3. WARRIOR POSE (Fixed)
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

    // Step 3: Arms T-Shape
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

  // 4. BRIDGE POSE (Fixed)
  static PoseEvaluation _checkBridgePose(Pose pose) {
    final hip = pose.landmarks[PoseLandmarkType.leftHip];
    final shoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    
    if (hip == null || shoulder == null) return PoseEvaluation(false, "Side view needed.");

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
    if (wrist != null && shoulder != null && wrist.y > shoulder.y) {
      return PoseEvaluation(false, "Raise arms overhead.");
    }
    return PoseEvaluation(true, "Perfect Chair Pose!");
  }

  // 6. COBRA POSE
  static PoseEvaluation _checkCobraPose(Pose pose) {
    if (!_isLyingDown(pose)) return PoseEvaluation(false, "Lie on your stomach.");

    final hip = pose.landmarks[PoseLandmarkType.leftHip];
    final shoulder = pose.landmarks[PoseLandmarkType.leftShoulder];

    if (hip != null && shoulder != null) {
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

  // ================= NEW POSES =================

  // 10. PLANK POSE
  static PoseEvaluation _checkPlankPose(Pose pose) {
    if (!_isLyingDown(pose)) return PoseEvaluation(false, "Get into push-up position.");
    
    // Check Straight Line (Shoulder - Hip - Ankle)
    double bodyAngle = _getAngle(pose, PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, PoseLandmarkType.leftAnkle);
    
    // Angle should be close to 180 (straight line). 
    // Allowing range 160-200 to account for slight arch/sag
    if (bodyAngle < 160) return PoseEvaluation(false, "Straighten your back.");
    
    return PoseEvaluation(true, "Perfect Plank!");
  }

  // 11. CAT POSE (Marjaryasana)
  static PoseEvaluation _checkCatPose(Pose pose) {
    if (!_isLyingDown(pose)) return PoseEvaluation(false, "Get on hands and knees.");
    
    // Check Table Top: Shoulders and Hips roughly level
    final shoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final hip = pose.landmarks[PoseLandmarkType.leftHip];
    
    if (shoulder != null && hip != null) {
      if ((shoulder.y - hip.y).abs() > 150) return PoseEvaluation(false, "Keep back level (Tabletop).");
    }

    // Cat = Head Down (Chin to chest)
    // We check if nose is lower or equal to shoulder
    final nose = pose.landmarks[PoseLandmarkType.nose];
    if (nose != null && shoulder != null && nose.y < shoulder.y) {
       // If nose is significantly higher than shoulder, user is looking up (Cow)
       return PoseEvaluation(false, "Tuck your chin to chest.");
    }
    
    return PoseEvaluation(true, "Perfect Cat Pose!");
  }

  // 12. COW POSE (Bitilasana)
  static PoseEvaluation _checkCowPose(Pose pose) {
    if (!_isLyingDown(pose)) return PoseEvaluation(false, "Get on hands and knees.");
    
    // Cow = Head Up, Belly Down
    final nose = pose.landmarks[PoseLandmarkType.nose];
    final shoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    
    if (nose != null && shoulder != null && nose.y > shoulder.y) {
       // If nose is lower (bigger Y) than shoulder, user is looking down
       return PoseEvaluation(false, "Look up at the ceiling.");
    }
    
    return PoseEvaluation(true, "Perfect Cow Pose!");
  }

  // 13. BOAT POSE (Navasana)
  static PoseEvaluation _checkBoatPose(Pose pose) {
    // Seated V-Shape: Hips are the lowest point (biggest Y value)
    final hip = pose.landmarks[PoseLandmarkType.leftHip];
    final shoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final ankle = pose.landmarks[PoseLandmarkType.leftAnkle];

    if (hip == null || shoulder == null || ankle == null) return PoseEvaluation(false, "Side view needed.");

    // Shoulders and Ankles must be HIGHER (smaller Y) than Hips
    // Give some buffer (20px)
    if (shoulder.y > hip.y - 20 || ankle.y > hip.y - 20) {
      return PoseEvaluation(false, "Lift legs and lean back.");
    }
    
    return PoseEvaluation(true, "Perfect Boat Pose!");
  }

  // 14. LOW LUNGE (Anjaneyasana)
  static PoseEvaluation _checkLowLunge(Pose pose) {
    // Like Warrior but back knee is DOWN.
    final lKnee = pose.landmarks[PoseLandmarkType.leftKnee];
    final rKnee = pose.landmarks[PoseLandmarkType.rightKnee];

    if (lKnee == null || rKnee == null) return PoseEvaluation(false, "Legs not visible.");

    // Find the lower knee (higher Y value = closer to floor)
    double lowerKneeY = (lKnee.y > rKnee.y) ? lKnee.y : rKnee.y;
    double higherKneeY = (lKnee.y < rKnee.y) ? lKnee.y : rKnee.y;
    
    // If knees are at same level, both are probably standing
    if ((lowerKneeY - higherKneeY).abs() < 50) {
       return PoseEvaluation(false, "Drop back knee to floor.");
    }

    // Arms Check (Overhead)
    final wrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final nose = pose.landmarks[PoseLandmarkType.nose];
    
    if (wrist != null && nose != null && wrist.y > nose.y) {
       return PoseEvaluation(false, "Raise arms overhead.");
    }

    return PoseEvaluation(true, "Perfect Low Lunge!");
  }

  // 15. PIGEON POSE
  static PoseEvaluation _checkPigeonPose(Pose pose) {
    if (!_isLyingDown(pose)) return PoseEvaluation(false, "Get on the floor.");

    final hip = pose.landmarks[PoseLandmarkType.leftHip];
    final shoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    
    if (hip != null && shoulder != null) {
      // Check for upright torso (King Pigeon variation) or simply hips grounded.
      // Simple check: Hips and shoulders visible, user is on floor.
      // We assume if they are 'LyingDown' shape but shoulder is significantly higher than hip, they are upright.
      if (shoulder.y > hip.y) {
         return PoseEvaluation(false, "Sit up tall.");
      }
    }
    
    return PoseEvaluation(true, "Perfect Pigeon Pose!");
  }
  
  // 16. DOWNWARD DOG (Adho Mukha Svanasana)
static PoseEvaluation _checkDownwardDog(Pose pose) {
  final hip = pose.landmarks[PoseLandmarkType.leftHip];
  final shoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
  final ankle = pose.landmarks[PoseLandmarkType.leftAnkle];

  if (hip == null || shoulder == null || ankle == null) return PoseEvaluation(false, "Side view needed.");

  // CHECK 1: Hips must be the Highest Point (Apex of the V)
  // Remember: Smaller Y = Higher on screen
  if (hip.y > shoulder.y || hip.y > ankle.y) {
    return PoseEvaluation(false, "Lift your hips higher.");
  }

  // CHECK 2: V-Shape Angle (Hip Angle)
  // Should be sharp (approx 70-110 degrees). If > 130, you're in Plank.
  double hipAngle = _getAngle(pose, PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee);
  if (hipAngle > 120) {
    return PoseEvaluation(false, "Push chest to thighs (make a V shape).");
  }

  // CHECK 3: Straight Legs (Optional but good form)
  double kneeAngle = _getAngle(pose, PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle);
  if (kneeAngle < 150) {
    return PoseEvaluation(false, "Straighten your legs.");
  }

  return PoseEvaluation(true, "Perfect Downward Dog!");
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