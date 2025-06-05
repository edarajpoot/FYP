import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:login/model/keywordModel.dart';
import 'package:login/screens/contacts_list_screen.dart';
import 'package:permission_handler/permission_handler.dart'; // Ensure this import is correct
import 'package:login/screens/Setcontact.dart' as FlutterContacts;

class EditKeywordScreen extends StatefulWidget {
  final KeywordModel keyword;
  const EditKeywordScreen({Key? key, required this.keyword}) : super(key: key);

  @override
  _EditKeywordScreenState createState() => _EditKeywordScreenState();
}

class _EditKeywordScreenState extends State<EditKeywordScreen> {
  TextEditingController keywordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    keywordController.text = widget.keyword.voiceText;
  }

  // Update keyword in Firestore
  Future<void> updateKeyword() async {
    if (keywordController.text.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('EmergencyAlertKeyword')
            .doc(widget.keyword.keywordID)
            .update({
          'voiceText': keywordController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Keyword updated successfully!')),
        );
        Navigator.pop(context, true); // Return to previous screen
      } catch (e) {
        print('Error updating keyword: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update keyword')),
        );
      }
    }
  }

  // Change contact
  Future<void> changeContact() async {
    final contacts = await getContacts();

    if (contacts.isNotEmpty) {
      final selectedContact = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ContactsListScreen(
            contacts: contacts,
            keywordID: widget.keyword.keywordID!,
          ),
        ),
      );
      if (selectedContact != null) {
        try {
          final snapshot = await FirebaseFirestore.instance
              .collection('EmergencyContacts')
              .where('keywordID', isEqualTo: widget.keyword.keywordID)
              .limit(1)
              .get();

          if (snapshot.docs.isNotEmpty) {
            // Replace existing contact
            await FirebaseFirestore.instance
                .collection('EmergencyContacts')
                .doc(snapshot.docs.first.id)
                .update({
              'contactName': selectedContact["contactName"],
              'contactNumber': selectedContact["contactNumber"],
            });
          } else {
            // Add if not exists
            await FirebaseFirestore.instance
                .collection('EmergencyContacts')
                .add({
              'keywordID': widget.keyword.keywordID,
              'contactName': selectedContact["contactName"],
              'contactNumber': selectedContact["contactNumber"],
            });
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Contact updated: ${selectedContact["contactName"]}')),
          );
        } catch (e) {
          print('Error updating contact in Firebase: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update contact')),
          );
        }
      }

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No contacts available or permission denied')),
      );
    }
  }
  Future<void> confirmUpdateKeyword() async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text("Confirm Update"),
      content: Text("Are you sure you want to update this keyword?"),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancel")),
        TextButton(onPressed: () => Navigator.pop(context, true), child: Text("Update")),
      ],
    ),
  );

  if (confirmed == true) {
    updateKeyword();
  }
}


  // Get contacts with permission handling
  Future<List<Contact>> getContacts() async {
    if (await Permission.contacts.request().isGranted) {
      try {
        return await FlutterContacts.getContacts();
      } catch (e) {
        print('Error fetching contacts: $e');
        return [];
      }
    } else {
      print("Permission denied");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Padding(
          padding: const EdgeInsets.only(top:30, left: 25.0),
          child: Text("Edit Keyword",
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
              const SizedBox(height: 10),
                  SizedBox(
                    width: 370,
                    height: 50,
                    child: TextFormField(
                      controller: keywordController,
                      decoration: InputDecoration(
                        labelText: "Enter new keyword",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      validator: (val) =>
                         val == null || val.isEmpty ? 'Enter a Keyword' : null,
                    ),
                  ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: confirmUpdateKeyword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(37, 66, 43, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 12),
                 ),
                   child: const Text(
                    'Update',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                   ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: changeContact,
                style: ElevatedButton.styleFrom(
                   backgroundColor: const Color.fromRGBO(37, 66, 43, 1),
                   shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(30),
                   ),
                   padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 12),
                 ),
                   child: const Text(
                     'Change Number',
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
