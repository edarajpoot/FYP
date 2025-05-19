// import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:login/model/contactModel.dart';
import 'package:login/model/keywordModel.dart';
import 'package:login/screens/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'dart:async';
import 'package:flutter/services.dart';
// import 'package:path_provider/path_provider.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

const platform = MethodChannel('com.safespeak/audio');


// Method to invoke audio playback on the phone's background during the call
Future<void> playAudioDuringCall(String filePath) async {
  try {
    // Play the audio file using platform-specific method channel
    await platform.invokeMethod('playAudioDuringCall', {'filePath': filePath});
    print("Audio is playing during the call.");
  } catch (e) {
    print("Error playing audio: $e");
  }
}


// Initialize the notification plugin
Future<void> initializeService(List<ContactModel> contacts, List<KeywordModel> keywordDataList) async {
  print("🚀 Starting background service...");
  print("Keyword to detect: ${keywordDataList.map((k) => k.voiceText).join(', ')}");
  print("Total contacts: ${contacts.length}");

  // Request permissions
  await Permission.microphone.request();
  await Permission.phone.request();
  await Permission.sms.request();
  await Permission.ignoreBatteryOptimizations.request(); // 🔋 Battery optimization ignore
  await Permission.location.request();

  PermissionStatus microphoneStatus = await Permission.microphone.status;
  PermissionStatus phoneStatus = await Permission.phone.status;
  PermissionStatus batteryOptStatus = await Permission.ignoreBatteryOptimizations.status;
  // PermissionStatus locationStatus = await Permission.location.status;

  if (microphoneStatus.isGranted && phoneStatus.isGranted && batteryOptStatus.isGranted) {
    print("✅ All required permissions granted.");
  } else {
    print("❌ Required permissions not granted.");
    return;
  }

  final service = FlutterBackgroundService();
  createNotificationChannel();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: true,
      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'SafeSpeak Running',
      initialNotificationContent: 'Listening for keywords...',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(),
  );

  await service.startService();

  List<Map<String, dynamic>> contactMaps = contacts.map((e) => e.toJson()).toList();

  service.invoke('start-listening', {
  'contacts': contactMaps,
  'keywordText': keywordDataList.map((e) => {
    'keywordID': e.keywordID,
    'userID': e.userID,
    'voiceText': e.voiceText,
    'priority': e.priority,
  }).toList(),
  });

  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  startLocationUpdates(currentUserId);
}


void createNotificationChannel() async {
  final AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground',
    'SafeSpeak Running',
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

bool isCallInProgress = false;

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  await Firebase.initializeApp();
  WidgetsFlutterBinding.ensureInitialized();
  print("✅ Background service started.");

  bool isListening = false;

  service.on('stopService').listen((event) {
    isListening = false;
    service.stopSelf();
  });
  

  final speech = SpeechToText();
  bool available = await speech.initialize();

  if (!available) {
    print("❌ Speech recognition not available.");
    return;
  }

  List<dynamic> contacts = [];
  List<KeywordModel> keywordDataList = [];

  service.on('start-listening').listen((event) async {
    if (event != null) {
      contacts = event['contacts'] ?? [];

      // Ensure userID is not null, use an empty string or any default value you prefer
      // String userID = FirebaseAuth.instance.currentUser?.uid ?? "";

     if (event['keywordText'] != null && event['keywordText'] is List) {
      var rawList = event['keywordText'] as List;
      keywordDataList = rawList.map<KeywordModel>((e) {
        if (e is String) {
          return KeywordModel(voiceText: e, userID: "", priority: "low"); // fallback if needed
        } else if (e is Map<String, dynamic>) {
          return KeywordModel.fromJson(e);
        } else {
          throw FormatException("Invalid keywordText item type: ${e.runtimeType}");
        }
      }).toList();
    }

    else { 
      print("❌ Invalid keywordText format in event.");
      }


      print("🎧 Listening for keyword: ${keywordDataList.map((e) => e.voiceText).join(", ")}");

      if (!isListening) {
        isListening = true;

        await startListeningSession(speech, contacts, keywordDataList, service);
      }
    }
  });

  // 🔁 Restart listening if it stops unexpectedly every 30 seconds
  Timer.periodic(Duration(seconds: 2), (timer) async {
    if (!speech.isListening && contacts.isNotEmpty && keywordDataList.isNotEmpty) {
      print("🔁 Mic was stopped. Restarting listening...");
      await startListeningSession(speech, contacts, keywordDataList, service);
    }
  });
}


Future<void> startListeningSession(SpeechToText speech, List<dynamic> contacts, List<KeywordModel> keywordDataList, ServiceInstance service) async {
  print("🎤 Starting new listening session...");

  speech.listen(
    onResult: (result) async {
      String spoken = result.recognizedWords.toLowerCase();
      print("🗣️ Heard: $spoken");

      // Iterate over the list of keywords and match the spoken word
      for (var keyword in keywordDataList) {
        if (spoken.contains(keyword.voiceText.toLowerCase()) && !isCallInProgress) {
          print("🚨 Keyword matched! Calling now...");
          isCallInProgress = true;

          // 🔍 Filter contacts linked to this keyword
          var matchedContacts = contacts.where((contact) =>
            contact['keywordID'] == keyword.keywordID
          ).toList();

          if (matchedContacts.isEmpty) {
            print("⚠️ No contacts found for keyword: ${keyword.voiceText}");
            return;
          }

          try {
            for (var contact in matchedContacts) {
              await Future.delayed(Duration(seconds: 2));
              service.invoke('make-call', {
                'contacts': [contact],
              });

              await Future.delayed(Duration(seconds: 5)); // Allow time for the call to be made
            }
          } catch (e) {
            print("❌ Error during emergency handling: $e");
          }

          await Future.delayed(Duration(seconds: 5));
          isCallInProgress = false;
        }
      }

      // If it's the final result, restart listening without stopping
      if (result.finalResult) {
        print("🛑 Final result received. Restarting listening without stopping...");
        await Future.delayed(Duration(seconds: 1));
        await startListeningSession(speech, contacts, keywordDataList, service); // Recursively call to restart listening
      }
    },
  );
}
