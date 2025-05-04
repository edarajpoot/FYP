import 'package:location/location.dart' as location;
import 'package:sms_advanced/sms_advanced.dart';
import 'package:permission_handler/permission_handler.dart'; // No prefix needed

Future<location.LocationData> getCurrentLocation() async {
  print("Location section");
  location.Location locationService = new location.Location();

  // Check if location services are enabled
  bool _serviceEnabled;
  PermissionStatus _permissionGranted; // Use the PermissionStatus from permission_handler

  _serviceEnabled = await locationService.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await locationService.requestService();
    if (!_serviceEnabled) {
      throw Exception("Location services are disabled.");
    }
  }

  _permissionGranted = await Permission.sms.status; // Corrected reference
  if (_permissionGranted == PermissionStatus.denied) {
    _permissionGranted = await Permission.sms.request();
    if (_permissionGranted != PermissionStatus.granted) {
      throw Exception("Location permission denied.");
    }
  }

  if (_permissionGranted == PermissionStatus.permanentlyDenied) {
    throw Exception("Location permission permanently denied.");
  }

  // Get the current location
  return await locationService.getLocation();
}

Future<bool> requestSmsPermission() async {
  var status = await Permission.sms.status;
  if (!status.isGranted) {
    status = await Permission.sms.request();
  }
  return status.isGranted;
}

void sendSmsMessage(String number, String fallbackText) async {
  bool permissionGranted = await requestSmsPermission();
  if (!permissionGranted) {
    print("❌ SMS permission not granted");
    return;
  }

  try {
    location.LocationData locationData = await getCurrentLocation();

    String locationMessage =
        "🚨 Emergency! Here's my location: https://maps.google.com/?q=${locationData.latitude},${locationData.longitude}";

    SmsSender sender = SmsSender();
    SmsMessage sms = SmsMessage(number, locationMessage);

    sms.onStateChanged.listen((state) {
      print('📨 SMS State: $state');
    });

    sender.sendSms(sms);
  } catch (e) {
    // If location fails, send fallback text
    print("⚠ Location error: $e. Sending fallback message.");
    SmsSender sender = SmsSender();
    SmsMessage sms = SmsMessage(number, fallbackText);
    sender.sendSms(sms);
  }
}