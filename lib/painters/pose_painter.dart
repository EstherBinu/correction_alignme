import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PosePainter extends CustomPainter {
  final List<Pose> poses;
  final Size absoluteImageSize;
  final InputImageRotation rotation;
  final bool isPostureCorrect;

  PosePainter(this.poses, this.absoluteImageSize, this.rotation, this.isPostureCorrect);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = isPostureCorrect ? Colors.green : Colors.red;

    final jointPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;

    for (final pose in poses) {
      // 1. Draw Bones (Lines)
      _drawAllConnections(canvas, pose, paint, size);
      
      // 2. Draw Joints (Circles) - NEW
      for (final landmark in pose.landmarks.values) {
        _drawJoint(canvas, landmark, jointPaint, size);
      }
    }
  }

  void _drawJoint(Canvas canvas, PoseLandmark landmark, Paint paint, Size screen) {
    // Skip if invisible
    if (landmark.likelihood < 0.5) return;

    final double scaleX = screen.width / absoluteImageSize.width;
    final double scaleY = screen.height / absoluteImageSize.height;

    // Apply Mirroring & Scaling
    final x = screen.width - (landmark.x * scaleX);
    final y = landmark.y * scaleY;

    // Draw a circle with radius 5
    canvas.drawCircle(Offset(x, y), 5, paint);
  }

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

    final x1 = screen.width - (p1.x * scaleX);
    final y1 = p1.y * scaleY;
    final x2 = screen.width - (p2.x * scaleX);
    final y2 = p2.y * scaleY;

    canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.poses != poses || oldDelegate.isPostureCorrect != isPostureCorrect;
  }
}