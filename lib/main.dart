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
      debugShowCheckedModeBanner: false, 
      title: 'MyProfile Test',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.yellow[700],
      ),
      home: const WelcomeScreen(), 
    );
  }
}
