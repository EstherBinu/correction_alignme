import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PosePainter extends CustomPainter {
  final List<Pose> poses;
  final Size absoluteImageSize;
  final InputImageRotation rotation;

  PosePainter(this.poses, this.absoluteImageSize, this.rotation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    for (final pose in poses) {
      // 1. Logic: Check for Mountain Pose using ANGLES
      bool isCorrect = _checkMountainPose(pose);
      paint.color = isCorrect ? Colors.green : Colors.red;

      // 2. Draw Skeleton
      _drawAllConnections(canvas, pose, paint, size);
    }
  }

  // --- NEW: ADVANCED MATH LOGIC ---
  bool _checkMountainPose(Pose pose) {
    // We check 3 conditions for a perfect Mountain Pose (Tadasana)

    // A. HIP ANGLE: Is the body straight? (Shoulder -> Hip -> Knee)
    // We expect ~180 degrees. We allow 160-180.
    double leftHipAngle = _getAngle(
      pose.landmarks[PoseLandmarkType.leftShoulder],
      pose.landmarks[PoseLandmarkType.leftHip],
      pose.landmarks[PoseLandmarkType.leftKnee],
    );

    // B. ELBOW ANGLE: Are arms straight? (Shoulder -> Elbow -> Wrist)
    // We expect ~180 degrees. We allow 160-180.
    double leftArmAngle = _getAngle(
      pose.landmarks[PoseLandmarkType.leftShoulder],
      pose.landmarks[PoseLandmarkType.leftElbow],
      pose.landmarks[PoseLandmarkType.leftWrist],
    );
    double rightArmAngle = _getAngle(
      pose.landmarks[PoseLandmarkType.rightShoulder],
      pose.landmarks[PoseLandmarkType.rightElbow],
      pose.landmarks[PoseLandmarkType.rightWrist],
    );

    // C. SHOULDER ANGLE: Are arms down by the side? (Hip -> Shoulder -> Elbow)
    // We expect ~0-20 degrees relative to the torso.
    double leftShoulderAngle = _getAngle(
      pose.landmarks[PoseLandmarkType.leftHip],
      pose.landmarks[PoseLandmarkType.leftShoulder],
      pose.landmarks[PoseLandmarkType.leftElbow],
    );
    double rightShoulderAngle = _getAngle(
      pose.landmarks[PoseLandmarkType.rightHip],
      pose.landmarks[PoseLandmarkType.rightShoulder],
      pose.landmarks[PoseLandmarkType.rightElbow],
    );

    // --- THE CHECK ---
    
    // 1. Body must be relatively straight (not bending forward too much)
    bool isBodyStraight = leftHipAngle > 150; 

    // 2. Arms must be straight
    bool areArmsStraight = leftArmAngle > 160 && rightArmAngle > 160;

    // 3. Arms must be down (close to body)
    // Note: Angles can be tricky depending on how they are measured. 
    // Usually, arms down creates a small angle with the torso.
    bool areArmsDown = leftShoulderAngle < 35 && rightShoulderAngle < 35;

    return isBodyStraight && areArmsStraight && areArmsDown;
  }

  // --- HELPER: CALCULATE ANGLE ---
  double _getAngle(PoseLandmark? first, PoseLandmark? mid, PoseLandmark? last) {
    if (first == null || mid == null || last == null) return 0.0;

    // Use atan2 to get the angle of the lines
    final double radians = math.atan2(last.y - mid.y, last.x - mid.x) -
                           math.atan2(first.y - mid.y, first.x - mid.x);
    
    double degrees = (radians * 180.0 / math.pi).abs();
    
    // Normalize to 0-180
    if (degrees > 180.0) {
      degrees = 360.0 - degrees;
    }
    return degrees;
  }

  // --- DRAWING HELPER ---
  void _drawAllConnections(Canvas canvas, Pose pose, Paint paint, Size size) {
    // Arms
    _drawConnection(canvas, pose, PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow, paint, size);
    _drawConnection(canvas, pose, PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist, paint, size);
    _drawConnection(canvas, pose, PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow, paint, size);
    _drawConnection(canvas, pose, PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist, paint, size);

    // Body
    _drawConnection(canvas, pose, PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, paint, size);
    _drawConnection(canvas, pose, PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip, paint, size);
    _drawConnection(canvas, pose, PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder, paint, size);
    _drawConnection(canvas, pose, PoseLandmarkType.leftHip, PoseLandmarkType.rightHip, paint, size);

    // Legs
    _drawConnection(canvas, pose, PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, paint, size);
    _drawConnection(canvas, pose, PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle, paint, size);
    _drawConnection(canvas, pose, PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee, paint, size);
    _drawConnection(canvas, pose, PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle, paint, size);
  }

  void _drawConnection(Canvas canvas, Pose pose, PoseLandmarkType type1, PoseLandmarkType type2, Paint paint, Size screen) {
    final p1 = pose.landmarks[type1];
    final p2 = pose.landmarks[type2];

    if (p1 == null || p2 == null) return;

    final double scaleX = screen.width / absoluteImageSize.width;
    final double scaleY = screen.height / absoluteImageSize.height;

    // Mirroring Fix: screen.width - (x * scaleX)
    final x1 = screen.width - (p1.x * scaleX);
    final y1 = p1.y * scaleY;
    final x2 = screen.width - (p2.x * scaleX);
    final y2 = p2.y * scaleY;

    canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.poses != poses;
  }
}