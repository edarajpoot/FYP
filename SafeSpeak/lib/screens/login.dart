import 'package:flutter/material.dart';
import 'package:login/database_service.dart';
import 'package:login/model/contactModel.dart';
import 'package:login/model/keywordModel.dart';
import 'package:login/model/usermodel.dart';
import 'package:login/navigation.dart';
import 'package:login/screens/backgroungServices.dart';
import 'package:login/screens/signup.dart';
import 'package:login/screens/splash.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LogInScreen(),
  ));
}

class LogInScreen extends StatefulWidget {
  const LogInScreen({Key? key}) : super(key: key);

  @override
  _LogInScreenState createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  bool _rememberMe = false;
  bool _obscureText = true;
  bool _isLoading = false; // Track loading state
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  Future<void> signIn() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text,
        password: password.text,
      );

      User? user = FirebaseAuth.instance.currentUser;

      if (user != null && !user.emailVerified) {
        await FirebaseAuth.instance.signOut();
        showErrorDialog(context, "Please verify your email before logging in.");
        return;
      }

      String? userId = user?.uid;
      if (userId == null) {
        showErrorDialog(context, "User not found. Please try again.");
        return;
      }

      DatabaseService dbService = DatabaseService();
      UserModel? userData = await dbService.getUserData(userId);
      KeywordModel? keywordData = await dbService.getKeywordData(userId);
      List<ContactModel> contacts = [];

      if (keywordData != null) {
        String? keywordId = keywordData.keywordID;
        if (keywordId != null) {
          contacts = await dbService.getContactList(userId, keywordId);
        }
      }

      if (userData != null) {
  if (mounted) {
    await initializeService(contacts, keywordData!); // ✅ Start service before navigating
    Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => MyNavigationBar(
      user: userData,
      keywordData: keywordData,
      contacts: contacts,
    ),
  ),
);

  }
} else {
        showErrorDialog(context, "User data not found.");
      }
    } catch (e) {
      if (mounted) {
        showErrorDialog(context, "Login failed: ${e.toString()}");
      }
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator after the process
      });
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
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color.fromRGBO(37, 66, 43, 1)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SplashScreen()),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
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
              const Text(
                'Welcome Back',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(37, 66, 43, 1),
                ),
              ),
              const SizedBox(height: 1),
              const Text(
                'Login to your Account!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color.fromRGBO(37, 66, 43, 0.8),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
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
              SizedBox(
                width: 370,
                height: 50,
                child: TextField(
                  controller: password,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    labelText: "Password",
                    hintText: "Enter Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                      child: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (bool? value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                      ),
                      const Text("Remember me", style: TextStyle(color: Colors.black)),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      // Handle Forget Password Tap
                    },
                    child: const Text(
                      "Forget Password?",
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator() // Show progress indicator while logging in
                  : ElevatedButton(
                      onPressed: () async {
                        await signIn();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(37, 66, 43, 1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 12),
                      ),
                      child: const Text(
                        'Log In',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
              const SizedBox(height: 3),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignUpScreen()),
                      );
                    },
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(color: Color.fromRGBO(37, 66, 43, 1), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
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
