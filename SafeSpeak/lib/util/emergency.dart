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
void sendSmsMessage(String number, String fallbackText) async {
  bool smsPermissionGranted = await requestSmsPermission();
  if (!smsPermissionGranted) {
    print("❌ SMS permission not granted");
    return;
  }
  

  // try {
  //   location.LocationData locationData = await getCurrentLocation();

  //   String locationMessage =
  //       "🚨 Emergency! Here's my location: https://maps.google.com/?q=${locationData.latitude},${locationData.longitude}";

  //   SmsSender sender = SmsSender();
  //   SmsMessage sms = SmsMessage(number, locationMessage);

  //   sms.onStateChanged.listen((state) {
  //     print('📨 SMS State: $state');
  //   });

  //   sender.sendSms(sms);
  // } catch (e) {
    // print("⚠ Location error: $e. Sending fallback message.");
    SmsSender sender = SmsSender();
    SmsMessage sms = SmsMessage(number, fallbackText);
    sender.sendSms(sms);
  // }
}
