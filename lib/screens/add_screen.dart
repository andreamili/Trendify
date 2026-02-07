import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();
  bool isLoading = false;
  String currentPreviewUrl = "";

  @override
  void initState() {
    super.initState();
    imageUrlController.addListener(() {
      setState(() {
        currentPreviewUrl = imageUrlController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    descriptionController.dispose();
    imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _uploadImage() async {
    final caption = descriptionController.text.trim();
    final imageUrl = imageUrlController.text.trim();

    if (caption.isEmpty || imageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      final userRole = userDoc.data()?['role'] ?? 'user';
      final userName = userDoc.data()?['name'] ?? 'User';

      await FirebaseFirestore.instance.collection('images').add({
        'caption': caption,
        'imageUrl': imageUrl,
        'userId': user.uid,
        'userName': userName,
        'role': userRole,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pop(context);

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'lib/assets/images/add.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            color: const Color(0xFF0A0A0A).withValues(alpha: 0.9),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    'ADD NEW IMAGE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.yellow,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 25),
                  
                  // BOX ZA SLIKU - ISTI KAO NA HOME
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: AspectRatio(
                        aspectRatio: 0.8, // Ključno za doslednost sa Home ekranom
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: currentPreviewUrl.isEmpty
                              ? const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.image_search, color: Colors.white24, size: 50),
                                    SizedBox(height: 8),
                                    Text('Preview', 
                                      style: TextStyle(color: Colors.white24, fontSize: 12)),
                                  ],
                                )
                              : Image.network(
                                  currentPreviewUrl,
                                  fit: BoxFit.cover, // Automatski popunjava boks
                                  errorBuilder: (context, error, stackTrace) => const Center(
                                    child: Icon(Icons.broken_image, color: Colors.redAccent, size: 40),
                                  ),
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(child: CircularProgressIndicator(color: Colors.yellow));
                                  },
                                ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 25),
                  TextField(
                    controller: imageUrlController,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Paste image URL here...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[300],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                      prefixIcon: const Icon(Icons.link, color: Colors.black54),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: descriptionController,
                    maxLines: 2,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Enter image description...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[300],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: isLoading ? null : _uploadImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow[700],
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('ADD IMAGE'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}