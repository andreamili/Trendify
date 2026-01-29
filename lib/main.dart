import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart'; 

void main() {
  runApp(const TrendifyApp());
}

class TrendifyApp extends StatelessWidget {
  const TrendifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trendify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color.fromARGB(255, 29, 29, 29),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(), 
    );
  }
}
