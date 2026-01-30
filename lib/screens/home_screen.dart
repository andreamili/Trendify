import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Placeholder lista slika (kasnije ide backend)
  final List<String> images = const [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
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

          // BODY
          Expanded(
            child: Stack(
              children: [
                // Pozadinska slika
                SizedBox.expand(
                  child: Image.asset(
                    'lib/assets/images/homebackground.png',
                    fit: BoxFit.cover,
                  ),
                ),

                // Tamno-sivi providni sloj
                Container(
                  color: const Color.fromARGB(180, 30, 30, 30),
                ),

                // Sadržaj
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: images.isEmpty
                      ? Center(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(220, 40, 40, 40),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'No images added yet.\nStay tuned!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.yellow,
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
                                color: const Color.fromARGB(255, 45, 45, 45),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.yellow,
                                  width: 1.5,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  images[index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
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
