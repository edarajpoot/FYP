import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';

final Location location = Location();

Future<void> startLocationUpdates(String userID) async {
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;

  // Request location service
  _serviceEnabled = await location.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await location.requestService();
    if (!_serviceEnabled) {
      print("❌ Location service not enabled.");
      return;
    }
  }

  // Request location permission
  _permissionGranted = await location.hasPermission();
  if (_permissionGranted == PermissionStatus.denied) {
    _permissionGranted = await location.requestPermission();
    if (_permissionGranted != PermissionStatus.granted) {
      print("❌ Location permission denied.");
      return;
    }
  }

  // Start periodic location updates every 10 seconds
  Timer.periodic(Duration(seconds: 30), (timer) async {
    await updateUserLocation(userID);
  });
}

Future<void> updateUserLocation(String userID) async {
  try {
    LocationData _locationData = await location.getLocation();

    // Delete previous location for the same user
    await FirebaseFirestore.instance
        .collection('Location')
        .where('userId', isEqualTo: userID)
        .get()
        .then((snapshot) async {
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    });

    // Store the new location in Firestore
    await FirebaseFirestore.instance.collection('Location').add({
      'userId': userID,
      'latitude': _locationData.latitude,
      'longitude': _locationData.longitude,
      'timestamp': Timestamp.now(),
    });

    print("📍 Location updated in Firestore.");
  } catch (e) {
    print("❌ Error getting location: $e");
  }
}

