import 'package:flutter/material.dart';
//import 'package:login/firestore_dummy_data.dart';
import 'package:login/screens/splash.dart';
import 'package:firebase_auth/firebase_auth.dart';


void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ForgotPasswordScreen(), // Corrected home route
  ));
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key); // Added Key parameter

  @override
  // ignore: library_private_types_in_public_api
  _LogInScreenState createState() => _LogInScreenState();
}

class _LogInScreenState extends State<ForgotPasswordScreen> {
   TextEditingController email = TextEditingController();

   @override
   void dispose(){
    email.dispose();
    super.dispose();
   }

   Future passwordReset() async {
    
    try{
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.text.trim());
      showDialog(
        context: context, 
        builder: (context) {
          return AlertDialog(
            content: Text("Password reset link sent! check your email"),
          );
        }
        );
    } on FirebaseAuthException catch (e) {
      print(e);
      showDialog(
        context: context, 
        builder: (context) {
          return AlertDialog(
            content: Text("Invalid email!"),
          );
        }
        );
    }

   }



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
                  padding: const EdgeInsets.only(top: 15.0),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Color.fromRGBO(37, 66, 43, 1)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SplashScreen()),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Illustration
              Container(
                width: 150,
                height: 150,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/login.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              
              // Description
              const Text(
                'Enter your email to reset password',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color.fromRGBO(37, 66, 43, 0.8),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              // Email TextField
              SizedBox(
                width: 370,
                height: 50,
                child: TextField(
                  controller: email,
                  decoration: InputDecoration(
                    labelText: "Email",
                    hintText: "Enter Email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    prefixIcon: const Icon(Icons.email),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed:() async {
                       passwordReset();
                    },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(37, 66, 43, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 80, vertical: 12),
                ),
                child: const Text(
                  'Reset your Password',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 3),              
            ],
          ),
        ),
      ),
    );
  }

  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
