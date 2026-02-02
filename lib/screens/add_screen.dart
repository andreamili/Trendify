import 'package:flutter/material.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final TextEditingController descriptionController = TextEditingController();

String? selectedImagePath;

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
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
            color: const Color.fromRGBO(0, 0, 0, 0.6),
          ),

          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  
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

                  const SizedBox(height: 30),

                  // Preview slike i klikom se bira slika
                   GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedImagePath = 'lib/assets/images/sample_image.jpeg';
                      });
                    },
                    child: const Center(
                      child: Icon(
                        Icons.image,
                        size: 80,
                        color: Colors.yellow,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // opis slike
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Enter image description...',
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[300],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Add dugme
                  ElevatedButton(
                    onPressed: () {
                      if (selectedImagePath == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select an image!'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      // opis može da ostane prazan, ali ovde možemo eventualno dohvatiti
                      String description = descriptionController.text.trim();
                     // Ovde koristimo description tako da warning nestane
                      Navigator.pop(context, description); // vraca na home
                    },
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
                    child: const Text('ADD IMAGE'),
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
