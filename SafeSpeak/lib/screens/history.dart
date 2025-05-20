// import 'package:call_log/call_log.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:permission_handler/permission_handler.dart';

// class CallHistory {
//   final String? callID;
//   final String userID;
//   final String contactID;
//   final DateTime timeStamp;
//   final String callStatus;

//   CallHistory({
//     this.callID,
//     required this.userID,
//     required this.contactID,
//     required this.timeStamp,
//     required this.callStatus,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       "userId": userID,
//       "contactId": contactID,
//       "timestamp": Timestamp.fromDate(timeStamp),
//       "callstatus": callStatus,
//     };
//   }

//   factory CallHistory.fromMap(String id, Map<String, dynamic> map) {
//     return CallHistory(
//       callID: id,
//       userID: map["userId"] ?? "",
//       contactID: map["contactId"] ?? "",
//       timeStamp: (map["timestamp"] as Timestamp).toDate(),
//       callStatus: map["callstatus"] ?? "",
//     );
//   }
// }

// class CallHistoryService {
//   final FirebaseFirestore firestore = FirebaseFirestore.instance;

//   // Request phone permissions
//   Future<bool> requestPermissions() async {
//     var status = await Permission.phone.status;
//     if (!status.isGranted) {
//       var result = await Permission.phone.request();
//       return result.isGranted;
//     }
//     return true;
//   }

//   // Fetch call logs and save to Firestore
//   Future<void> fetchAndSaveCallLogs(String userId) async {
//     bool granted = await requestPermissions();

//     if (!granted) {
//       print("Phone permission not granted.");
//       return;
//     }

//     Iterable<CallLogEntry> entries = await CallLog.get();

//     for (var entry in entries) {
//       String callStatus = _mapCallTypeToStatus(entry.callType);

//       CallHistory call = CallHistory(
//         userID: userId,
//         contactID: entry.number ?? "Unknown",
//         timeStamp: DateTime.fromMillisecondsSinceEpoch(entry.timestamp ?? 0),
//         callStatus: callStatus,
//       );

//       await _saveCallToFirestore(call);
//     }
//     print("All call logs saved.");
//   }

//   String _mapCallTypeToStatus(CallType? type) {
//     switch (type) {
//       case CallType.incoming:
//         return "incoming";
//       case CallType.outgoing:
//         return "outgoing";
//       case CallType.missed:
//         return "missed";
//       case CallType.rejected:
//         return "rejected";
//       case CallType.blocked:
//         return "blocked";
//       default:
//         return "unknown";
//     }
//   }

//   Future<void> _saveCallToFirestore(CallHistory call) async {
//     try {
//       await firestore.collection("CallHistory").add(call.toMap());
//       print("Call saved: ${call.contactID} at ${call.timeStamp}");
//     } catch (e) {
//       print("Error saving call: $e");
//     }
//   }
// }
