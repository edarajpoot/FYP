import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:login/model/usermodel.dart';

class EditPhoneNumberScreen extends StatefulWidget {
  final UserModel user;
  const EditPhoneNumberScreen({Key? key, required this.user}) : super(key: key);

  @override
  _EditPhoneNumberScreenState createState() => _EditPhoneNumberScreenState();
}

class _EditPhoneNumberScreenState extends State<EditPhoneNumberScreen> {
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.user.phoneNo);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _savePhoneNumber() async {
    final newPhone = _phoneController.text.trim();

    if (newPhone.isEmpty) {
      // Show error or validation
      return;
    }

    // Update Firestore
    await FirebaseFirestore.instance.collection('USERS').doc(widget.user.id).update({
      'phoneNo': newPhone,
    });

    // Create updated user model to return
    final updatedUser = UserModel(
      id: widget.user.id,
      name: widget.user.name,
      email: widget.user.email,
      phoneNo: newPhone,
      emergencyMode: widget.user.emergencyMode,
    );

    Navigator.pop(context, updatedUser);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Padding(
          padding: const EdgeInsets.only(top:30, left: 25.0),
          child: Text("Edit Phone Number",
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
          child: Column(
            children: [
              const SizedBox(height: 20),
              SizedBox(
                width: 370,
                height: 50,
                child: TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: "Phone Number",
                    hintText: "Enter Phone number",
                    hintStyle: TextStyle(color: Color.fromRGBO(37, 66, 43, 0.8)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (val) =>
                    val == null || val.isEmpty ? 'Enter a Phone number' : null,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _savePhoneNumber,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
