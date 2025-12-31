import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'timer_screen.dart'; 

class PoseSelectionScreen extends StatefulWidget {
  final int initialIndex; // NEW: Memory for which slide to start on

  const PoseSelectionScreen({
    super.key, 
    this.initialIndex = 1 // Defaults to 1 (Tree Pose) if not specified
  });

  @override
  State<PoseSelectionScreen> createState() => _PoseSelectionScreenState();
}

class _PoseSelectionScreenState extends State<PoseSelectionScreen> {
  int _selectedPractice = 15; 
  late PageController _controller; // Late init to use widget.initialIndex
  late int selectedIndex;

  final List<Map<String, dynamic>> practiceOptions = [
    {'time': 10, 'label': 'Light • 10 min/day'},
    {'time': 15, 'label': 'Standard • 15 min/day'},
    {'time': 20, 'label': 'Intense • 20 min/day'},
    {'time': 30, 'label': 'Extreme • 30 min/day'},
  ];

  // --- UPDATED LIST: 15 POSES ---
  final List<Map<String, dynamic>> poses = [
    {"name": "Mountain Pose", "image": "assets/cat-cow.jpg", "desc": "Improves posture."},
    {"name": "Tree Pose", "image": "assets/pigeon-pose.jpg", "desc": "Enhances stability."},
    {"name": "Warrior Pose", "image": "assets/warrior2.jpg", "desc": "Strengthens legs."},
    {"name": "Bridge Pose", "image": "assets/bridge-pose.jpg", "desc": "Opens chest."},
    {"name": "Chair Pose", "image": "assets/chair-pose.jpg", "desc": "Strengthens thighs."},
    {"name": "Cobra Pose", "image": "assets/cobra.jpg", "desc": "Strengthens back."},
    {"name": "Triangle Pose", "image": "assets/triangle.jpg", "desc": "Full body stretch."},
    {"name": "Forward Bend", "image": "assets/forward-bend.jpg", "desc": "Calms the mind."},
    {"name": "Side Stretch", "image": "assets/side-stretch.jpg", "desc": "Lengthens sides."},
    // --- NEW POSES ---
    {"name": "Plank Pose", "image": "assets/plank.jpg", "desc": "Core strength."},
    {"name": "Cat Pose", "image": "assets/cat.jpg", "desc": "Spine flexibility."},
    {"name": "Cow Pose", "image": "assets/cow.jpg", "desc": "Opens chest."},
    {"name": "Low Lunge", "image": "assets/low-lunge.jpg", "desc": "Hip flexor stretch."},
    {"name": "Boat Pose", "image": "assets/boat.jpg", "desc": "Abdominal balance."},
    {"name": "Pigeon Pose", "image": "assets/pigeon.jpg", "desc": "Deep hip opener."},
    {"name": "Downward Dog", "image": "assets/downward-dog.jpg", "desc": "Full body stretch."},
  ];

  @override
  void initState() {
    super.initState();
    // MEMORY FIX: Initialize with the passed index
    selectedIndex = widget.initialIndex;
    _controller = PageController(viewportFraction: 0.72, initialPage: selectedIndex);
  }

  void showConfirmPopup() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        final pose = poses[selectedIndex];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              const Text("Are you sure?", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text("Start correction for:", style: TextStyle(fontSize: 15, color: Colors.grey[600])),
              const SizedBox(height: 10),
              Text(pose["name"], style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  pose["image"],
                  height: 350,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 350,
                      color: Colors.grey[200],
                      child: const Center(child: Icon(Icons.self_improvement, size: 80, color: Colors.grey)),
                    );
                  },
                ),
              ),
              const SizedBox(height: 25),
              InkWell(
                onTap: () {
                  Navigator.pop(context); 
                  // Pass the poseName AND poseIndex to the next screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TimerScreen(
                        poseName: pose["name"],
                        poseIndex: selectedIndex,
                        // NOTE: If you haven't updated TimerScreen to accept poseIndex yet,
                        // you might need to update that file too. 
                        // For now, this keeps your existing flow working.
                        // poseIndex: selectedIndex, 
                      )
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7EA6FF), Color(0xFFCB8BFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(child: Text("Start Now", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white))),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPracticeSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: Text("How often do you want to practice?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1D1617)))),
          const SizedBox(height: 20),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: practiceOptions.length,
              itemBuilder: (context, index) {
                final item = practiceOptions[index];
                bool isSelected = item['time'] == _selectedPractice;
                return GestureDetector(
                  onTap: () => setState(() => _selectedPractice = item['time']),
                  child: Container(
                    width: 150,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFC58BF2).withOpacity(0.1) : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: isSelected ? const Color(0xFFC58BF2) : const Color(0xFFF7F8F8)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("${item['time']} min", style: TextStyle(fontSize: isSelected ? 26 : 22, fontWeight: FontWeight.bold, color: isSelected ? const Color(0xFF92A3FD) : const Color(0xFF1D1617))),
                        const SizedBox(height: 5),
                        Text(item['label'], textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: isSelected ? const Color(0xFFC58BF2) : const Color(0xFF7B6F72))),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () { if(Navigator.canPop(context)) Navigator.pop(context); },
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
                    ),
                    const Spacer(),
                    const Text("PosePerfect", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    const SizedBox(width: 45),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Center(child: const Text("Choose Your Yoga Pose", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)).animate().fadeIn().slideY(begin: 0.3, end: 0)),
              const SizedBox(height: 30),
              SizedBox(
                height: 300,
                child: PageView.builder(
                  controller: _controller,
                  itemCount: poses.length,
                  onPageChanged: (index) => setState(() => selectedIndex = index),
                  itemBuilder: (context, i) {
                    final pose = poses[i];
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: i == selectedIndex ? 0 : 25),
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(26),
                                gradient: const LinearGradient(colors: [Color(0xFFA8C5FF), Color(0xFFC4A1FF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                              ),
                              child: Center(child: Text(pose["name"], textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white))),
                            ),
                          ),
                          const SizedBox(height: 18),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOut,
                            width: i == selectedIndex ? 140 : 90,
                            height: i == selectedIndex ? 26 : 18,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [Colors.black.withOpacity(0.20), Colors.black.withOpacity(0.05)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                              borderRadius: BorderRadius.circular(50),
                            ),
                          )
                        ],
                      ),
                    ).animate().slideX(begin: 1.2, end: 0, duration: (600 + i * 80).ms, curve: Curves.easeOutCubic).fadeIn(duration: 800.ms);
                  },
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    _buildPracticeSection(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: InkWell(
                  onTap: showConfirmPopup,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      gradient: const LinearGradient(colors: [Color(0xFF7EA6FF), Color(0xFFCB8BFF)]),
                      boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.6), blurRadius: 15, offset: const Offset(0, 8))],
                    ),
                    child: const Center(child: Text("Start Correction", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 17))),
                  ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scale(duration: 1200.ms, curve: Curves.easeInOut, begin: const Offset(1, 1), end: const Offset(0.94, 0.94)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}