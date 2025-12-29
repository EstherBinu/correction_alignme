import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'pose_selection_screen.dart'; // Import to go back home

class SuccessScreen extends StatelessWidget {
  final String poseName;

  const SuccessScreen({super.key, required this.poseName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            
            // Success Icon
            Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.check_circle, size: 100, color: Colors.green),
              ),
            ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

            const SizedBox(height: 30),

            const Text(
              "Great Job!",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.5, end: 0),

            const SizedBox(height: 10),

            Text(
              "You mastered $poseName",
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ).animate().fadeIn(delay: 500.ms),

            const Spacer(),

            // Home Button
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // Go back to the main menu (remove all previous screens)
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const PoseSelectionScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7EA6FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text("Back to Menu", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}