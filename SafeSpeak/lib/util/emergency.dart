// import 'package:telephony/telephony.dart';

// final Telephony telephony = Telephony.instance;

// Future<void> sendEmergencySms(String number, String message) async {
//   bool? permissionsGranted = await telephony.requestSmsPermissions;

//   bool? perGranted = await telephony.requestSmsPermissions;
//   bool? isDefault = await telephony.isSmsCapable;

//   if (isDefault == false || perGranted == false) {
//     print("❌ SMS not allowed. Please grant permission or set app as default SMS app.");
//     return;
//   }
// if (permissionsGranted ?? false){
//   try {
//       await telephony.sendSms(
//         to: number,
//         message: message,
//       );
//       print("📨 SMS sent to $number");
//     } catch (e) {
//       print("❌ Error sending SMS to $number: $e");
//     }
// }
// }
// import 'package:sms_advanced/sms_advanced.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:geolocator/geolocator.dart';



// Future<Position> getCurrentLocation() async {
//   bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//   if (!serviceEnabled) {
//     await Geolocator.openLocationSettings();
//     throw Exception("Location services are disabled.");
//   }

//   LocationPermission permission = await Geolocator.checkPermission();
//   if (permission == LocationPermission.denied) {
//     permission = await Geolocator.requestPermission();
//     if (permission == LocationPermission.denied) {
//       throw Exception("Location permission denied.");
//     }
//   }

//   if (permission == LocationPermission.deniedForever) {
//     throw Exception("Location permission permanently denied.");
//   }

//   return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
// }

// Future<bool> requestSmsPermission() async {
//   var status = await Permission.sms.status;
//   if (!status.isGranted) {
//     status = await Permission.sms.request();
//   }
//   return status.isGranted;
// }


// void sendSmsMessage(String number, String fallbackText) async {
//   bool permissionGranted = await requestSmsPermission();
//   if (!permissionGranted) {
//     print("❌ SMS permission not granted");
//     return;
//   }

//   try {
//     Position position = await getCurrentLocation();

//     String locationMessage =
//         "🚨 Emergency! Here's my location: https://maps.google.com/?q=${position.latitude},${position.longitude}";

//     SmsSender sender = SmsSender();
//     SmsMessage sms = SmsMessage(number, locationMessage);

//     sms.onStateChanged.listen((state) {
//       print('📨 SMS State: $state');
//     });

//     sender.sendSms(sms);
//   } catch (e) {
//     // If location fails, send fallback text
//     print("⚠ Location error: $e. Sending fallback message.");
//     SmsSender sender = SmsSender();
//     SmsMessage sms = SmsMessage(number, fallbackText);
//     sender.sendSms(sms);
// }
// }

import 'package:sms_advanced/sms_advanced.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestSmsPermission() async {
  var status = await Permission.sms.status;
  if (!status.isGranted) {
    status = await Permission.sms.request();
  }
  return status.isGranted;
}


void sendSmsMessage(String number, String message) async {
  bool permissionGranted = await requestSmsPermission();
  if (!permissionGranted) {
    print("❌ SMS permission not granted");
    return;
  }

  SmsSender sender = SmsSender();
  SmsMessage sms = SmsMessage(number, message);

  sms.onStateChanged.listen((state) {
    print('📨 SMS State: $state');
  });

  sender.sendSms(sms);
}
