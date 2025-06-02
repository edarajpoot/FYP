import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _changePassword() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No user logged in')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Re-authenticate user with current password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPasswordController.text.trim(),
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPasswordController.text.trim());
      print("Password updated in Firebase ✅");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password updated successfully')),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String message = 'Error: ${e.message}';
      if (e.code == 'wrong-password') {
        message = 'Current password is incorrect.';
      } else if (e.code == 'weak-password') {
        message = 'The new password is too weak.';
      } else if (e.code == 'requires-recent-login') {
        message = 'Please log out and log in again before changing password.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Padding(
          padding: const EdgeInsets.only(left: 25.0),
          child: Text("Change Password",
          style: TextStyle(
            color: Color.fromRGBO(37, 66, 43, 1),
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),),
        )
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // TextFormField(
              //   controller: currentPasswordController,
              //   obscureText: true,
              //   decoration: InputDecoration(labelText: "Current Password"),
              //   validator: (val) =>
              //       val == null || val.isEmpty ? 'Enter current password' : null,
              // ),

              const SizedBox(height: 20),
              SizedBox(
                width: 370,
                height: 50,
                child: TextFormField(
                  controller: currentPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Current Password",
                    hintText: "Enter Current Password",
                    hintStyle: TextStyle(color: Color.fromRGBO(37, 66, 43, 0.8)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  validator: (val) =>
                    val == null || val.isEmpty ? 'Enter current password' : null,
                ),
              ),


              
              // SizedBox(height: 12),
              // TextFormField(
              //   controller: newPasswordController,
              //   obscureText: true,
              //   decoration: InputDecoration(labelText: "New Password"),
              //   validator: (val) =>
              //       val == null || val.length < 6 ? 'Password must be 6+ chars' : null,
              // ),


              const SizedBox(height: 20),
              SizedBox(
                width: 370,
                height: 50,
                child: TextFormField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "New Password",
                    hintText: "Enter New Password",
                    hintStyle: TextStyle(color: Color.fromRGBO(37, 66, 43, 0.8)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  validator: (val) =>
                    val == null || val.length < 6 ? 'Password must be 6+ chars' : null,
                ),
              ),



              const SizedBox(height: 20),
              SizedBox(
                width: 370,
                height: 50,
                child: TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Confirm New Password",
                    hintText: "Re-enter New Password",
                    hintStyle: TextStyle(color: Color.fromRGBO(37, 66, 43, 0.8)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  validator: (val) =>
                    val != newPasswordController.text ? 'Passwords do not match' : null,
                ),
              ),
              // TextFormField(
              //   controller: confirmPasswordController,
              //   obscureText: true,
              //   decoration: InputDecoration(labelText: "Confirm New Password"),
              //   validator: (val) =>
              //       val != newPasswordController.text ? 'Passwords do not match' : null,
              // ),
              SizedBox(height: 70),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _changePassword,
                      style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(37, 66, 43, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 12),
                    ),
                      child: const Text(
                        'Change Password',
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
      ),
    );
  }
}
