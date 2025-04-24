import 'package:flutter/material.dart';
import 'package:login/screens/login.dart';
import 'package:login/screens/signup.dart';
import 'package:login/screens/splash.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Back Button
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color.fromRGBO(37, 66, 43, 1)),
                  onPressed: () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SplashScreen()));
                    // Add back navigation here
                  },
                ),),
              ),
              const SizedBox(height: 20),
              // Illustration
              Container(
                width: 150,
                height: 150,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/illustration.png'), // Replace with your illustration path
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Tagline
              const Text(
                'Your Voice, Your Shield',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(37, 66, 43, 1),
                ),
              ),
              const SizedBox(height: 10),
              // Description
              const Text(
                'Stay protected with just a word. Empowering you to take control and stay safe, anytime, anywhere.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color.fromRGBO(37, 66, 43, 0.8),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 30),
              // Login Button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LogInScreen()),
            );
                  // Add navigation to the login screen here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(37, 66, 43, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 12),
                ),
                child: const Text(
                  'Log In',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              // Sign Up Button
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpScreen()),
            );
                  // Add navigation to the sign-up screen here
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color.fromRGBO(37, 66, 43, 1)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 92, vertical: 12),
                ),
                child: const Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(37, 66, 43, 1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: OnboardingScreen(),
  ));
}
