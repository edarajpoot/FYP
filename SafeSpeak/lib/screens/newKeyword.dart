import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:login/model/usermodel.dart';
import 'package:login/model/keywordModel.dart';
import 'package:login/screens/Setcontact.dart' as FlutterContacts;
import 'package:login/screens/contacts_list_screen.dart';
import 'package:login/screens/editkeyword.dart';
import 'package:permission_handler/permission_handler.dart';

class AllKeywords extends StatefulWidget {
  final UserModel user;
  const AllKeywords({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<AllKeywords> createState() => _NewKeywordState();
}

class _NewKeywordState extends State<AllKeywords> {
  List<KeywordModel> keywordList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchKeywords();
  }

  Future<void> fetchKeywords() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('EmergencyAlertKeyword')
          .where('userID', isEqualTo: widget.user.id)
          .get();

      setState(() {
        keywordList = snapshot.docs.map((doc) {
          return KeywordModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching keywords: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> confirmDeleteKeyword(KeywordModel keyword) async {
  bool confirm = await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Keyword?'),
      content: Text('Are you sure you want to delete the keyword "${keyword.voiceText}" and its contacts?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );

  if (confirm) {
    await deleteKeywordAndContacts(keyword);
  }
}

Future<void> deleteKeywordAndContacts(KeywordModel keyword) async {
  try {
    // Delete contacts related to this keyword
    QuerySnapshot contactsSnapshot = await FirebaseFirestore.instance
        .collection('EmergencyContacts')
        .where('keywordID', isEqualTo: keyword.keywordID)
        .get();

    for (var doc in contactsSnapshot.docs) {
      await doc.reference.delete();
    }

    // Delete the keyword itself
    await FirebaseFirestore.instance
        .collection('EmergencyAlertKeyword')
        .doc(keyword.keywordID)
        .delete();

    // Update UI
    setState(() {
      keywordList.removeWhere((k) => k.keywordID == keyword.keywordID);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Keyword and contacts deleted successfully.')),
    );

    //  Fresh fetch after deletion
    await fetchKeywords();

  } catch (e) {
    print('Error deleting keyword: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to delete keyword.')),
    );
  }
}


  Future<void> fetchContactsForKeyword(KeywordModel keyword) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('EmergencyContacts')
          .where('keywordID', isEqualTo: keyword.keywordID)
          .get();

      List<Map<String, dynamic>> contacts = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

      if (contacts.isEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('No Contacts'),
            content: const Text('No contacts found for this keyword.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Contacts for "${keyword.voiceText}"'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  final contact = contacts[index];
                  return ListTile(
                    title: Text(contact['contactName'] ?? ''),
                    subtitle: Text(contact['contactNumber'] ?? ''),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Error fetching contacts: $e');
    }
  }

  // Modify the long press to show options for Edit and Delete
  Future<void> showEditDeleteOptions(KeywordModel keyword) async {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Edit Keyword'),
            onTap: () async {
              Navigator.pop(context);
              await navigateToEditKeywordScreen(keyword);
            },
          ),
          ListTile(
            leading: Icon(Icons.delete),
            title: Text('Delete Keyword'),
            onTap: () async {
              Navigator.pop(context);
              await confirmDeleteKeyword(keyword);
            },
          ),
        ],
      ),
    );
  }

  // Navigate to Edit Keyword Screen
  Future<void> navigateToEditKeywordScreen(KeywordModel keyword) async {
    bool? updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditKeywordScreen(keyword: keyword),
      ),
    );

    if (updated == true) {
      // Refresh the keywords list after editing
      await fetchKeywords();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 25.0),
          child: const Text('Keywords',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(37, 66, 43, 1),
              fontSize: 25,
            ),
            ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add,
              color: Color.fromRGBO(37, 66, 43, 1),
              size: 40,
              weight: 300,
              ),
            padding: const EdgeInsets.only(right: 23.0), // Right padding
            onPressed: () async {
              bool? keywordAdded = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddKeywordScreen(user: widget.user),
                ),
              );

              if (keywordAdded == true) {
                // ✅ Agar naya keyword add hua, to fresh fetch
                await fetchKeywords();
              }
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : keywordList.isEmpty
              ? const Center(child: Text('No keywords available.'))
              : ListView.builder(
                  itemCount: keywordList.length,
                  itemBuilder: (context, index) {
                    final keyword = keywordList[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: GestureDetector(
                        onTap: () => fetchContactsForKeyword(keyword),
                        onLongPress: () => showEditDeleteOptions(keyword), // Long-press to delete
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                keyword.voiceText,
                                style: const TextStyle(fontSize: 18),
                              ),
                              const Icon(Icons.info_outline),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class AddKeywordScreen extends StatefulWidget {
  final UserModel user;
  const AddKeywordScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<AddKeywordScreen> createState() => _AddKeywordScreenState();
}

class _AddKeywordScreenState extends State<AddKeywordScreen> {
  TextEditingController keywordController = TextEditingController();

  Future<void> addKeyword() async {
    if (keywordController.text.isNotEmpty) {
      try {
        // Add the new keyword to Firestore
        var keywordRef = await FirebaseFirestore.instance.collection('EmergencyAlertKeyword').add({
          'userID': widget.user.id,
          'voiceText': keywordController.text,
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Keyword added successfully!')),
        );

        // Navigate to the EmergencyContactScreen where contacts for this keyword can be added
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FlutterContacts.EmergencyContactScreen(
              userID: widget.user.id,
              keywordID: keywordRef.id,
            ),
          ),
        );
        
        // Clear the input field after adding
        keywordController.clear();

      } catch (e) {
        print('Error adding keyword: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add keyword')),
        );
      }
    }
  }
  

  
Future<List<Contact>> getContacts() async {
  if (await Permission.contacts.request().isGranted) {
    return await FlutterContacts.getContacts();
  } else {
    print("Permission denied");
    return [];
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Keyword'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: addKeyword,
          ),
        ],
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
            // ElevatedButton(
            //   onPressed: addKeyword,
            //   child: const Text('Add Keyword'),
            // ),
            const SizedBox(height: 16),
            ElevatedButton(
            onPressed: () async {
              if (keywordController.text.isEmpty) return;

              try {
                // First, add the keyword and get its ID
                var keywordRef = await FirebaseFirestore.instance.collection('EmergencyAlertKeyword').add({
                  'userID': widget.user.id,
                  'voiceText': keywordController.text,
                });

                String newKeywordID = keywordRef.id;
          
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Keyword added successfully!')),
                );

                // Fetch contacts
                List<Contact> contacts = await getContacts();

                // Navigate to contact selection screen with correct keyword ID
                final selectedContact = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ContactsListScreen(
                      contacts: contacts,
                      keywordID: newKeywordID, // ✅ CORRECT keyword ID
                    ),
                  ),
                );

                // Optional: Show selected contact name
                if (selectedContact != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Selected contact: ${selectedContact["contactName"]}')),
                  );
                }          

                keywordController.clear();

              } catch (e) {
                print('Error adding keyword and selecting contact: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Something went wrong.')),
                );
              }
            },
            child: const Text('Set Contact'),
          ),

          ],
        ),
      ),
    );
  }
}