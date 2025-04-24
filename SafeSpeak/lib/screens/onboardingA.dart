import 'package:flutter/material.dart';
import 'package:login/screens/onboardingB.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: WelcomeScreen(name: "Areeba", userID: "123"),
  ));
}

class WelcomeScreen extends StatelessWidget {
  final String name;
  final String userID;
  const WelcomeScreen({super.key, required this.name, required this.userID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack( // ✅ Stack use kiya button ko fixed karne ke liye
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                // mainAxisSize: MainAxisSize.min, // ✅ Content ko center mein rakha
                crossAxisAlignment: CrossAxisAlignment.center, 
                children: [
                  const SizedBox(height: 100),
                  Image.asset('assets/images/Welcome.png', width: 300, height: 300),
                  const SizedBox(height: 20),
                   Text(
                    "Welcome $name!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(37, 66, 43, 1),
                      shadows: [
                        Shadow(
                          blurRadius: 3.0,
                          color: Colors.grey,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Your voice is your power! SafeSpeak helps you stay protected by automatically calling your emergency contacts when you need help.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),

          // ✅ Next Button Fixed at Bottom Right
          Positioned(
            bottom: 50,
            right: 30,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WelcomeScreenB(userID: userID)),
                  );
              },
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(15),
                backgroundColor: const Color.fromRGBO(37, 66, 43, 1), // Button color
              ),
              child: const Icon(Icons.arrow_forward, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
