import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class CameraUtils {
  static InputImage inputImageFromCameraImage(
      CameraImage image, 
      CameraDescription camera, 
      DeviceOrientation deviceOrientation
  ) {
    final sensorOrientation = camera.sensorOrientation;
    
    // 1. Calculate Rotation
    InputImageRotation? rotation;
    if (Platform.isAndroid) {
      var rotationCompensation = _orientations[deviceOrientation];
      if (rotationCompensation == null) return InputImage.fromFilePath(''); 
      
      if (camera.lensDirection == CameraLensDirection.front) {
        // Front camera needs mirroring logic
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        // Back camera
        rotationCompensation = (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    rotation ??= InputImageRotation.rotation0deg;

    // 2. Formatting - Force NV21 check
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    
    // 3. Data Extraction (The Samsung Fix)
    // On some devices, using just plane[0] is not enough if the stride is weird.
    // However, for Pose Detection, we primarily need the Y (Luminance) plane.
    
    if (image.planes.isEmpty) return InputImage.fromFilePath('');
    
    // Calculate the 'row stride' vs 'width' difference
    final plane = image.planes.first;
    
    return InputImage.fromBytes(
      bytes: plane.bytes, 
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format ?? InputImageFormat.nv21,
        bytesPerRow: plane.bytesPerRow, 
      ),
    );
  }

  static final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };
}