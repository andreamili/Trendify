import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
  String dailyQuote = "Loading inspiration...";
  StreamSubscription<User?>? authSubscription;

  @override
  void initState() {
    super.initState();
    _initUser();
    _fetchQuote();
  }

  @override
  void dispose() {
    authSubscription?.cancel();
    super.dispose();
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    DateTime dt = (date is Timestamp) ? date.toDate() : date;
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dt.day} ${monthNames[dt.month - 1]} ${dt.year}';
  }

  Future<void> _fetchQuote() async {
    try {
      final response = await http.get(
        Uri.parse('https://zenquotes.io/api/random'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            dailyQuote = data[0]['q'];
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          dailyQuote =
              "Style is a way to say who you are without having to speak.";
        });
      }
    }
  }

  Future<void> _initUser() async {
    authSubscription = FirebaseAuth.instance.authStateChanges().listen((
      User? newUser,
    ) async {
      if (newUser == null) {
        if (mounted) {
          setState(() {
            user = null;
            isAdmin = false;
            isLoading = false;
          });
        }
      } else {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(newUser.uid)
            .get();

        if (mounted) {
          setState(() {
            user = newUser;
            isAdmin = doc.exists && (doc.data()?['role'] == 'admin');
            isLoading = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50, bottom: 10),
            color: Colors.black,
            child: Column(
              children: [
                const Text(
                  'TRENDIFY',
                  style: TextStyle(
                    color: Colors.yellow,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 2,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 8,
                  ),
                  child: Text(
                    '"$dailyQuote"',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: user == null
                ? Row(
                    children: [
                      _topButton(
                        'Login',
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        ),
                        true,
                      ),
                      const SizedBox(width: 12),
                      _topButton(
                        'Register',
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        ),
                        false,
                      ),
                    ],
                  )
                : Row(
                    children: [
                      _topButton(
                        'My Profile',
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MyProfileScreen(),
                          ),
                        ),
                        true,
                      ),
                      if (isAdmin) ...[
                        const SizedBox(width: 12),
                        _topButton(
                          'Admin Panel',
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminContentScreen(),
                            ),
                          ),
                          false,
                        ),
                      ],
                    ],
                  ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('images')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.yellow),
                  );
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

  Widget _postItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data['imageUrl'] != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(19),
              ),
              child: AspectRatio(
                aspectRatio: 0.8,
                child: Image.network(
                  data['imageUrl'],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[850],
                    child: const Icon(Icons.broken_image, color: Colors.yellow),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.yellow),
                    );
                  },
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(data['userId'])
                          .get(),
                      builder: (context, userSnapshot) {
                        String displayName =
                            data['userName'] ?? 'Trendify User';
                        if (userSnapshot.hasData && userSnapshot.data!.exists) {
                          var userData =
                              userSnapshot.data!.data() as Map<String, dynamic>;
                          displayName = userData['fullName'] ?? displayName;
                        }
                        return Text(
                          displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        );
                      },
                    ),
                    Text(
                      _formatDate(data['createdAt']),
                      style: TextStyle(
                        color: Colors.yellow[700],
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  data['caption'] ?? '',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_search, size: 64, color: Colors.grey[800]),
          const SizedBox(height: 16),
          const Text(
            'No trends yet.\nBe the first to post!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
