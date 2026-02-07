import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'my_profile_screen.dart';
import 'admin_panel.dart';
import 'add_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';

import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? user;
  bool isAdmin = false;
  bool isLoading = true;
  
  // Stream subscription nam omogućava da pratimo korisnika bez greške
  StreamSubscription<User?>? authSubscription;

  @override
  void initState() {
    super.initState();
    _initUser();
  }

  @override
  void dispose() {
    authSubscription?.cancel(); // Čistimo resurse
    super.dispose();
  }

  Future<void> _initUser() async {
    authSubscription = FirebaseAuth.instance.authStateChanges().listen((User? newUser) async {
      if (newUser == null) {
        if (mounted) {
          setState(() {
            user = null;
            isAdmin = false;
            isLoading = false;
          });
        }
      } else {
        // Kada se uloguje, ODMAH vučemo rolu iz Firestore-a
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(newUser.uid)
            .get();

        if (mounted) {
          setState(() {
            user = newUser;
            isAdmin = doc.exists && doc.data()?['role'] == 'admin';
            isLoading = false;
          });
        }
      }
    });
  }

  Future<void> _deletePost(String postId) async {
    await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
  }

  @override
  Widget build(BuildContext context) {
    // LOADING EKRAN - Ovo sprečava da korisnik vidi "pogrešna" dugmad dok se baza ne učita
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.yellow)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: user != null
          ? FloatingActionButton(
              backgroundColor: Colors.yellow[700],
              foregroundColor: Colors.black,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddScreen()),
              ),
              child: const Icon(Icons.add, size: 30),
            )
          : null,
      body: Column(
        children: [
          // HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50, bottom: 18),
            color: Colors.black,
            child: const Center(
              child: Text(
                'TRENDIFY',
                style: TextStyle(
                  color: Colors.yellow,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),

          // BUTTONS - Sada se garantovano osvežavaju
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: user == null
                ? Row(
                    children: [
                      _topButton('Login', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())), true),
                      const SizedBox(width: 12),
                      _topButton('Register', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())), false),
                    ],
                  )
                : Row(
                    children: [
                      _topButton('My Profile', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyProfileScreen())), true),
                      if (isAdmin) ...[
                        const SizedBox(width: 12),
                        _topButton('Admin Panel', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminContentScreen())), false),
                      ],
                    ],
                  ),
          ),

          // FEED
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('posts').orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.yellow));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _emptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var post = snapshot.data!.docs[index];
                    return _postItem(post);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Pomoćne funkcije za vidgete (ostaju iste kao pre...)
  Widget _postItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data['imageUrl'] != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                data['imageUrl'], 
                fit: BoxFit.cover, 
                width: double.infinity, 
                height: 200,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200, color: Colors.grey[800], child: const Icon(Icons.broken_image, color: Colors.yellow)
                ),
              ),
            ),
          ListTile(
            title: Text(data['title'] ?? 'No Title', style: const TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold)),
            subtitle: Text(data['description'] ?? '', style: const TextStyle(color: Colors.white70)),
            trailing: (isAdmin || (user != null && user!.uid == data['userId']))
                ? IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deletePost(doc.id),
                  )
                : null,
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(12)),
        child: const Text('No posts yet.\nStay tuned!', textAlign: TextAlign.center, style: TextStyle(color: Colors.yellow, fontSize: 18)),
      ),
    );
  }

  Widget _topButton(String text, VoidCallback onPressed, bool isPrimary) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? Colors.yellow[700] : Colors.black,
          foregroundColor: isPrimary ? Colors.black : Colors.yellow,
          side: isPrimary ? null : BorderSide(color: Colors.yellow[700]!),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(text),
      ),
    );
  }
}