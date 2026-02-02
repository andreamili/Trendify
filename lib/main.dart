import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/welcome_screen.dart';
import 'firebase_options.dart'; // ovo generisano od FlutterFire CLI

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // debug log umesto print
  debugPrint("✅ Firebase initialized successfully!");

  runApp(const TrendifyApp());
}

class TrendifyApp extends StatelessWidget {
  const TrendifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trendify',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.yellow[700],
      ),
      home: const WelcomeScreen(),
    );
  }
}
