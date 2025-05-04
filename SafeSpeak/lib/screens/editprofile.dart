import 'package:flutter/material.dart';
import 'package:login/database_service.dart';
import 'package:login/model/usermodel.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;

  EditProfileScreen({required this.user});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
  }

  Future<void> _saveProfile() async {
    UserModel updatedUser = UserModel(
      id: widget.user.id,
      name: _nameController.text,
      email: _emailController.text,
      phoneNo: widget.user.phoneNo,
      emergencyMode: widget.user.emergencyMode, // Or allow this to be edited
    );

    await DatabaseService().updateUserProfile(updatedUser);

    // After updating, navigate back to the ProfileScreen with updated data
    Navigator.pop(context, updatedUser);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            // Add other fields as necessary

            ElevatedButton(
              onPressed: _saveProfile,
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
 }