import 'package:flutter/material.dart';
import 'package:login/screens/keyword.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: WelcomeScreenD(userID: "123"),
  ));
}

class WelcomeScreenD extends StatelessWidget {
  final String userID;
  const WelcomeScreenD({super.key, required this.userID});

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
                  Image.asset('assets/images/permission.png', width: 250, height: 250),
                  const SizedBox(height: 25),
                  const Text(
                    "Permissions Require for Your Safety",
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
                    'To function properly, SafeSpeak needs the following permissions:',
                    // textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),

                  const SizedBox(height: 5),
                  const Text(
                    '\n✅  Microphone (to detect keywords) \n✅  Location (to share your live location) \n✅  Contacts (to call your emergency contacts)',
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
                  MaterialPageRoute(builder: (context) =>  SetKeywordScreen(userID: userID)),
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
