import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login/screens/savedKeyword.dart';
import 'package:login/screens/splash.dart';


class EmergencyAlertKeyword {
  final String? keywordID; // Nullable since Firestore generates it
  final String userID; // Foreign Key
  final String voiceText;

  EmergencyAlertKeyword({
    this.keywordID, // Firestore will generate this
    required this.userID,
    required this.voiceText,
  });

  Map<String, dynamic> toMap() {
    return {
      "userID": userID,
      "voiceText": voiceText,
    };
  }

  factory EmergencyAlertKeyword.fromMap(String id, Map<String, dynamic> map) {
    return EmergencyAlertKeyword(
      keywordID: id, // Assign Firestore-generated ID
      userID: map["userId"] ?? "",
      voiceText: map["voiceText"] ?? "",
    );
  }
}


void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SetKeywordScreen(userID: "",),
  ));
}

class SetKeywordScreen extends StatefulWidget {
  final String userID;
  const SetKeywordScreen({super.key, required this.userID});

  @override
  _SetKeywordScreenState createState() => _SetKeywordScreenState();
}

class _SetKeywordScreenState extends State<SetKeywordScreen> {
  final TextEditingController _keywordController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveKeyword() async {
    String keywordText = _keywordController.text.trim();

    // Helper function to show error dialog
    void showError(String message) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Invalid Keyword"),
            content: Text(message),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          );
        },
      );
    }

    if (keywordText.isEmpty) {
      showError("Please enter a keyword!");
      return;
    }

    if (keywordText.length > 10) {
      showError("Keyword should not be more than 10 characters!");
      return;
    }

    if (!RegExp(r'^[a-zA-Z]+$').hasMatch(keywordText)) {
      showError("Keyword should only contain alphabets (no numbers or symbols)!");
      return;
    }

    EmergencyAlertKeyword newKeyword = EmergencyAlertKeyword(
      keywordID: "", // Firestore auto-generates
      userID: widget.userID, // Replace with actual user ID
      voiceText: keywordText,
    );

    try {
      DocumentReference docRef =
          await _firestore.collection("EmergencyAlertKeyword").add(newKeyword.toMap());
      print("Keyword saved with ID: ${docRef.id}");

      String generatedKeywordID = docRef.id;
      
      Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => KeywordSavedScreen(
        keyword: keywordText,
        keywordID: generatedKeywordID,
        userID: widget.userID,)),
    );
    
    } catch (e) {
      print("Error saving keyword: $e");
    }

    _keywordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(

              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color.fromRGBO(37, 66, 43, 1)),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const SplashScreen()));
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  Image.asset('assets/images/woman.png', width: 150, height: 150),
                  const SizedBox(height: 10),


                  const Text(
                    "Set your safety Keyword",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color.fromRGBO(37, 66, 43, 1)),
                  ),
                  const SizedBox(height: 10),

                  const Text(
                    "Speak a keyword that will activate the safety call.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Color.fromRGBO(37, 66, 43, 0.8)),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: 370,
                    height: 50,
                    child: 
                     TextField(
                      controller: _keywordController,
                      decoration: const InputDecoration(labelText: "Enter Keyword"),
                      ),
                  ),

                  
                  const SizedBox(height: 40),

                  ElevatedButton(
                    onPressed: saveKeyword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(37, 66, 43, 1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 12),
                    ),
                    child: const Text(
                      "Save Keyword",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}