import 'dart:math';
import 'package:login/model/contactModel.dart';
import 'package:login/model/keywordModel.dart';
import 'package:login/screens/backgroungServices.dart';
import 'package:login/widgets/Emergnecywidget.dart';
import 'package:login/widgets/Livelocation/LiveLocation.dart';
import 'package:login/widgets/customCarousel.dart';
import 'package:login/widgets/customappbar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login/model/usermodel.dart';
import 'package:login/screens/login.dart';
import 'package:login/widgets/live_safe.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  final UserModel user;
  final List<KeywordModel> allKeywords;
  final List<ContactModel> contacts;
  final Function? onMapFunction;
  const HomePage({
    Key? key, 
    required this.user,
    required this.allKeywords,
    required this.contacts,
    this.onMapFunction,
    }): super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int qIndex = 0;
  String userName = '';

  final SpeechToText speechToText = SpeechToText();
  var isListening = false;

  getRandomQuote() {
    Random random = Random();
    setState(() {
      qIndex = random.nextInt(8);
    });
  }

Future<void> _requestMicrophonePermission() async {
  var status = await Permission.microphone.status;

  if (status.isGranted) {
    print('Microphone permission already granted');
    return;
  }

  if (!status.isDenied && !status.isPermanentlyDenied) {
    print('Waiting for previous permission request to complete...');
    return;
  }

  var result = await Permission.microphone.request();
  print('Microphone permission result: $result');
}



  @override
  void initState() {
    getRandomQuote();
    _requestMicrophonePermission();
    super.initState();
  //   if (widget.user.emergencyMode == true) {
  //   print("service Initialize");
  //   initializeService(widget.contacts, widget.allKeywords);
  // } if (widget.user.emergencyMode == true) {
  //   FlutterBackgroundService().invoke('stopService');
  // }

  initializeService(widget.contacts, widget.allKeywords);
}


  

  Future<void> signout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LogInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 25.0),
          child: Text("Welcome, ${widget.user.name}",
          style: TextStyle(
            color: Color.fromRGBO(37, 66, 43, 1),
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),),
        )),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomAppBar(
              quoteIndex: qIndex,
              onTap: () {
                getRandomQuote();
              },
            ),
            CustomCarousel(),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 18.0),
              child: Align(
               alignment: Alignment.centerLeft, // Other options: .centerLeft, .centerRight, etc.
               child: Text(
                "Emergency",
                 style: TextStyle(
                  color: Color.fromRGBO(37, 66, 43, 1),
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
               ),
              ),
            ),

            const SizedBox(height: 10),

            Emergnecywidget(),
          
           const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.only(left: 18.0),
              child: Align(
               alignment: Alignment.centerLeft, // Other options: .centerLeft, .centerRight, etc.
               child: Text(
                "Nearby Places",
                 style: TextStyle(
                  color: Color.fromRGBO(37, 66, 43, 1),
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
               ),
              ),
            ),
            
            const SizedBox(height: 10),

            LiveSafe(),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.only(left: 18.0),
              child: Align(
               alignment: Alignment.centerLeft, // Other options: .centerLeft, .centerRight, etc.
               child: Text(
                "Live Location",
                 style: TextStyle(
                  color: Color.fromRGBO(37, 66, 43, 1),
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
               ),
              ),
            ),

            const SizedBox(height: 10),

            Livelocation(),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}