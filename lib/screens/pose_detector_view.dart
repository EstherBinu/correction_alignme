import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../main.dart'; // To get the 'cameras' list
import '../utils/camera_utils.dart'; // The translator
import '../painters/pose_painter.dart'; // The painter we just created
import 'dart:io'; // Add this at the very top

class PoseDetectorView extends StatefulWidget {
  const PoseDetectorView({super.key});

  @override
  State<PoseDetectorView> createState() => _PoseDetectorViewState();
}

class _PoseDetectorViewState extends State<PoseDetectorView> {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;

  // The AI Detector
  final PoseDetector _poseDetector = PoseDetector(
    options: PoseDetectorOptions(),
  );

  // Variable to store the detected pose to draw later
  List<Pose> _poses = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() async {
    // 1. Pick the first Front Camera, or fallback to any camera
    final camera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      camera,
      ResolutionPreset.medium, // High res often breaks detection on Samsung
      enableAudio: false,
      // FORCE the format to NV21 (The "Silver Bullet" for Android)
      imageFormatGroup: Platform.isAndroid 
          ? ImageFormatGroup.nv21 
          : ImageFormatGroup.bgra8888,
    );

    // 2. Initialize
    await _controller!.initialize();

    // 3. Start Streaming
    if (!mounted) return;

    // Fix orientation to portrait
    await _controller!.lockCaptureOrientation(DeviceOrientation.portraitUp);

    _controller!.startImageStream((CameraImage image) {
      if (_isProcessing) return; // Skip frame if busy
      _isProcessing = true;
      _processImage(image, camera);
    });

    setState(() {
      _isCameraInitialized = true;
    });
  }

  // The Loop: Camera Image -> AI -> Results
  Future<void> _processImage(
    CameraImage image,
    CameraDescription camera,
  ) async {
    try {
      final inputImage = CameraUtils.inputImageFromCameraImage(
        image,
        camera,
        DeviceOrientation.portraitUp,
      );

      final poses = await _poseDetector.processImage(inputImage);

      if (mounted) {
        setState(() {
          _poses = poses; // Save poses to draw
        });
      }
    } catch (e) {
      print("Error processing image: $e");
    } finally {
      _isProcessing = false;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized || _controller == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Calculate the size of the camera image to help with drawing
    // We swap width and height because the camera sensor is landscape but the phone is portrait
    final Size imageSize = Size(
      _controller!.value.previewSize!.height, 
      _controller!.value.previewSize!.width,
    );

    return Scaffold(
      body: Stack(
        children: [
          // Layer 1: The Camera Feed
          CameraPreview(_controller!),

          // Layer 2: The Skeleton Painter
          // We only draw if we found a person
          if (_poses.isNotEmpty)
            CustomPaint(
              painter: PosePainter(
                _poses, 
                imageSize, 
                InputImageRotation.rotation90deg // Android Portrait default
              ),
              child: Container(),
            ),

          // Layer 3: Status Text
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _poses.isNotEmpty ? "Pose Detected: Active" : "No Person Detected\n(Try rotating phone or stepping back)",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),

          // Close Button
          Positioned(
            top: 50,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}