import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login/database_service.dart';
import 'package:login/screens/login.dart';
import 'package:login/screens/onboardingA.dart';
import 'package:login/screens/splash.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SignUpScreen(),
  ));
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final dbService = DatabaseService();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneNoController = TextEditingController();
  final TextEditingController emergencyModeController = TextEditingController();

  bool _isLoading = false;

  Future<void> signup() async {
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String phoneNo = phoneNoController.text.trim();
    bool emergencyMode = emergencyModeController.text.trim().toLowerCase() == 'true';

    if (name.isEmpty || email.isEmpty || password.length < 6) {
      showErrorDialog("Enter a valid name, email & password (6+ characters).");
      return;
    }

    if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(name)) {
      showErrorDialog("Name should only contain alphabets.");
      return;
    }

    // Capital letter check
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      showErrorDialog("Password must contain at least one uppercase letter.");
      return;
    }

    // Small letter check
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      showErrorDialog("Password must contain at least one lowercase letter.");
      return;
    }

    // Special character check
    if (!RegExp(r'[!@#\$&*~%^()\-_=+{}[\]|:;"<>,.?/\\]').hasMatch(password)) {
      showErrorDialog("Password must contain at least one special character.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await FirebaseAuth.instance.currentUser?.reload();
      String userID = userCredential.user!.uid;
      final user = USER(
        id: userID,
        name: name,
        email: email,
        password: password,
        phoneNo: phoneNo,
        emergencyMode: emergencyMode,
      );

      await dbService.createUser(user, userCredential.user!.uid);
      print("User creation function called.");

      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();
        await showInfoDialog("A verification email has been sent. Please verify before logging in.");
        checkEmailVerification(userID, name);
        return;
      } else {
        navigateToWelcome(userID,name);
      }
    } catch (e) {
      showErrorDialog(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> checkEmailVerification(String userID, String name) async {
    for (int i = 0; i < 50; i++) {
      await Future.delayed(const Duration(seconds: 3));
      await FirebaseAuth.instance.currentUser?.reload();
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null && user.emailVerified) {
        print("Email Verified!");
        navigateToWelcome(userID, name);
        return;
      }
    }
    showErrorDialog("Email verification failed. Please try again.");
  }

  void navigateToWelcome(String userID, String name) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => WelcomeScreen(name: name, userID: userID)),
    );
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))
        ],
      ),
    );
  }


  Future<void> resendVerificationEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      showInfoDialog("Verification email resent. Check your inbox.");
    }
  }
  
  Future<void> showInfoDialog(String message) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Attention"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

 @override
  Widget build(BuildContext context) {
    FirebaseAuth.instance.setLanguageCode("en");

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color.fromRGBO(37, 66, 43, 1)),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const SplashScreen()));
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Image.asset('assets/images/signup.png', width: 150, height: 150),
                  const SizedBox(height: 10),
                  const Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color.fromRGBO(37, 66, 43, 1)),
                  ),
                  const SizedBox(height: 1),
                  const Text(
                    'Create new Account!',
                    style: TextStyle(fontSize: 14, color: Color.fromRGBO(37, 66, 43, 0.8)),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: 370,
                    height: 50,
                    child: TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: "Name",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        prefixIcon: const Icon(Icons.person),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: 370,
                    height: 50,
                    child: TextField(
                      controller: phoneNoController,
                      decoration: InputDecoration(
                        labelText: "Phone No",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        prefixIcon: const Icon(Icons.phone),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  SizedBox(
                    width: 370,
                    height: 50,
                    child: TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        prefixIcon: const Icon(Icons.email),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 370,
                    height: 50,
                    child: TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        prefixIcon: const Icon(Icons.lock),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await signup();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(37, 66, 43, 1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 12),
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account ? "),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const LogInScreen()));
                        },
                        child: const Text(
                          "Log In",
                          style: TextStyle(color: Color.fromRGBO(37, 66, 43, 1), fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  TextButton(
                    onPressed: () async {
                      await resendVerificationEmail();
                    },
                    child: const Text("Resend Verification Email", style: TextStyle(color: Colors.green)),
                  ),
    
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}


class USER {
  final String id;
  final String name;
  final String email;
  final String password;
  final String phoneNo;
  final bool emergencyMode;

  USER({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.phoneNo,
    required this.emergencyMode,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "password": password,
      "phoneNo": phoneNo,
      "emergencyMode": emergencyMode,
    };
  }
}