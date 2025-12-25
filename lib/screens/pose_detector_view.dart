import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:flutter_tts/flutter_tts.dart'; // NEW: Voice
import '../main.dart'; 
import '../utils/camera_utils.dart';
import '../painters/pose_painter.dart';
import '../logic/pose_matcher.dart'; // NEW: Logic

class PoseDetectorView extends StatefulWidget {
  const PoseDetectorView({super.key});

  @override
  State<PoseDetectorView> createState() => _PoseDetectorViewState();
}

class _PoseDetectorViewState extends State<PoseDetectorView> {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  
  // Voice & Logic Variables
  final PoseDetector _poseDetector = PoseDetector(options: PoseDetectorOptions());
  final FlutterTts _flutterTts = FlutterTts();
  List<Pose> _poses = [];
  bool _isPostureCorrect = false; // State to track Green/Red
  DateTime? _lastSpokenTime; // To avoid spamming voice

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initTts();
  }

  void _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
  }

  void _initializeCamera() async {
    final camera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      camera,
      ResolutionPreset.medium, 
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid 
          ? ImageFormatGroup.nv21 
          : ImageFormatGroup.bgra8888,
    );

    await _controller!.initialize();
    if (!mounted) return;
    await _controller!.lockCaptureOrientation(DeviceOrientation.portraitUp);

    _controller!.startImageStream((CameraImage image) {
      if (_isProcessing) return; 
      _isProcessing = true;
      _processImage(image, camera);
    });

    setState(() {
      _isCameraInitialized = true;
    });
  }

  Future<void> _processImage(CameraImage image, CameraDescription camera) async {
    try {
      final inputImage = CameraUtils.inputImageFromCameraImage(
        image, camera, DeviceOrientation.portraitUp
      );
      final poses = await _poseDetector.processImage(inputImage);

      // --- NEW: LOGIC & VOICE BLOCK ---
      bool isCorrect = false;
      if (poses.isNotEmpty) {
        // Evaluate the first detected person
        isCorrect = PoseMatcher.evaluate(poses.first, "Mountain Pose");
        _handleVoiceFeedback(isCorrect);
      }
      // --------------------------------

      if (mounted) {
        setState(() {
          _poses = poses;
          _isPostureCorrect = isCorrect; // Update UI Color
        });
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      _isProcessing = false;
    }
  }

  void _handleVoiceFeedback(bool isCorrect) async {
    if (isCorrect) return; // Silence if posture is good!

    // If posture is bad, speak every 5 seconds
    if (_lastSpokenTime == null || 
        DateTime.now().difference(_lastSpokenTime!).inSeconds > 5) {
      
      _lastSpokenTime = DateTime.now();
      await _flutterTts.speak("Please straighten your arms and stand tall.");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _poseDetector.close();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized || _controller == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final Size imageSize = Size(
      _controller!.value.previewSize!.height, 
      _controller!.value.previewSize!.width,
    );

    return Scaffold(
      body: Stack(
        children: [
          CameraPreview(_controller!),
          if (_poses.isNotEmpty)
            CustomPaint(
              painter: PosePainter(
                _poses, 
                imageSize, 
                InputImageRotation.rotation90deg,
                _isPostureCorrect // Pass the computed color here
              ),
              child: Container(),
            ),
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isPostureCorrect ? Colors.green.withOpacity(0.8) : Colors.red.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _isPostureCorrect ? "Perfect Posture!" : "Adjust Your Body",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Positioned(
            top: 50, right: 20,
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