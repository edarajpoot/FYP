import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login/screens/splash.dart';
import 'package:login/screens/Setcontact.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: KeywordSavedScreen(
      keyword: "Test Keyword",
      userID:"TestUserId",
      keywordID:"TestKeywordId",
      priority: "low",),
  ));
}

class KeywordSavedScreen extends StatefulWidget {

  final String keyword;
  final String userID;
  final String keywordID;
  final String priority;

  const KeywordSavedScreen({super.key, 
  required this.keyword,
  required this.userID,
  required this.keywordID,
  required this.priority
  });
  
  

  @override
  _KeywordSavedScreenState createState() => _KeywordSavedScreenState();
}

class _KeywordSavedScreenState extends State<KeywordSavedScreen> {
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Contact>> getContacts() async {
    if (await FlutterContacts.requestPermission()) {
      return await FlutterContacts.getContacts(withProperties: true);
    }
    return [];
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
                  Image.asset('assets/images/login.png', width: 150, height: 150),
                  const SizedBox(height: 20),
                  const Text(
                    "Congratulations, \nKeyword Saved!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color.fromRGBO(37, 66, 43, 1)),
                  ),
                  const SizedBox(height: 50),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 10),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(37, 66, 43, 0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.keyword, // Fixed
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromRGBO(37, 66, 43, 1)),
                    ),
                  ),
                  const SizedBox(height: 60),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                         MaterialPageRoute(builder: (context) => EmergencyContactScreen(
                          keywordID: widget.keywordID,
                          userID:widget.userID,)),
                        );
                        },
                        style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(37, 66, 43, 1),
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 12),
                        ),
                        child: const Text(
                      "Set Contact",
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
