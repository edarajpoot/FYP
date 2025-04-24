import 'package:flutter/material.dart';
import 'package:login/screens/onboardingD.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: WelcomeScreenC(userID: "123"),
  ));
}

class WelcomeScreenC extends StatelessWidget {
final String userID;
const WelcomeScreenC({super.key, required this.userID});

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
                  Image.asset('assets/images/keyword.png', width: 250, height: 250),
                  const SizedBox(height: 25),
                  const Text(
                    "Set Your Emergency Keywords",
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
                  const SizedBox(height: 25),
                  const Text(
                    'Choose unique words or phrases that only you know. When spoken, SafeSpeak will automatically alert your contacts.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),

                  const SizedBox(height: 10),
                  const Text(
                    "Example Keywords: Help!, Danger!, I'm in trouble!",
                    // textAlign: TextAlign.center,
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
                  MaterialPageRoute(builder: (context) =>  WelcomeScreenD(userID: userID)),
                  );              },
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
