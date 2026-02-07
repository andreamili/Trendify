import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminContentScreen extends StatefulWidget {
  const AdminContentScreen({super.key});

  @override
  State<AdminContentScreen> createState() => _AdminContentScreenState();
}

class _AdminContentScreenState extends State<AdminContentScreen> {
  String searchQuery = '';
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Formatiranje datuma iz Firebase-a
  String formatDate(dynamic date) {
    if (date == null) return 'N/A';
    DateTime dt = (date is Timestamp) ? date.toDate() : date;
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${monthNames[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Pozadinska slika
          SizedBox.expand(
            child: Image.asset(
              'lib/assets/images/admin.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          
          // TAMNIJI I JAČI OVERLAY
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: Colors.black.withValues(alpha: 0.8),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildSearchBar(),
                Expanded(child: _buildImageStream()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.yellow.withValues(alpha: 0.5)),
      ),
      child: const Text(
        'CONTROL PANEL',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.yellow,
          fontSize: 26,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        onChanged: (value) => setState(() => searchQuery = value),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search by User or Caption...',
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: const Icon(Icons.search, color: Colors.yellow),
          filled: true,
          fillColor: Colors.grey[900],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), 
            borderSide: BorderSide.none
          ),
        ),
      ),
    );
  }

  Widget _buildImageStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('images').orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.yellow));
        
        var docs = snapshot.data!.docs.where((doc) {
          var data = doc.data() as Map<String, dynamic>;
          String uid = data['userId'] ?? '';
          String cap = data['caption'] ?? '';
          return searchQuery.isEmpty || 
                 uid.toLowerCase().contains(searchQuery.toLowerCase()) ||
                 cap.toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var doc = docs[index];
            var data = doc.data() as Map<String, dynamic>;
            return _buildImageCard(doc.id, data);
          },
        );
      },
    );
  }

  Widget _buildImageCard(String docId, Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  data['imageUrl'] ?? '',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => Container(
                    width: 100, height: 100, color: Colors.grey, child: const Icon(Icons.broken_image),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // OVO JE DEO KOJI VUČE FULL NAME IZ KOLEKCIJE USERS
                    FutureBuilder<DocumentSnapshot>(
                      future: _db.collection('users').doc(data['userId']).get(),
                      builder: (context, userSnapshot) {
                        String displayName = "Unknown User";
                        if (userSnapshot.hasData && userSnapshot.data!.exists) {
                          var userData = userSnapshot.data!.data() as Map<String, dynamic>;
                          displayName = userData['fullName'] ?? "No Name";
                        } else if (data['userId'] != null) {
                          // Ako nema imena u bazi, prikaži skraćeni ID kao backup
                          displayName = "ID: ${data['userId'].toString().substring(0, 8)}...";
                        }

                        return Text(
                          displayName,
                          style: const TextStyle(
                            color: Colors.yellow, 
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    Text(formatDate(data['createdAt']), 
                        style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 8),
                    Text(data['caption'] ?? '', 
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white10, height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _editPost(docId, data['caption'] ?? ''),
                icon: const Icon(Icons.edit, color: Colors.blue),
                label: const Text("Edit", style: TextStyle(color: Colors.blue)),
              ),
              const SizedBox(width: 10),
              TextButton.icon(
                onPressed: () => _deletePost(docId),
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                label: const Text("Delete", style: TextStyle(color: Colors.red)),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _deletePost(String docId) async {
    final messenger = ScaffoldMessenger.of(context);
    bool confirm = await _showConfirmDialog("Delete", "Are you sure you want to remove this post?");
    
    if (confirm) {
      await _db.collection('images').doc(docId).delete();
      messenger.showSnackBar(
        const SnackBar(content: Text('Post deleted successfully')),
      );
    }
  }

  void _editPost(String docId, String currentCaption) {
    TextEditingController editController = TextEditingController(text: currentCaption);
    
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text("Edit Caption", style: TextStyle(color: Colors.yellow)),
          content: TextField(
            controller: editController,
            style: const TextStyle(color: Colors.white),
            maxLines: 4,
            decoration: const InputDecoration(
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.yellow)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext), 
              child: const Text("Cancel")
            ),
            ElevatedButton(
              onPressed: () async {
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(dialogContext);

                await _db.collection('images').doc(docId).update({'caption': editController.text});
                
                navigator.pop(); 
                scaffoldMessenger.showSnackBar(
                  const SnackBar(content: Text('Post updated successfully')),
                );
              },
              child: const Text("Save"),
            ),
          ],
        );
      }
    );
  }

  Future<bool> _showConfirmDialog(String title, String content) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(title, style: const TextStyle(color: Colors.red)),
        content: Text(content, style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("No")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Yes")),
        ],
      ),
    ) ?? false;
  }
}