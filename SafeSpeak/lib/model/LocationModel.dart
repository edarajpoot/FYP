// lib/models/location_history.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class LocationHistory {
  final String? locationID;
  final String userID;
  final double latitude;
  final double longitude;
  final Timestamp timeStamp;

  LocationHistory({
    this.locationID,
    required this.userID,
    required this.latitude,
    required this.longitude,
    required this.timeStamp,
  });

  Map<String, dynamic> toMap() {
    return {
      "userId": userID,
      "latitude": latitude,
      "longitude": longitude,
      "timestamp": timeStamp,
    };
  }

  factory LocationHistory.fromMap(String id, Map<String, dynamic> map) {
    return LocationHistory(
      locationID: id,
      userID: map["userId"] ?? "",
      latitude: map["latitude"] ?? 0.0,
      longitude: map["longitude"] ?? 0.0,
      timeStamp: map["timestamp"] ?? Timestamp.now(),
    );
  }
}
