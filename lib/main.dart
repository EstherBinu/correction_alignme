import 'package:flutter/material.dart';
import 'package:camera/camera.dart'; // Import Camera
import 'screens/home_screen.dart';

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
      title: 'AlignMe Pose',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}