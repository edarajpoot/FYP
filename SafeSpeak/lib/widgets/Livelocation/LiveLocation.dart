import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart' as location;
import 'package:sms_advanced/sms_advanced.dart';

class Livelocation extends StatelessWidget {
  const Livelocation({super.key});

  // Request Contact Permission
  Future<void> requestContactPermission() async {
    var status = await Permission.contacts.status;
    if (!status.isGranted) {
      await Permission.contacts.request();
    }
  }

  // Request Location Permission
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

  // Send SMS with location or fallback message
  Future<void> sendSmsWithLocation(String number, String fallbackText) async {
    bool smsPermissionGranted = await Permission.sms.isGranted;
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

  // Split message into multiple parts if it exceeds 160 characters
  List<String> _splitMessage(String message, {int partLength = 160}) {
    List<String> parts = [];
    for (int i = 0; i < message.length; i += partLength) {
      parts.add(
        message.substring(i, i + partLength > message.length ? message.length : i + partLength),
      );
    }
    return parts;
  }

  // Get Contacts
  Future<List<Contact>> getContacts() async {
    await requestContactPermission();
    if (await Permission.contacts.request().isGranted) {
      return await FlutterContacts.getContacts(withProperties: true);
    } else {
      print("Permission denied");
      return [];
    }
  }

  // Show Modal Bottom Sheet for Location Sending
 void showModelLiveLocation(BuildContext context) async {
  List<Contact> allContacts = await getContacts();
  List<Contact> filteredContacts = List.from(allContacts);
  TextEditingController searchController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Search and select a contact:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromRGBO(37, 66, 43, 1)),
                ),
                const SizedBox(height: 10),

                // 🔍 Search Bar
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      filteredContacts = allContacts
                          .where((contact) =>
                              contact.displayName
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                          .toList();
                    });
                  },
                ),
                const SizedBox(height: 10),

                // 📋 Contact List
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredContacts.length,
                    itemBuilder: (context, index) {
                      final contact = filteredContacts[index];
                      final number = contact.phones.isNotEmpty
                          ? contact.phones.first.number
                          : '';

                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(contact.displayName),
                          subtitle: Text(number),
                          trailing: IconButton(
                            icon: const Icon(Icons.send, color: Colors.green),
                            onPressed: () async {
                              String locationUrl =
                                  await getCurrentLocation().then(
                                (locationData) =>
                                    'https://maps.google.com/?q=${locationData.latitude},${locationData.longitude}',
                              );

                              print('Sending location to $number');
                              await sendSmsWithLocation(
                                number,
                                'Emergency message. Unable to fetch location.',
                              );
                              // 👇 Close the bottom sheet
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      });
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showModelLiveLocation(context),
      borderRadius: BorderRadius.circular(20),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: 180,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  'Send Location',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromRGBO(37, 66, 43, 1),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Image.asset(
                  'assets/images/location.png',
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
