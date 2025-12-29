import 'package:flutter/material.dart';
import 'package:camera/camera.dart'; // Import Camera
import 'screens/pose_selection_screen.dart'; // CONNECTED: Your new beautiful UI

// 1. Global variable to store the list of cameras
List<CameraDescription> cameras = [];

Future<void> main() async {
  // 2. Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // 3. Find available cameras (Front & Back)
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error: $e.code\nError Message: $e.message');
  }

  runApp(const AlignMeApp());
}

class AlignMeApp extends StatelessWidget {
  const AlignMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PosePerfect', // Updated to match your new UI Name
      theme: ThemeData(
        primarySwatch: Colors.teal, // You can change this to purple to match your gradient later if you want
        useMaterial3: true,
      ),
      // CONNECTED: Starts with your new Slider UI
      home: const PoseSelectionScreen(), 
      debugShowCheckedModeBanner: false,
    );
  }
}