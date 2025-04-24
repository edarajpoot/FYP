import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login/screens/login.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:login/screens/contacts_list_screen.dart';

class EmergencyContact {
  final String? contactID;
  final String userID;
  final String keywordID;
  final String contactName;
  final String contactNumber;

  EmergencyContact({
    this.contactID,
    required this.userID,
    required this.keywordID,
    required this.contactName,
    required this.contactNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      "userID": userID,
      "keywordID": keywordID,
      "contactName": contactName,
      "contactNumber": contactNumber,
    };
  }

  factory EmergencyContact.fromMap(String id, Map<String, dynamic> map) {
    return EmergencyContact(
      contactID: id,
      userID: map["userID"] ?? "",
      keywordID: map["keywordID"] ?? "",
      contactName: map["contactName"] ?? "",
      contactNumber: map["contactNumber"] ?? "",
    );
  }
}

Future<List<Contact>> getContacts() async {
  if (await Permission.contacts.request().isGranted) {
    return await FlutterContacts.getContacts(withProperties: true);
  } else {
    print("Permission denied");
    return [];
  }
}



class EmergencyContactScreen extends StatefulWidget {
  final String keywordID;
  final String userID;
  const EmergencyContactScreen({
    super.key, 
    required this.keywordID,
    required this.userID,
    });

  @override
  _EmergencyContactScreenState createState() => _EmergencyContactScreenState();
}

class _EmergencyContactScreenState extends State<EmergencyContactScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addEmergencyContact() async {
    String contactName = _nameController.text.trim();
    String contactNumber = _numberController.text.trim();

    if (contactName.isEmpty || contactNumber.isEmpty) {
      print("Please enter both name and number!");
      return;
    }

    try {
      await _firestore.collection("EmergencyContacts").add({
        "keywordID": widget.keywordID,
        "userID": widget.userID,
        "contactName": contactName,
        "contactNumber": contactNumber,
      });
      print("Emergency contact added successfully!");
    } catch (e) {
      print("Error saving emergency contact: $e");
    }

    _nameController.clear();
    _numberController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Emergency Contact")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Contact Name"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _numberController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: "Contact Number"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: addEmergencyContact,
              child: const Text("Save Contact"),
            ),
            ElevatedButton(
              onPressed: () async {
                List<Contact> contacts = await getContacts();
                final selectedContact = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ContactsListScreen(
                      contacts: contacts,
                      keywordID: widget.keywordID,
                    ),
                  ),
                );

                if (selectedContact != null) {
                  setState(() {
                    _nameController.text = selectedContact["contactName"];
                    _numberController.text = selectedContact["contactNumber"];
                  });
                }
              },
              child: const Text("Add from Phone"),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LogInScreen()),
                  );
              },
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(15),
                backgroundColor: const Color.fromRGBO(37, 66, 43, 1), // Button color
              ),
              child: const Text("Next"),
            ),
          ],
        ),
      ),
    );
  }
}
