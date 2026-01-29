import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Pozadinska slika
          SizedBox.expand(
            child: Image.asset(
              'lib/assets/images/registerbackground.jpeg',
              fit: BoxFit.cover,
            ),
          ),

          // Tamni pink overlay / blur
          Container(
            color: const Color.fromRGBO(200, 0, 100, 0.4), // tamno-roze providni sloj
          ),

          // Centrirani box za registraciju
          Center(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.pink[900]?.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Naslov
                    const Text(
                      'REGISTER',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Full Name polje
                    TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        labelStyle: TextStyle(color: Colors.grey[300]),
                        filled: true,
                        fillColor: Colors.pink[700],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 16),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Email polje
                    TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.grey[300]),
                        filled: true,
                        fillColor: Colors.pink[700],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 16),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password polje
                    TextField(
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Colors.grey[300]),
                        filled: true,
                        fillColor: Colors.pink[700],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 16),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Confirm Password polje
                    TextField(
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        labelStyle: TextStyle(color: Colors.grey[300]),
                        filled: true,
                        fillColor: Colors.pink[700],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 16),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Register dugme
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Za sada vodi na HomeScreen
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const HomeScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink[400],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Text('Register'),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Login link
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                        );
                      },
                      child: const Text(
                        'Already have an account? Login',
                        style: TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
