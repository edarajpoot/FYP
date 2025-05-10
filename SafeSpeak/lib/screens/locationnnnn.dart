import 'package:flutter/material.dart';
import 'package:location/location.dart';

class Locationnnnn extends StatefulWidget {
  const Locationnnnn({super.key});

  @override
  State<Locationnnnn> createState() => _LocationnnnnState();
}

class _LocationnnnnState extends State<Locationnnnn> {
  final Location location = Location();
  bool _serviceEnabled = false;
  PermissionStatus? _permissionGranted;
  LocationData? _locationData;

  Future<void> _requestLocationPermission() async {
    // Step 1: Check if location service is enabled
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location service not enabled")),
        );
        return;
      }
    }

    // Step 2: Request permission
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permission denied")),
        );
        return;
      }
    }

    // Step 3: Get location
    try {
      _locationData = await location.getLocation();
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error getting location: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Get Location")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _requestLocationPermission,
              child: const Text("Get Location"),
            ),
            const SizedBox(height: 20),
            Text("Latitude  : ${_locationData?.latitude ?? "Not available"}"),
            Text("Longitude : ${_locationData?.longitude ?? "Not available"}"),
          ],
        ),
      ),
    );
  }
}
