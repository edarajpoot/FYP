import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login/model/contactModel.dart';
import 'package:login/model/keywordModel.dart';
import 'package:login/model/usermodel.dart';
import 'package:login/screens/Recordedvoice.dart';
import 'package:login/screens/history.dart';
import 'package:login/screens/signup.dart';

class DatabaseService {
  final FirebaseFirestore _fire = FirebaseFirestore.instance;

  // 🔹 Create User
  Future<void> createUser(USER user, String userId) async {
    try {
      await _fire.collection("USERS").doc(userId).set(user.toMap()); 
      print("User created successfully!");
    } catch (e) {
      print("Error saving user: $e");
    }
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
  Future<void> logCall(MessageHistory call) async {
    try {
      DocumentReference docRef = await _fire.collection("MessageHistory").add(call.toMap());
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
