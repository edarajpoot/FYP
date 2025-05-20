import 'package:cloud_firestore/cloud_firestore.dart';

class CallHistory {
  final String? callID;
  final String userID;
  final String contactID;
  final DateTime timeStamp;
  final String callStatus;

  CallHistory({
    this.callID,
    required this.userID,
    required this.contactID,
    required this.timeStamp,
    required this.callStatus,
  });

  Map<String, dynamic> toMap() {
    return {
      "userID": userID,
      "contactID": contactID,
      "timeStamp": Timestamp.fromDate(timeStamp),
      "callStatus": callStatus,
    };
  }

  factory CallHistory.fromMap(String id, Map<String, dynamic> map) {
    return CallHistory(
      callID: id,
      userID: map["userID"] ?? "",
      contactID: map["contactID"] ?? "",
      timeStamp: (map["timeStamp"] as Timestamp).toDate(),
      callStatus: map["callStatus"] ?? "",
    );
  }
}