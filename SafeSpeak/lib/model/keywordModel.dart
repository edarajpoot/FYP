import 'package:cloud_firestore/cloud_firestore.dart';

class KeywordModel {
  final String? keywordID;
  final String userID;
  final String voiceText;

  KeywordModel({
    this.keywordID,
    required this.userID,
    required this.voiceText,
  });

  // Convert the model to a Map to send to Firestore
  Map<String, dynamic> toMap() {
    return {
      "userID": userID,
      "voiceText": voiceText,
    };
  }

  // Create a KeywordModel from a Map (e.g., from Firestore)
  factory KeywordModel.fromMap(String id, Map<String, dynamic> map) {
    return KeywordModel(
      keywordID: id,
      userID: map["userID"] ?? "",  // Safely access userID
      voiceText: map["voiceText"] ?? "",  // Safely access voiceText
    );
  }

  // Create a KeywordModel from a Firestore document
  factory KeywordModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;  // Ensure safe casting
    return KeywordModel(
      keywordID: doc.id,  // Use Firestore's document ID as keywordID
      voiceText: data['voiceText'] ?? '',  // Default empty string if voiceText is missing
      userID: data['userID'] ?? '',  // Default empty string if userID is missing
    );
  }

  factory KeywordModel.fromJson(Map<String, dynamic> json) {
  return KeywordModel(
    keywordID: json['keywordID'],  // optional, can be null
    userID: json['userID'] ?? '',
    voiceText: json['voiceText'] ?? '',
  );
}

}
