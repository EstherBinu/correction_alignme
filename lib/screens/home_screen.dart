import 'package:flutter/material.dart';
import 'timer_screen.dart';

// 1. A simple class to hold our Yoga Pose data
class YogaPose {
  final String name;
  final String sanskritName;
  final String imageName; // We will use this later for real images

  YogaPose({
    required this.name,
    required this.sanskritName,
    required this.imageName,
  });
}

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  // 2. The List of Yoga Poses (Mountain Pose added at the top)
  final List<YogaPose> poses = [
    YogaPose(
      name: "Mountain Pose",
      sanskritName: "Tadasana",
      imageName: "assets/mountain.png",
    ),
    YogaPose(
      name: "Tree Pose",
      sanskritName: "Vrikshasana",
      imageName: "assets/tree.png",
    ),
    YogaPose(
      name: "Warrior I",
      sanskritName: "Virabhadrasana I",
      imageName: "assets/warrior1.png",
    ),
    YogaPose(
      name: "Warrior II",
      sanskritName: "Virabhadrasana II",
      imageName: "assets/warrior2.png",
    ),
    YogaPose(
      name: "Cobra Pose",
      sanskritName: "Bhujangasana",
      imageName: "assets/cobra.png",
    ),
    YogaPose(
      name: "Downward Dog",
      sanskritName: "Adho Mukha Svanasana",
      imageName: "assets/dog.png",
    ),
    YogaPose(
      name: "Triangle Pose",
      sanskritName: "Trikonasana",
      imageName: "assets/triangle.png",
    ),
    YogaPose(
      name: "Chair Pose",
      sanskritName: "Utkatasana",
      imageName: "assets/chair.png",
    ),
    YogaPose(
      name: "Bridge Pose",
      sanskritName: "Setu Bandhasana",
      imageName: "assets/bridge.png",
    ),
    YogaPose(
      name: "Child's Pose",
      sanskritName: "Balasana",
      imageName: "assets/child.png",
    ),
    YogaPose(
      name: "Plank Pose",
      sanskritName: "Phalakasana",
      imageName: "assets/plank.png",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AlignMe Pose"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: poses.length,
        itemBuilder: (context, index) {
          final pose = poses[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.teal.shade100,
                child: Text((index + 1).toString()), // Number 1, 2, 3...
              ),
              title: Text(
                pose.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(pose.sanskritName),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // We will add the Timer navigation here in the next step
                print("Selected: ${pose.name}");

                Navigator.push(
                  context,
                  MaterialPageRoute(
                   builder: (context) => TimerScreen(poseName: pose.name),
                 ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
