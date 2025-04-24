import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactsListScreen extends StatelessWidget {
  final List<Contact> contacts;
  final String keywordID;

  const ContactsListScreen({super.key, required this.contacts, required this.keywordID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Contact")),
      body: contacts.isEmpty
          ? const Center(child: Text("No contacts found"))
          : ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                Contact contact = contacts[index];
                return ListTile(
                  title: Text(contact.displayName),
                  subtitle: Text(contact.phones.isNotEmpty ? contact.phones.first.number : "No number"),
                  onTap: () {
                    Navigator.pop(context, {
                      "contactName": contact.displayName,
                      "contactNumber": contact.phones.isNotEmpty ? contact.phones.first.number : "No number",
                    });
                  },
                );
              },
            ),
    );
  }
}
