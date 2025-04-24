import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:login/model/contactModel.dart';
import 'package:login/model/keywordModel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'dart:async';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

// Initialize the notification plugin
Future<void> initializeService(List<ContactModel> contacts, KeywordModel keywordModel) async {
  print("🚀 Starting background service...");
  print("Keyword to detect: \${keywordModel.voiceText}");
  print("Total contacts: \${contacts.length}");

  // Request permissions
  await Permission.microphone.request();
  await Permission.phone.request();
  await Permission.sms.request();
  await Permission.ignoreBatteryOptimizations.request(); // 🔋 Battery optimization ignore

  PermissionStatus microphoneStatus = await Permission.microphone.status;
  PermissionStatus phoneStatus = await Permission.phone.status;
  PermissionStatus batteryOptStatus = await Permission.ignoreBatteryOptimizations.status;

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
    'keywordText': keywordModel.voiceText,
  });
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
  String keyword = "";
  service.on('start-listening').listen((event) async {
    if (event != null) {
      contacts = event['contacts'];
      keyword = (event['keywordText'] ?? "").toLowerCase();

      print("🎧 Listening for keyword: \$keyword");

      if (!isListening) {
        isListening = true;
        await startListeningSession(speech, contacts, keyword, service);
      }
    }
  });

  // 🔁 Restart listening if it stops unexpectedly every 30 seconds
  Timer.periodic(Duration(seconds: 2), (timer) async {
    if (!speech.isListening && contacts.isNotEmpty && keyword.isNotEmpty) {
      print("🔁 Mic was stopped. Restarting listening...");
      await startListeningSession(speech, contacts, keyword, service);
    }
  });
}


Future<void> startListeningSession(SpeechToText speech, List<dynamic> contacts, String keyword, ServiceInstance service) async {
  print("🎤 Starting new listening session...");

  speech.listen(
    onResult: (result) async {
      String spoken = result.recognizedWords.toLowerCase();
      print("🗣️ Heard: \$spoken");

      if (spoken.contains(keyword) && !isCallInProgress) {
        print("🚨 Keyword matched! Calling now...");
        isCallInProgress = true;

        try {
          for (var contact in contacts) {
            await Future.delayed(Duration(seconds: 2));
            service.invoke('make-call', {
              'contacts': [contact],
            });

            await Future.delayed(Duration(seconds: 5));
          }
        } catch (e) {
          print("❌ Error during emergency handling: \$e");
        }

        await Future.delayed(Duration(seconds: 5));
        isCallInProgress = false;
      }

      if (result.finalResult) {
        print("🛑 Final result received. Restarting listening without stopping...");
        await Future.delayed(Duration(seconds: 1));
        await startListeningSession(speech, contacts, keyword, service);
      }
    },
  );
}