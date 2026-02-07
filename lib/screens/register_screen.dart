import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'lib/assets/images/registerbackground.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          Container(color: Colors.black.withValues(alpha: 0.6)),

          Center(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'REGISTER',
                      style: TextStyle(
                        color: Colors.yellow,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),

                    _field(nameController, 'Full Name'),
                    const SizedBox(height: 16),
                    _field(emailController, 'Email'),
                    const SizedBox(height: 16),
                    _field(passwordController, 'Password', obscure: true),
                    const SizedBox(height: 16),
                    _field(confirmController, 'Confirm Password', obscure: true),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                              )
                            : const Text('Register'),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Already have an account? Login',
                        style: TextStyle(color: Colors.yellow),
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

  Future<void> _register() async {
    final messenger = ScaffoldMessenger.of(context);

    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmController.text.isEmpty) {
      messenger.showSnackBar(const SnackBar(content: Text('Fill all fields')));
      return;
    }

    if (passwordController.text != confirmController.text) {
      messenger.showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    setState(() => isLoading = true);

    try {
      final cred = await auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      // ČEKAMO da se podaci upišu u Firestore
      await firestore.collection('users').doc(cred.user!.uid).set({
        'uid': cred.user!.uid,
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'role': 'user', 
        'createdAt': Timestamp.now(),
      });

      if (mounted) {
        // Idemo dva koraka nazad da bismo bili sigurni da smo na Home
        // (Jer je putanja bila Home -> Login -> Register)
        Navigator.of(context).popUntil((route) => route.isFirst);
      }

    } on FirebaseAuthException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message ?? 'Registration failed')));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Widget _field(TextEditingController c, String label, {bool obscure = false}) {
    return TextField(
      controller: c,
      obscureText: obscure,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        floatingLabelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        filled: true,
        fillColor: Colors.grey[300],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.yellow, width: 2),
        ),
      ),
    );
  }
}