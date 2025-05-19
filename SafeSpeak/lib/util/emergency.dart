import 'package:location/location.dart' as location;
import 'package:sms_advanced/sms_advanced.dart';
import 'package:permission_handler/permission_handler.dart';

// Request SMS permission
Future<bool> requestSmsPermission() async {
  var status = await Permission.sms.status;
  if (!status.isGranted) {
    status = await Permission.sms.request();
  }
  return status.isGranted;
}

// Request location permission
Future<bool> requestLocationPermission() async {
  var status = await Permission.location.status;
  if (status.isDenied) {
    status = await Permission.location.request();
  }
  if (status.isPermanentlyDenied) {
    throw Exception("Location permission permanently denied.");
  }
  return status.isGranted;
}

// Get current location
Future<location.LocationData> getCurrentLocation() async {
  print("📍 Getting location...");
  location.Location locationService = location.Location();

  // Ensure location services are enabled
  bool serviceEnabled = await locationService.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await locationService.requestService();
    if (!serviceEnabled) {
      throw Exception("Location services are disabled.");
    }
  }

  // Check and request location permission
  bool permissionGranted = await requestLocationPermission();
  if (!permissionGranted) {
    throw Exception("Location permission not granted.");
  }

  // Get the current location
  return await locationService.getLocation();
}

// Send SMS with location or fallback
void sendSmsWithLocation(String number, String fallbackText) async {
  bool smsPermissionGranted = await requestSmsPermission();
  if (!smsPermissionGranted) {
    print("❌ SMS permission not granted");
    return;
  }

  try {
    location.LocationData locationData = await getCurrentLocation();

    String locationMessage =
        "There's an Emergency! Please Help. Here's my location: https://maps.google.com/?q=${locationData.latitude},${locationData.longitude}";

    // Split manually into 160-char parts
    List<String> parts = _splitMessage(locationMessage);

    SmsSender sender = SmsSender();
    for (String part in parts) {
      SmsMessage sms = SmsMessage(number, part);
      sms.onStateChanged.listen((state) {
        print('📨 SMS State: $state');
      });
      sender.sendSms(sms);
    }
  } catch (e) {
    print("⚠ Location error: $e. Sending fallback message.");
    SmsSender sender = SmsSender();
    SmsMessage sms = SmsMessage(number, fallbackText);
    sender.sendSms(sms);
  }
}

List<String> _splitMessage(String message, {int partLength = 160}) {
  List<String> parts = [];
  for (int i = 0; i < message.length; i += partLength) {
    parts.add(
      message.substring(i, i + partLength > message.length ? message.length : i + partLength),
    );
  }
  return parts;
}

// Future<void> _makePhoneCall(String phoneNumber) async {
//   final status = await Permission.phone.status;
//   if (!status.isGranted) {
//     final result = await Permission.phone.request();
//     if (!result.isGranted) {
//       print('❌ CALL_PHONE permission not granted');
//       return;
//     }
//   }

//   final callMade = await FlutterPhoneDirectCaller.callNumber(phoneNumber);
//   if (callMade != null && callMade) {
//     print('📞 Call placed successfully');
//   } else {
//     print('❌ Call failed');
//   }
// }


