import 'dart:async'; // Need this for Timer
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:flutter_tts/flutter_tts.dart'; 
import '../main.dart'; 
import '../utils/camera_utils.dart';
import '../painters/pose_painter.dart';
import '../logic/pose_matcher.dart'; 
import 'success_screen.dart'; // NEW: Import Success Screen

class PoseDetectorView extends StatefulWidget {
  final String poseName;
  const PoseDetectorView({super.key, required this.poseName});

  @override
  State<PoseDetectorView> createState() => _PoseDetectorViewState();
}

class _PoseDetectorViewState extends State<PoseDetectorView> {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  
  final PoseDetector _poseDetector = PoseDetector(options: PoseDetectorOptions());
  final FlutterTts _flutterTts = FlutterTts();
  
  List<Pose> _poses = [];
  bool _isPostureCorrect = false; 
  String _feedbackMessage = "Align your body"; 
  DateTime? _lastSpokenTime; 

  // --- NEW: HOLD TIMER VARIABLES ---
  Timer? _successTimer;
  int _successSeconds = 0;
  final int _targetSeconds = 5; // Hold for 5 seconds to win
  bool _isCompleted = false; // To prevent double navigation

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initTts();
    _startHoldTimer(); // Start the checker
  }

  void _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
  }

  void _startHoldTimer() {
    // Check every 1 second
    _successTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPostureCorrect && !_isCompleted) {
        setState(() {
          _successSeconds++;
        });
        
        // WIN CONDITION
        if (_successSeconds >= _targetSeconds) {
          _completeExercise();
        }
      } else {
        // Reset if they lose the pose
        if (_successSeconds > 0) {
           setState(() {
             _successSeconds = 0;
           });
        }
      }
    });
  }

  void _completeExercise() async {
    _isCompleted = true;
    _successTimer?.cancel();
    await _flutterTts.speak("Great job! Exercise completed.");
    
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SuccessScreen(poseName: widget.poseName)),
    );
  }

  void _initializeCamera() async {
    final camera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
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
    if (_isCompleted) return; // Stop processing if won

    try {
      final inputImage = CameraUtils.inputImageFromCameraImage(
        image, camera, DeviceOrientation.portraitUp
      );
      final poses = await _poseDetector.processImage(inputImage);

      bool isCorrect = false;
      String feedback = "No Pose Detected";

      if (poses.isNotEmpty) {
        final evaluation = PoseMatcher.evaluate(poses.first, widget.poseName);
        isCorrect = evaluation.isCorrect;
        feedback = evaluation.feedback;
        _handleVoiceFeedback(isCorrect, feedback);
      }

      if (mounted) {
        setState(() {
          _poses = poses;
          _isPostureCorrect = isCorrect; 
          _feedbackMessage = feedback; 
        });
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      _isProcessing = false;
    }
  }

  void _handleVoiceFeedback(bool isCorrect, String message) async {
    if (isCorrect) return; 
    if (_lastSpokenTime == null || DateTime.now().difference(_lastSpokenTime!).inSeconds > 4) {
      _lastSpokenTime = DateTime.now();
      await _flutterTts.speak(message); 
    }
  }

  @override
  void dispose() {
    _successTimer?.cancel(); // Cancel timer
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

    final size = MediaQuery.of(context).size;
    var scale = size.aspectRatio * _controller!.value.aspectRatio;
    if (scale < 1) scale = 1 / scale;

    final Size imageSize = Size(
      _controller!.value.previewSize!.height, 
      _controller!.value.previewSize!.width,
    );

    return Scaffold(
      body: Stack(
        children: [
          Transform.scale(scale: scale, child: Center(child: CameraPreview(_controller!))),
          
          if (_poses.isNotEmpty)
            Transform.scale(
              scale: scale,
              child: Center(
                child: CustomPaint(
                  painter: PosePainter(_poses, imageSize, InputImageRotation.rotation90deg, _isPostureCorrect),
                  child: Container(width: double.infinity, height: double.infinity),
                ),
              ),
            ),
            
          // --- PROGRESS BAR ---
          if (_isPostureCorrect)
            Positioned(
              top: 60,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  Text("Hold Steady: $_successSeconds / $_targetSeconds", 
                       style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black, blurRadius: 4)])),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: _successSeconds / _targetSeconds,
                    color: Colors.greenAccent,
                    backgroundColor: Colors.white30,
                    minHeight: 10,
                  ),
                ],
              ),
            ),

          // Feedback Box
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isPostureCorrect ? Colors.green.withOpacity(0.9) : Colors.red.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _feedbackMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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