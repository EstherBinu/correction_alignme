import 'package:flutter/material.dart';
import 'dart:async';
import 'pose_detector_view.dart'; // Import the camera screen

class TimerScreen extends StatefulWidget {
  final String poseName;

  const TimerScreen({super.key, required this.poseName});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  int _seconds = 5; // Start from 5
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_seconds > 0) {
          _seconds--;
        } else {
          _timer?.cancel();
          _navigateToCamera();
        }
      });
    });
  }

  void _navigateToCamera() {
    // Replace this screen with the Camera screen so back button goes to Home
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PoseDetectorView(poseName: widget.poseName),),
    );
  }

  @override
  void dispose() {
    _timer?.cancel(); // Always cancel timers to stop memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Get Ready for\n${widget.poseName}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white, 
                fontSize: 28, 
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 50),
            // The Big Number
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: Text(
                "$_seconds",
                style: const TextStyle(
                  fontSize: 80, 
                  color: Colors.white, 
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Step back and position your full body in the frame.",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            )
          ],
        ),
      ),
    );
  }
}