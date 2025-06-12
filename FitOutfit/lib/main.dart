import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'pages/splash_screen_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBlsF9FDh0TDDKxw7mZX3301m2lqwn5FRc",
        authDomain: "fitoutfit-f47ae.firebaseapp.com",
        projectId: "fitoutfit-f47ae",
        storageBucket: "fitoutfit-f47ae.appspot.com",
        messagingSenderId: "1020357822298",
        appId: "1:1020357822298:web:b51c742da1c68809cc1563",
        measurementId: "G-VKTVP5F6L7",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitOutfit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF4A90E2), // Blue
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A90E2),
          secondary: const Color(0xFFF5A623), // Yellow
          tertiary: const Color(0xFFD0021B), // Red
        ),
        useMaterial3: true,
      ),
      home: const SplashScreenPage(),
    );
  }
}
