import 'dart:async';
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
import 'success_screen.dart';

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

  // --- TIMERS ---
  Timer? _gameTimer; // Runs every second
  int _holdSeconds = 0;      // How long user held GREEN (Goal: 5s)
  final int _targetHold = 5; 
  
  int _elapsedSessionSeconds = 0; // Total time spent in session
  final int _maxSessionTime = 60; // Max time allowed (60s limit)

  bool _isCompleted = false; 
  final Set<String> _feedbackLog = {}; 
  bool _hasEnteredCorrectPoseOnce = false; 

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initTts();
    _startGameLoop(); // Start the 1-second ticker
  }

  void _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
  }

  void _startGameLoop() {
    // One single timer to handle both "Session Time" and "Hold Time"
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isCompleted) return;

      setState(() {
        _elapsedSessionSeconds++; // Always increase session time
      });

      // 1. CHECK TIMEOUT (Did they run out of time?)
      if (_elapsedSessionSeconds >= _maxSessionTime) {
        _finishSession(false); // Failed (Time out)
        return;
      }

      // 2. CHECK HOLD SUCCESS (Are they holding it green?)
      if (_isPostureCorrect) {
        setState(() => _holdSeconds++);
        if (_holdSeconds >= _targetHold) {
          _finishSession(true); // Success!
        }
      } else {
        // Reset hold timer if they wobble
        if (_holdSeconds > 0) setState(() => _holdSeconds = 0);
      }
    });
  }

  void _finishSession(bool isSuccess) async {
    _isCompleted = true;
    _gameTimer?.cancel();
    
    if (isSuccess) {
      await _flutterTts.speak("Great job! Pose complete.");
    } else {
      await _flutterTts.speak("Time is up. Let's review.");
    }
    
    if (!mounted) return;
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SuccessScreen(
          poseName: widget.poseName,
          feedbackSummary: _feedbackLog.toList(),
          isSuccess: isSuccess, // Pass the result status
        ),
      ),
    );
  }

  // ... (Rest of the Camera/AI code is unchanged, I'll paste the standard blocks below) ...

  void _initializeCamera() async {
    final camera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );
    _controller = CameraController(camera, ResolutionPreset.high, enableAudio: false, imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888);
    await _controller!.initialize();
    if (!mounted) return;
    await _controller!.lockCaptureOrientation(DeviceOrientation.portraitUp);
    _controller!.startImageStream((CameraImage image) {
      if (_isProcessing) return; 
      _isProcessing = true;
      _processImage(image, camera);
    });
    setState(() => _isCameraInitialized = true);
  }

  Future<void> _processImage(CameraImage image, CameraDescription camera) async {
    if (_isCompleted) return; 
    try {
      final inputImage = CameraUtils.inputImageFromCameraImage(image, camera, DeviceOrientation.portraitUp);
      final poses = await _poseDetector.processImage(inputImage);

      bool isCorrect = false;
      String feedback = "No Pose Detected";

      if (poses.isNotEmpty) {
        final evaluation = PoseMatcher.evaluate(poses.first, widget.poseName);
        isCorrect = evaluation.isCorrect;
        feedback = evaluation.feedback;
        
        if (isCorrect) {
          if (!_hasEnteredCorrectPoseOnce) {
             _feedbackLog.clear(); // Clear setup errors
             _hasEnteredCorrectPoseOnce = true;
          }
        } else {
          if (_hasEnteredCorrectPoseOnce && 
              feedback != "Perfect ${widget.poseName}!" && 
              feedback != "Step back. Show your full body." &&
              feedback != "Unknown Pose") {
             _feedbackLog.add(feedback);
          }
        }
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
    _gameTimer?.cancel();
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
    final Size imageSize = Size(_controller!.value.previewSize!.height, _controller!.value.previewSize!.width);

    return Scaffold(
      body: Stack(
        children: [
          Transform.scale(scale: scale, child: Center(child: CameraPreview(_controller!))),
          if (_poses.isNotEmpty)
            Transform.scale(scale: scale, child: Center(child: CustomPaint(painter: PosePainter(_poses, imageSize, InputImageRotation.rotation90deg, _isPostureCorrect), child: Container(width: double.infinity, height: double.infinity)))),
          
          // --- TOP BAR: TIME REMAINING ---
          Positioned(
            top: 50, left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                   const Icon(Icons.timer, color: Colors.white, size: 20),
                   const SizedBox(width: 5),
                   Text("${_maxSessionTime - _elapsedSessionSeconds}s", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
          ),

          // --- PROGRESS BAR (HOLD TIME) ---
          if (_isPostureCorrect)
            Positioned(
              top: 100, left: 40, right: 40,
              child: Column(
                children: [
                  Text("Hold it! $_holdSeconds / $_targetHold", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 5)])),
                  LinearProgressIndicator(value: _holdSeconds / _targetHold, color: Colors.greenAccent, minHeight: 8),
                ],
              ),
            ),

          Positioned(
            bottom: 50, left: 20, right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: _isPostureCorrect ? Colors.green.withOpacity(0.9) : Colors.red.withOpacity(0.9), borderRadius: BorderRadius.circular(12)),
              child: Text(_feedbackMessage, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          ),
          
          Positioned(top: 50, right: 20, child: IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 30), onPressed: () => Navigator.pop(context))),
        ],
      ),
    );
  }
}