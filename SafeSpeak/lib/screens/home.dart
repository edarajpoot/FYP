import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:login/model/contactModel.dart';
import 'package:login/model/keywordModel.dart';
import 'package:login/screens/backgroungServices.dart';
import 'package:login/widgets/customCarousel.dart';
import 'package:login/widgets/customappbar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login/model/usermodel.dart';
import 'package:login/screens/login.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  final UserModel user;
  final KeywordModel? keywordData;
  final List<ContactModel> contacts;
  const HomePage({
    Key? key, 
    required this.user,
    required this.keywordData,
    required this.contacts,
    }): super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int qIndex = 0;

  final SpeechToText speechToText = SpeechToText();
  var isListening = false;


//   Future<void> _makeEmergencyCall(String number) async {
//   await FlutterPhoneDirectCaller.callNumber(number);
// }


  getRandomQuote() {
    Random random = Random();
    setState(() {
      qIndex = random.nextInt(6);
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
    _startBackgroundService();

   if (widget.keywordData != null && widget.contacts.isNotEmpty) {
    print('✅ Sending keyword to background: ${widget.keywordData!.voiceText}');
    print('✅ Contacts to background: ${widget.contacts.length}');
    initializeService(widget.contacts, widget.keywordData!);
  } else {
    print('⚠️ No keyword or contacts provided to service');
  }
  }
   Future<void> _startBackgroundService() async {
    await FlutterBackgroundService().startService();
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
    // String keywordText = widget.keywordData?.voiceText ?? 'No Keyword';

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
  //     floatingActionButton: AvatarGlow(
  //       animate: isListening,
  //       duration: const Duration(milliseconds: 2000),
  //       glowColor: const Color(0xff00A67E),
  //       repeat: true,
  //       child: GestureDetector(
  //         onTapDown: (details) async {
  //           if (!isListening) {
  //             var available = await speechToText.initialize();
  //             if (available) {
  //               setState(() {
  //                 isListening = true;
  //                 speechToText.listen(
  //                   onResult: (result) {
  //                     setState(() {
  //                     });
  //                     String spokenText = result.recognizedWords.toLowerCase();
  //                     String keywordText = widget.keywordData?.voiceText.toLowerCase() ?? '';

  //                     if (spokenText.contains(keywordText)) {
  //   // Match found, now find all contacts linked to this keywordID
  //   String matchedKeywordID = widget.keywordData?.keywordID ?? '';

  //   for (var contact in widget.contacts) {
  //     if (contact.keywordID == matchedKeywordID) {
  //       _makeEmergencyCall(contact.contactNumber);
  //       break; // call only the first one, or remove break if you want multiple
  //     }
  //   }
  // }
  //                   },
  //                 );
  //               });
  //             } else {
  //               ScaffoldMessenger.of(context).showSnackBar(
  //                 const SnackBar(content: Text('Speech recognition is not available on this device.')),
  //               );
  //             }
  //           }
  //         },
  //         onTapUp: (details) {
  //           setState(() {
  //             isListening = false;
  //           });
  //           speechToText.stop();
  //         },
  //         child: CircleAvatar(
  //           backgroundColor: const Color(0xff00A67E),
  //           radius: 35,
  //           child: Icon(
  //             isListening ? Icons.mic : Icons.mic_none,
  //             color: Colors.white,
  //           ),
  //         ),
  //       ),
  //     ),
      appBar: AppBar(
        title: Text("Welcome, ${widget.user.name}",
        style: TextStyle(
          color: Color.fromRGBO(37, 66, 43, 1),
          fontWeight: FontWeight.bold,
        ),)),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          //   Text('User: ${widget.user.name}'),
          //   Text('Email: ${widget.user.email}'),
          //  Text('Keyword: $keywordText'),
          //    // Check if contacts are available and display them
          //   widget.contacts.isEmpty
          //       ? const Text('No contacts available.')
          //       : ListView.builder(
          //           shrinkWrap: true, // Prevents ListView from taking up unnecessary space
          //           itemCount: widget.contacts.length,
          //           itemBuilder: (context, index) {
          //             final contact = widget.contacts[index];
          //             return ListTile(
          //               title: Text(contact.contactName),
          //               subtitle: Text(contact.contactNumber),
          //             );
          //           },
          //         ),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: CarouselSlider(
                options: CarouselOptions(
                  height: 180,
                  enlargeCenterPage: true,
                  autoPlay: false,
                ),
                items: [
                  {
                    'title': 'Ambulance',
                    'subtitle': 'In case of medical emergency',
                    'buttonText': '1122',
                    'icon': Icons.local_hospital,
                    // 'onPressed': () {
                    //   print('Calling Ambulance...');
                    //    FlutterPhoneDirectCaller.callNumber('1122');
                    // },
                  },
                  {
                    'title': 'Fire Brigade',
                    'subtitle': 'In case of fire',
                    'buttonText': '16',
                    'icon': Icons.fire_extinguisher,
                    // 'onPressed': () {
                    //   print('Calling Fire Brigade...');
                    //   FlutterPhoneDirectCaller.callNumber('16');

                    // },
                  },
                  {
                   'title': 'Police',
                   'subtitle': 'For criminal activity',
                    'buttonText': '15',
                    'icon': Icons.local_police,
                    // 'onPressed': () {
                             //   print('Calling Police...');
                    //   FlutterPhoneDirectCaller.callNumber('15');

                    // },
                  },
                ].map((item) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(37, 66, 43, 1),
                          borderRadius: BorderRadius.circular(30),
                     ),
                     child: Column(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Icon(item['icon'] as IconData? ?? Icons.help_outline, color: Colors.white, size: 30),
                         Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text(
                               (item['title'] as String?) ?? 'Unknown Title',
                                style: const TextStyle(
                                 color: Colors.white,
                                 fontSize: 18,
                                 fontWeight: FontWeight.bold,
                               ),
                             ),
                             const SizedBox(height: 4),
                             Text(
                               (item['subtitle'] as String?) ?? 'No subtitle available',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: ElevatedButton(
                         style: ElevatedButton.styleFrom(
                           backgroundColor: Colors.white,
                           foregroundColor: const Color.fromRGBO(37, 66, 43, 1),
                           shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(8),
                           ),
                         ),
                         onPressed: () async {
                           var status = await Permission.phone.status;
                           if (!status.isGranted) {
                             status = await Permission.phone.request();
                           }

                           if (status.isGranted) {
                             String number = item['buttonText'] as String;
                             print('📞 Calling $number...');
                             await FlutterPhoneDirectCaller.callNumber(number);
                           } else {
                                   print('❌ Phone permission not granted');
                                   ScaffoldMessenger.of(context).showSnackBar(
                                     SnackBar(content: Text('Phone permission is required to make a call')),
                                   );
                                 }
                               },
                               child: Text(item['buttonText'] as String), // ✅ Add this line
                                  ),
                  
                           ),
                         ],
                       ),
                     );
                   },
                 );
               }).toList(),
             ),
           ),
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
CarouselSlider(
  options: CarouselOptions(
    height: 130,
    enlargeCenterPage: false,
    viewportFraction: 0.45, // Adjust this for size & spacing
    scrollDirection: Axis.horizontal, // 👈 Important
  ),
  items: [
    {
      'title': 'Police Station',
      'icon': Icons.local_police,
    },
    {
      'title': 'Bus Stop',
      'icon': Icons.directions_bus,
    },
    {
      'title': 'Pharmacy',
      'icon': Icons.local_pharmacy,
    },
    {
      'title': 'Hospital',
      'icon': Icons.local_hospital,
    },
  ].map((place) {
    return Builder(
      builder: (BuildContext context) {
        return Container(
          width: MediaQuery.of(context).size.width * 0.4, // Set width
          margin: const EdgeInsets.symmetric(horizontal: 4,), // Spacing
          decoration: BoxDecoration(
            color: const Color.fromRGBO(230, 240, 234, 1),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(place['icon'] as IconData, size: 40, color: Color.fromRGBO(37, 66, 43, 1)),
              const SizedBox(height: 10),
              Text(
                place['title'] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color.fromRGBO(37, 66, 43, 1),
                ),
              ),
            ],
          ),
        );
      },
    );
  }).toList(),
),

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
Padding(
  padding: const EdgeInsets.all(16.0), // Padding around the container
  child: Container(
    width: MediaQuery.of(context).size.width * 0.8,
    height: 180, // Container width adjustment
    padding: const EdgeInsets.all(16.0), // Padding inside the container
    decoration: BoxDecoration(
      color: Colors.white, // Background color
      borderRadius: BorderRadius.circular(20), // Rounded corners
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 8,
          offset: Offset(0, 4), // Shadow position
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center, // Center content horizontally
      children: [
        // Left side: Heading text
        Expanded(
          flex: 3, // Adjust flex as needed
          child: Text(
            'Send Location', // Heading text
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(37, 66, 43, 1), // Custom color
            ),
          ),
        ),
        // Right side: Image
        Expanded(
          flex: 2, // Adjust flex to control image size
          child: Image.asset(
            'assets/images/location.png', // Replace with your image path
            height: 100, // Image height
            width: 100, // Image width
            fit: BoxFit.cover, // Image fitting
          ),
        ),
      ],
    ),
  ),
)


          ],
        ),
      ),
    );
  }
}