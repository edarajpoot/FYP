import 'package:call_log/call_log.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:login/model/callHistoryModel.dart';
import 'package:login/screens/splash.dart';
import 'package:login/util/emergency.dart';
import 'package:permission_handler/permission_handler.dart';
import 'firebase_options.dart';

String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

Future<void> _makePhoneCall(String phoneNumber) async {
  final status = await Permission.phone.status;
  if (!status.isGranted) {
    final result = await Permission.phone.request();
    if (!result.isGranted) {
      print('CALL_PHONE permission not granted');
      return;
    }
  }
  await FlutterPhoneDirectCaller.callNumber(phoneNumber);
  await Future.delayed(Duration(seconds: 15));
  await saveCallToFirestore(phoneNumber,userId,);
}

Future<String?> getContactIdByNumber(String number, String userId,) async {
  try {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('EmergencyContacts')
        .where('contactNumber', isEqualTo: number)
        .where('userID', isEqualTo: userId) 
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.id;
    } else {
      print("Contact not found");
      return null;
    }
  } catch (e) {
    print("Error getting contact ID: $e");
    return null;
  }
}

Future<void> saveCallToFirestore(String number, String userId) async {
  try {
    debugPrint('Saving call history for $number (User: $userId)');
    String? contactId = await getContactIdByNumber(number, userId);
    if (contactId == null) {
      debugPrint('No contact found for number: $number');
      return;
    }

    CallLogEntry? latestCall;
    for (int i = 0; i < 5; i++) { // Try 5 times
      final logs = await CallLog.query(
        dateFrom: DateTime.now().subtract(Duration(minutes: 5)).millisecondsSinceEpoch,
        number: number,
      );

      if (logs.isNotEmpty) {
        final entry = logs.first;
        // Check if the call has ended (has duration or call type)
        if (entry.duration != null && entry.duration! > 0 || entry.callType != null) {
          latestCall = entry;
          break;
        }
      }

      debugPrint('Waiting for call log update...');
      await Future.delayed(Duration(seconds: 5));
    }

    if (latestCall == null) {
      debugPrint('No valid call log found for $number');
      return;
    }

    String callStatus = _getCallStatusFromLog(latestCall);

    final history = CallHistory(
      userID: userId,
      contactID: contactId,
      timeStamp: latestCall.timestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(latestCall.timestamp!)
          : DateTime.now(),
      callStatus: callStatus,
    );

    await FirebaseFirestore.instance.collection('CallHistory').add(history.toMap());
    debugPrint('Call saved successfully. Status: $callStatus');
  } catch (e, stack) {
    debugPrint('Error saving call history: $e');
    debugPrint('Stack trace: $stack');
  }
}


// Future<void> saveCallToFirestore(String number, String userId) async {
//   try {
//     debugPrint('Saving call history for $number (User: $userId)');
//     String? contactId = await getContactIdByNumber(number, userId);
//     if (contactId == null) {
//       debugPrint('No contact found for number: $number');
//       return;
//     }

//     // Retry fetching call log up to 3 times
//     CallLogEntry? latestCall;
//     for (int i = 0; i < 3; i++) {
//       final logs = await CallLog.query(
//         dateFrom: DateTime.now().subtract(Duration(minutes: 5)).millisecondsSinceEpoch,
//         number: number,
//       );
//       if (logs.isNotEmpty) {
//         latestCall = logs.first;
//         break;
//       }
//       await Future.delayed(Duration(seconds: 10)); 
//     }

//     if (latestCall == null) {
//       debugPrint('No call log found for $number');
//       return;
//     }

//     String callStatus = _getCallStatusFromLog(latestCall);

//     final history = CallHistory(
//       userID: userId,
//       contactID: contactId,
//       timeStamp: DateTime.now(),
//       callStatus: callStatus,
//     );

//     await FirebaseFirestore.instance.collection('CallHistory').add(history.toMap());
//     debugPrint('Call saved successfully. Status: $callStatus');
//   } catch (e, stack) {
//     debugPrint('Error saving call history: $e');
//     debugPrint('Stack trace: $stack');
//   }
// }


// Future<void> saveCallToFirestore(String number, String userId) async {
//   try {
//     debugPrint('Saving call history for $number (User: $userId)');
    
//     String? contactId = await getContactIdByNumber(number, userId);
//     if (contactId == null) {
//       debugPrint('No contact found for number: $number');
//       return;
//     }

//     // Fetch the latest call log for this number
//     final Iterable<CallLogEntry> callLogs = await CallLog.query(
//       dateFrom: DateTime.now().subtract(Duration(minutes: 1)).millisecondsSinceEpoch,
//       number: number,
//     );

//     String callStatus = "";
//     if (callLogs.isNotEmpty) {
//       callStatus = _getCallStatusFromLog(callLogs.first);
//     }

//     final history = CallHistory(
//       userID: userId,
//       contactID: contactId,
//       timeStamp: DateTime.now(),
//       callStatus: callStatus,
//     );

//     await FirebaseFirestore.instance
//         .collection('CallHistory')
//         .add(history.toMap());
    
//     debugPrint('Call saved successfully. Status: $callStatus');
//   } catch (e, stack) {
//     debugPrint('Error saving call history: $e');
//     debugPrint('Stack trace: $stack');
//   }
// }

String _getCallStatusFromLog(CallLogEntry call) {
  switch (call.callType) {
    case CallType.outgoing:
      return (call.duration ?? 0) > 0 ? "accepted" : "missed";
    case CallType.missed:
      return "missed";
    case CallType.rejected:
      return "rejected";
    default:
      return "outgoing";
  }
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseAuth.instance.setLanguageCode("en");
  


  // for high priority
  void setupBackgroundListeners() {
  FlutterBackgroundService().on('make-call').listen((event) async {

    if (event != null && event['contacts'] != null) {
      List<dynamic> contacts = event['contacts'];
      FlutterBackgroundService().invoke("setAsForeground");

      for (var contact in contacts) {
        String contactNumber = contact['contactNumber'];

        if (contactNumber.isNotEmpty) {

           // Bring service to foreground before sensitive actions
          FlutterBackgroundService().invoke("setAsForeground");

          print("Calling from MAIN isolate: $contactNumber");
          await _makePhoneCall(contactNumber);

          print("Sending Message from MAIN isolate: $contactNumber");
          sendSmsWithLocation(contactNumber, "This is an emergency! Please help.");

          await Future.delayed(Duration(seconds: 5));
        }
      }
    }
  });

  // for low priority
  FlutterBackgroundService().on('send-location').listen((event) async {
    if (event != null && event['contacts'] != null) {
      List<dynamic> contacts = event['contacts'];
      String message = event['message'] ?? 'Location alert';
      
      for (var contact in contacts) {
        String contactNumber = contact['contactNumber'];
        if (contactNumber.isNotEmpty) {
          print("Sending location to: $contactNumber");
          sendSmsWithLocation(contactNumber, message);
        }
      }
    }
  });

}



 setupBackgroundListeners();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:SplashScreen()
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
  // FirebaseService fbs = GetIt.instance.get<FirebaseService>();
  // fbs.addUser();
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
