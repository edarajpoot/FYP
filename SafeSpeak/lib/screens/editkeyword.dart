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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selected contact: ${selectedContact["contactName"]}')),
        );
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
        title: const Text('Edit Keyword'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: keywordController,
              decoration: InputDecoration(
                labelText: 'Enter new keyword',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: confirmUpdateKeyword,
              child: const Text('Update Keyword'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: changeContact,
              child: const Text('Change Contact'),
            ),
          ],
        ),
      ),
    );
  }
}
