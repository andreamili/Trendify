import 'package:flutter/material.dart';
import 'welcome_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Placeholder lista slika
  final List<String> images = const []; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [

          // Header
          Container(
            width: double.infinity,
            color: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: const Center(
              child: Text(
                'TRENDIFY', 
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic, 
                  letterSpacing: 2,
                ),
              ),
            ),
          ),

          // body
          Expanded(
            child: Stack(
              children: [
                // pozadinska slika
                SizedBox.expand(
                  child: Image.asset(
                    'lib/assets/images/homebackground.jpeg',
                    fit: BoxFit.cover,
                  ),
                ),

                //blur slike
                Container(
                  color: Colors.black.withOpacity(0.4), 
                ),

                //Obavestenje ako nema dodatih slika
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: images.isEmpty
                      ? Center(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            color: Colors.black,
                            child: const Text(
                              'No images added yet. Please check back later!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      : GridView.builder(
                          itemCount: images.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1,
                          ),
                          itemBuilder: (context, index) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[800], 
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  images[index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                ),

                // Back dugme 
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const WelcomeScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('Back'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
