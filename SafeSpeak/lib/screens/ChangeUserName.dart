import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/usermodel.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;
  const EditProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      // Update Firestore
      await FirebaseFirestore.instance
          .collection('USERS')
          .doc(widget.user.id)
          .update({'name': _nameController.text});

      // Return updated user
      UserModel updatedUser = UserModel(
        id: widget.user.id,
        name: _nameController.text,
        email: widget.user.email,
        phoneNo: widget.user.phoneNo,
        emergencyMode: widget.user.emergencyMode,
      );

      Navigator.pop(context, updatedUser); // Back to Settings
      // Navigator.pop(
      //   context,
      //   UserModel(
      //     id: widget.user.id,
      //     name: _nameController.text,
      //     email: widget.user.email,
      //     phoneNo: widget.user.phoneNo,
      //     emergencyMode: widget.user.emergencyMode,
      //   ),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Padding(
          padding: const EdgeInsets.only(top:30, left: 25.0),
          child: Text("Change UserName",
          style: TextStyle(
            color: Color.fromRGBO(37, 66, 43, 1),
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),),
        )
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // TextFormField(
                //   controller: _nameController,
                //   decoration: InputDecoration(labelText: "New Name"),
                //   validator: (value) =>
                //       value == null || value.isEmpty ? 'Enter a name' : null,
                // ),

                const SizedBox(height: 20),
                SizedBox(
                  width: 370,
                  height: 50,
                  child: TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: "User Name",
                      hintText: "Enter New User Name",
                      hintStyle: TextStyle(color: Color.fromRGBO(37, 66, 43, 0.8)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    validator: (val) =>
                       val == null || val.isEmpty ? 'Enter a name' : null,
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                   backgroundColor: const Color.fromRGBO(37, 66, 43, 1),
                   shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(30),
                   ),
                   padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 12),
                 ),
                   child: const Text(
                     'Save',
                     style: TextStyle(
                       fontSize: 16,
                       fontWeight: FontWeight.bold,
                       color: Colors.white,
                     ),
                   ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
