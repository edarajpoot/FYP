import 'package:flutter/material.dart';
import 'package:login/screens/onboarding.dart';

class SplashScreen extends StatelessWidget {

//   Future<void> initializeService() async {
//   final service = FlutterBackgroundService();

//   // Configure background service for both Android and iOS
//   await service.configure(
//     androidConfiguration: AndroidConfiguration(
//       onStart: onStart, // onStart now returns FutureOr<bool>
//       isForegroundMode: true, // Run as a foreground service (required for long-running tasks)
//     ),
//     iosConfiguration: IosConfiguration(
//       onBackground: onStart, // onStart now returns FutureOr<bool> for iOS as well
//       autoStart: true, // Automatically start the service on iOS
//       isForegroundMode: true, // Run in foreground on iOS as well
//     ),
//   );

//   service.start(); // Start the background service
// }


//   FutureOr<bool> onStart(ServiceInstance service) async {
//   print("Background service started!");

//   // Here you can perform any asynchronous tasks (like checking permissions, etc.)
//   // The function should return `true` if the service starts successfully, or `false` if it fails.

//   // Example: Perform some task and return true or false based on the result
//   try {
//     service.sendData({"message": "Service is running"});
//     return true;  // Indicating that the service started successfully
//   } catch (e) {
//     print("Error starting service: $e");
//     return false;  // Indicating that there was an issue starting the service
//   }
// }

  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Image
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20), // 👈 Adjust this value to change roundness
                image: const DecorationImage(
                  image: AssetImage('assets/images/logo.jpg'),
                  fit: BoxFit.cover,
                  ),
                  ),
                ),

            const SizedBox(height: 20), // Spacing between logo and app name
            // App Name
            const Text(
              'SafeSpeak',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(37, 66, 43, 1),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 10), // Spacing between app name and tagline
            // Tagline
            Text(
              'Effortless Voice Control for tasks and emergency help.\nStay secure and Connected.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30), // Spacing between tagline and button
            // Get Started Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OnboardingScreen()),
                  );  // Add navigation to the next screen here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(37, 66, 43, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 12),
              ),
              child: const Text(
                'Get Started',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SplashScreen(),
  ));
}
