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

  // --- STATIC DATA: INSTRUCTIONS ---
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
    ]
  };

  void _showTutorial(BuildContext context) {
    final List<String> steps = _poseInstructions[poseName] ?? ["Follow standard yoga guidelines."];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.menu_book, color: Color(0xFF7EA6FF), size: 28),
                  const SizedBox(width: 10),
                  Text("How to do $poseName", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),
              ...steps.map((step) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.circle, size: 8, color: Colors.grey),
                    const SizedBox(width: 10),
                    Expanded(child: Text(step, style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.4))),
                  ],
                ),
              )),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7EA6FF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  child: const Text("Got it!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            ],
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
    final String subText = isSuccess ? "You mastered $poseName!" : "Let's review your form.";

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                
                // 1. Icon
                Container(
                  height: 100, width: 100,
                  decoration: BoxDecoration(color: mainColor.withOpacity(0.1), shape: BoxShape.circle),
                  child: Center(child: Icon(mainIcon, size: 50, color: mainColor)),
                ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

                const SizedBox(height: 20),

                Text(titleText, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.grey[800])).animate().fadeIn().slideY(begin: 0.3, end: 0),
                Text(subText, style: TextStyle(fontSize: 16, color: Colors.grey[500])),

                const SizedBox(height: 30),

                // 2. Feedback Card (Only if errors exist)
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
                  const SizedBox(height: 30),
                ] else ...[
                   // If perfect run or just time out without specific errors, add some spacing
                   const SizedBox(height: 50),
                ],

                // 3. ACTION BUTTONS
                Row(
                  children: [
                    // A. View Tutorial Button
                    Expanded(
                      child: SizedBox(
                        height: 55,
                        child: OutlinedButton(
                          onPressed: () => _showTutorial(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF7EA6FF), width: 2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                          child: const Text("View Tutorial", style: TextStyle(color: Color(0xFF7EA6FF), fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 15),

                    // B. Back to Menu Button
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
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}