import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'pose_selection_screen.dart';

class SuccessScreen extends StatelessWidget {
  final String poseName;
  final List<String> feedbackSummary;
  final bool isSuccess;

  const SuccessScreen({
    super.key, 
    required this.poseName,
    required this.feedbackSummary,
    this.isSuccess = true,
  });

  // --- 1. DATA: Instructions Text ---
  static const Map<String, List<String>> _poseInstructions = {
    "Mountain Pose": [
      "1. Stand tall with feet together.",
      "2. Keep your legs straight.",
      "3. Relax your shoulders down.",
      "4. Let arms hang by your sides.",
      "5. Look straight ahead."
    ],
    "Tree Pose": [
      "1. Stand on one leg (standing leg straight).",
      "2. Place your other foot on your inner thigh or calf.",
      "3. Open your bent knee to the side.",
      "4. Raise your arms overhead.",
      "5. Join your palms together (Prayer position)."
    ],
    "Warrior Pose": [
      "1. Step your feet wide apart.",
      "2. Turn your right foot out 90 degrees.",
      "3. Bend your front knee (aim for 90 degrees).",
      "4. Keep your back leg straight.",
      "5. Raise arms to shoulder height (T-Shape)."
    ],
    "Bridge Pose": [
      "1. Lie on your back.",
      "2. Bend your knees, feet flat on floor.",
      "3. Lift your hips high toward the ceiling.",
      "4. Keep shoulders grounded.",
      "5. Ensure knees are directly over ankles."
    ],
    "Chair Pose": [
      "1. Stand tall, feet together.",
      "2. Bend knees like sitting in a chair.",
      "3. Raise arms overhead.",
      "4. Keep back straight."
    ],
    "Cobra Pose": [
      "1. Lie on stomach.",
      "2. Hands under shoulders.",
      "3. Push chest up off floor.",
      "4. Keep hips grounded."
    ],
    "Triangle Pose": [
      "1. Feet wide apart.",
      "2. Reach forward and tilt down.",
      "3. Bottom hand touches shin/floor.",
      "4. Top hand reaches up to ceiling."
    ],
    "Forward Bend": [
      "1. Stand tall.",
      "2. Hinge at hips to fold forward.",
      "3. Reach hands to floor or shins.",
      "4. Keep legs straight or micro-bent."
    ],
    "Side Stretch": [
      "1. Stand tall, feet hip-width.",
      "2. Raise one arm overhead.",
      "3. Lean gently to the opposite side.",
      "4. Keep chest open."
    ]
  };

  // --- 2. DATA: Image Paths (Matches your Selection Screen) ---
  static const Map<String, String> _poseImages = {
    "Mountain Pose": "assets/cat-cow.jpg",
    "Tree Pose": "assets/pigeon-pose.jpg",
    "Warrior Pose": "assets/warrior2.jpg",
    "Bridge Pose": "assets/bridge-pose.jpg",
    "Chair Pose": "assets/chair-pose.jpg",
    "Cobra Pose": "assets/cobra.jpg", 
    "Triangle Pose": "assets/triangle.jpg",
    "Forward Bend": "assets/forward-bend.jpg",
    "Side Stretch": "assets/side-stretch.jpg",
  };

  // --- 3. LOGIC: Show Image Popup ---
  void _showImageTutorial(BuildContext context) {
    final String imagePath = _poseImages[poseName] ?? "";
    
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "$poseName Visual",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: imagePath.isNotEmpty 
                    ? Image.asset(imagePath, fit: BoxFit.cover)
                    : Container(height: 200, color: Colors.grey[200], child: const Center(child: Icon(Icons.image, size: 50, color: Colors.grey))),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7EA6FF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Close", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color mainColor = isSuccess ? Colors.green : Colors.orange;
    final IconData mainIcon = isSuccess ? Icons.emoji_events : Icons.timer_off;
    final String titleText = isSuccess ? "Session Complete!" : "Time's Up!";
    final String subText = isSuccess ? "You mastered $poseName!" : "Let's review the form.";
    
    // Get instructions
    final List<String> steps = _poseInstructions[poseName] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // --- SCROLLABLE CONTENT ---
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      
                      // Header Icon
                      Container(
                        height: 100, width: 100,
                        decoration: BoxDecoration(color: mainColor.withOpacity(0.1), shape: BoxShape.circle),
                        child: Center(child: Icon(mainIcon, size: 50, color: mainColor)),
                      ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

                      const SizedBox(height: 20),
                      Text(titleText, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.grey[800])).animate().fadeIn().slideY(begin: 0.3, end: 0),
                      Text(subText, style: TextStyle(fontSize: 16, color: Colors.grey[500])),
                      const SizedBox(height: 30),

                      // A. Feedback Section (Only if errors exist)
                      if (feedbackSummary.isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.orange.withOpacity(0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Areas for Improvement", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
                              const SizedBox(height: 10),
                              ...feedbackSummary.map((msg) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                                    const SizedBox(width: 10),
                                    Expanded(child: Text(msg, style: TextStyle(fontSize: 15, color: Colors.grey[800]))),
                                  ],
                                ),
                              )).toList(),
                            ],
                          ),
                        ).animate().fadeIn(delay: 200.ms),
                        const SizedBox(height: 20),
                      ],

                      // B. Instructions Section (ALWAYS VISIBLE)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.menu_book, color: Color(0xFF7EA6FF), size: 24),
                                const SizedBox(width: 10),
                                Text("Steps for $poseName", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 15),
                            if (steps.isNotEmpty)
                              ...steps.map((step) => Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.circle, size: 8, color: Colors.grey),
                                    const SizedBox(width: 10),
                                    Expanded(child: Text(step, style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.4))),
                                  ],
                                ),
                              )).toList()
                            else
                              const Text("Follow standard yoga guidelines."),
                          ],
                        ),
                      ).animate().fadeIn(delay: 400.ms),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),

            // --- BOTTOM BUTTONS (Fixed at bottom) ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))],
              ),
              child: Row(
                children: [
                  // Button 1: Visual Tutorial (Popup)
                  Expanded(
                    child: SizedBox(
                      height: 55,
                      child: OutlinedButton(
                        onPressed: () => _showImageTutorial(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF7EA6FF), width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                        child: const Text("Visual Tutorial", style: TextStyle(color: Color(0xFF7EA6FF), fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 15),

                  // Button 2: Back to Menu
                  Expanded(
                    child: SizedBox(
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const PoseSelectionScreen()),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7EA6FF),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          elevation: 0,
                        ),
                        child: const Text("Menu", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}