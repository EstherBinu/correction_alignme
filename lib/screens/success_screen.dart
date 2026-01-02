import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart'; // NEW: For YouTube
import 'pose_selection_screen.dart';

class SuccessScreen extends StatelessWidget {
  final String poseName;
  final List<String> feedbackSummary;
  final bool isSuccess;
  final int poseIndex; // To remember which slide to return to

  const SuccessScreen({
    super.key, 
    required this.poseName,
    required this.feedbackSummary,
    this.isSuccess = true,
    required this.poseIndex,
  });

  // --- 1. DATA: Instructions Text ---
  static const Map<String, List<String>> _poseInstructions = {
    "Mountain Pose": ["1. Stand tall.", "2. Feet together.", "3. Shoulders relaxed.", "4. Arms by sides."],
    "Tree Pose": ["1. Stand on one leg.", "2. Foot on inner thigh.", "3. Knee out to side.", "4. Hands in prayer."],
    "Warrior Pose": ["1. Feet wide apart.", "2. Front knee bent.", "3. Arms T-shape.", "4. Look over front hand."],
    "Bridge Pose": ["1. Lie on back.", "2. Knees bent.", "3. Lift hips high.", "4. Chin to chest."],
    "Chair Pose": ["1. Feet together.", "2. Bend knees.", "3. Arms up.", "4. Back straight."],
    "Cobra Pose": ["1. Lie on stomach.", "2. Push chest up.", "3. Hips on floor.", "4. Look up."],
    "Triangle Pose": ["1. Wide stance.", "2. Lean sideways.", "3. One hand down, one up."],
    "Forward Bend": ["1. Stand tall.", "2. Fold forward.", "3. Touch floor/shins."],
    "Side Stretch": ["1. Stand tall.", "2. Raise one arm.", "3. Lean to side."],
    "Plank Pose": ["1. Push-up position.", "2. Body straight line.", "3. Core tight.", "4. Don't sag hips."],
    "Cat Pose": ["1. Hands and knees.", "2. Arch back up.", "3. Chin to chest.", "4. Look at belly."],
    "Cow Pose": ["1. Hands and knees.", "2. Drop belly down.", "3. Lift head up.", "4. Arch spine down."],
    "Low Lunge": ["1. One foot forward.", "2. Back knee on floor.", "3. Hips forward.", "4. Arms up."],
    "Boat Pose": ["1. Sit on floor.", "2. Lean back slightly.", "3. Lift legs up.", "4. Arms forward (V-shape)."],
    "Pigeon Pose": ["1. One leg forward bent.", "2. Back leg straight.", "3. Hips square.", "4. Sit tall."],
    "Downward Dog": ["1. Hands and knees.", "2. Hips up high.", "3. Legs straight.", "4. Chest to thighs."],
  };

  // --- 2. DATA: Image Paths ---
  static const Map<String, String> _poseImages = {
    "Mountain Pose": "assets/mountain.jpg",
    "Tree Pose": "assets/pigeon-pose.jpg",
    "Warrior Pose": "assets/warrior2.jpg",
    "Bridge Pose": "assets/bridge-pose.jpg",
    "Chair Pose": "assets/chair-pose.jpg",
    "Cobra Pose": "assets/cobra.jpg", 
    "Triangle Pose": "assets/triangle.jpg",
    "Forward Bend": "assets/forward-bend.jpg",
    "Side Stretch": "assets/side-stretch.jpg",
    "Plank Pose": "assets/plank.jpg",
    "Cat Pose": "assets/cat.jpg",
    "Cow Pose": "assets/cow.jpg",
    "Low Lunge": "assets/low-lunge.jpg",
    "Boat Pose": "assets/boat.jpg",
    "Pigeon Pose": "assets/pigeon.jpg",
    "Downward Dog": "assets/downward-dog.jpg",
  };

  // --- 3. DATA: YouTube Video Links (NEW) ---
  static const Map<String, String> _poseVideos = {
    "Mountain Pose": "https://youtu.be/5NxDs-ovJU8?si=2lS5j98kd4FYAt1D",
    "Tree Pose": "https://www.youtube.com/watch?v=wdln9qWYloU",
    "Warrior Pose": "https://www.youtube.com/watch?v=5rM6a54t72M",
    "Bridge Pose": "https://www.youtube.com/watch?v=8Z6i6v9y8i4",
    "Chair Pose": "https://www.youtube.com/watch?v=4pP5p4z5p5k",
    "Cobra Pose": "https://www.youtube.com/watch?v=JDcdhTuycOI",
    "Triangle Pose": "https://www.youtube.com/watch?v=upTKd4834b4",
    "Forward Bend": "https://www.youtube.com/watch?v=g7M6x04q2h8",
    "Side Stretch": "https://www.youtube.com/watch?v=7uKjB4i_p5s",
    "Plank Pose": "https://www.youtube.com/watch?v=pSHjTRCQxIw",
    "Cat Pose": "https://www.youtube.com/watch?v=GoLt0i4y1bk",
    "Cow Pose": "https://www.youtube.com/watch?v=GoLt0i4y1bk",
    "Low Lunge": "https://www.youtube.com/watch?v=0h0X8k7z8z8",
    "Boat Pose": "https://www.youtube.com/watch?v=4jW0J0h7k0o",
    "Pigeon Pose": "https://www.youtube.com/results?search_query=pigeon+pose+yoga",
    "Downward Dog": "https://www.youtube.com/watch?v=EC7RGJ9sRJk",
  };

  // --- 4. LOGIC: Launch Video ---
  Future<void> _launchVideo() async {
    final String url = _poseVideos[poseName] ?? "https://www.youtube.com/results?search_query=$poseName+yoga";
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $url';
      }
    } catch (e) {
      debugPrint("Error launching video: $e");
    }
  }

  // --- 5. LOGIC: Show Image Popup ---
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
              padding: const EdgeInsets.all(16),
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
                        child: const Icon(Icons.image, color: Color(0xFF7EA6FF)),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Button 2: Video Tutorial (YouTube) - NEW
                  Expanded(
                    child: SizedBox(
                      height: 55,
                      child: OutlinedButton(
                        onPressed: _launchVideo,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red, width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                        child: const Icon(Icons.play_circle_fill, color: Colors.red, size: 30),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 10),

                  // Button 3: Back to Menu
                  Expanded(
                    flex: 2, // Make this button wider
                    child: SizedBox(
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          // MEMORY FIX: Return to the specific slide index
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PoseSelectionScreen(initialIndex: poseIndex),
                            ),
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