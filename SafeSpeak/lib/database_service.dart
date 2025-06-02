import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login/model/callHistoryModel.dart';
import 'package:login/model/contactModel.dart';
import 'package:login/model/keywordModel.dart';
import 'package:login/model/usermodel.dart';
import 'package:login/screens/Recordedvoice.dart';
import 'package:login/screens/signup.dart';

class DatabaseService {
  final FirebaseFirestore _fire = FirebaseFirestore.instance;

//   Future<String> copyAssetToFile(String assetPath) async {
//    try {
//     final directory = await getApplicationDocumentsDirectory();
//     final filePath = '${directory.path}/${assetPath.split('/').last}';
    
//     ByteData byteData = await rootBundle.load(assetPath); // Correct path
//     final buffer = byteData.buffer.asUint8List();
//     final file = File(filePath);
//     await file.writeAsBytes(buffer);

//     return filePath;  // Return the local file path where the asset was copied
//   } catch (e) {
//     print("Error copying asset to file: $e");
//     return ''; // Return empty string if error occurs
//   }
// }


//   // Save recording path to Firestore
// Future<void> saveRecordingToFirestore(String assetPath) async {
//   try {
//     String localPath = await copyAssetToFile(assetPath);

//     if (localPath.isNotEmpty) {
//       // Add document to Firestore with local file path
//       await _fire.collection("Recordings").add({
//         "fileName": "myRecording.mp3",
//         "duration": 120,
//         "localPath": localPath,  // Store local path in Firestore
//       });
//       print("Recording saved to Firestore with local path.");
//     } else {
//       print("Error: Could not copy file.");
//     }
//   } catch (e) {
//     print("Error saving recording to Firestore: $e");
//   }
// }

  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _fire.collection('USERS').doc(user.id).update({
        'name': user.name,
        'email': user.email,
        'phoneNo': user.phoneNo,
        'password':user.password,
        // Add any other fields you want to update
      });
    } catch (e) {
      print("Error updating user profile: $e");
      rethrow; // Optionally rethrow or handle the error in a way that suits your app
    }
  }


  // 🔹 Create User
  Future<void> createUser(USER user, String userId) async {
    try {
      await _fire.collection("USERS").doc(userId).set(user.toMap()); 
      print("User created successfully!");
    } catch (e) {
      print("Error saving user: $e");
    }
  }

  Future<void> updateEmergencyMode(String userId, bool mode) async {
  await FirebaseFirestore.instance.collection('USERS').doc(userId).update({
    'emergencyMode': mode,
  });
}


  Future<UserModel?> getUserData(String userId) async {
  try {
    DocumentSnapshot doc = await _fire.collection("USERS").doc(userId).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    }
  } catch (e) {
    print("Error fetching user data: $e");
  }
  return null;
}

// Define the method to get all keywords for a user
  Future<List<KeywordModel>> getAllKeywords(String userId) async {
    try {
      // Fetch all documents from the "keywords" collection for the given user
      QuerySnapshot querySnapshot = await _fire
          .collection('EmergencyAlertKeyword')  // Adjust the collection name if needed
          .where('userID', isEqualTo: userId) // Assuming the keywords are stored with the userId
          .get();

      // Map the query result to KeywordModel objects
      List<KeywordModel> keywordList = querySnapshot.docs.map((doc) {
        return KeywordModel.fromFirestore(doc); // Assuming you have a fromFirestore method in your KeywordModel
      }).toList();

      return keywordList;
    } catch (e) {
      print('Error fetching keywords: $e');
      return []; // Return an empty list if something goes wrong
    }
  }

Future<KeywordModel?> getKeywordData(String userId) async {
  // Fetch the document
  var snapshot = await FirebaseFirestore.instance
      .collection('EmergencyAlertKeyword') // Your Firestore collection
      .where('userID', isEqualTo: userId) // Use the correct case ('UserID')
      .get();

      print("Fetched documents count: ${snapshot.docs.length}");

  // Check if the document exists
   if (snapshot.docs.isNotEmpty) {
    var data = snapshot.docs.first.data();
    print("Fetched Keyword Data: $data"); // Print the fetched data
    return KeywordModel.fromMap(snapshot.docs.first.id, data);
  }

  // No matching document found
  print("No keyword data found for userID: $userId");
  return null;
}





Future<List<ContactModel>> getContactList(String userId, String keywordId) async {
  try {
    print("Fetching contacts for userId: $userId and keywordId: $keywordId");

    var snapshot = await FirebaseFirestore.instance
        .collection('EmergencyContacts')
        .where('userID', isEqualTo: userId)
        .where('keywordID', isEqualTo: keywordId)
        .get();

    // Debug: Print the number of documents returned
    print("Fetched ${snapshot.docs.length} contacts.");

    return snapshot.docs.map((doc) {
      return ContactModel.fromMap(doc.id, doc.data());
    }).toList();
  } catch (e) {
    print("Error fetching contact list: $e");
    return [];
  }
}




  // 🔹 Create Keyword
  Future<void> createKeyword(KeywordModel keyword, String userId) async {
    try {
      DocumentReference docRef = await _fire.collection("EmergencyAlertKeyword").add(keyword.toMap());
      print("Keyword created with ID: ${docRef.id}");
    } catch (e) {
      print("Error saving keyword: $e");
    }
  }

  // 🔹 Create Emergency Contact
  // Future<void> createContact(EmergencyContact contact) async {
  //   try {
  //     DocumentReference docRef = await _fire.collection("EmergencyContacts").add(contact.toMap());
  //     print("Contact added with ID: ${docRef.id}");
  //   } catch (e) {
  //     print("Error saving contact: $e");
  //   }
  // }

  // 🔹 Log Call History
  Future<void> logCall(CallHistory call) async {
    try {
      DocumentReference docRef = await _fire.collection("CallHistory").add(call.toMap());
      print("Call logged with ID: ${docRef.id}");
    } catch (e) {
      print("Error saving call history: $e");
    }
  }

  // 🔹 Save Recorded Voice
  Future<void> saveRecordedVoice(RecordedVoice voice) async {
    try {
      await _fire.collection("RecordedVoices").add(voice.toMap());
      print("Recorded voice saved successfully!");
    } catch (e) {
      print("Error saving recorded voice: $e");
    }
  }

  // 🔹 Get Recorded Voice for a Specific User
  Future<List<RecordedVoice>> getRecordedVoices(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _fire
          .collection("RecordedVoices")
          .where("userId", isEqualTo: userId)
          .get();

      return querySnapshot.docs.map((doc) {
        return RecordedVoice.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print("Error fetching recorded voices: $e");
      return [];
    }
  }
}
