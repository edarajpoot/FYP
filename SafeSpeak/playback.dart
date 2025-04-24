// import 'package:http/http.dart' as http;
// import 'package:file_picker/file_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'dart:convert';

// Future<void> uploadMP3AndTriggerCall() async {
//   // Step 1: Pick MP3 file from device
//   FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['mp3']);
//   if (result != null) {
//     final fileBytes = result.files.first.bytes;
//     final fileName = result.files.first.name;

//     // Step 2: Upload to Firebase Storage
//     final ref = FirebaseStorage.instance.ref().child('audio/$fileName');
//     await ref.putData(fileBytes!);

//     // Step 3: Get the download URL for public access
//     String downloadURL = await ref.getDownloadURL();
//     print('MP3 uploaded! Download URL: $downloadURL');

//     // Step 4: Trigger Twilio call with the MP3 file URL
//     final twilioUrl = Uri.parse('https://api.twilio.com/2010-04-01/Accounts/YOUR_ACCOUNT_SID/Calls.json');
//     final response = await http.post(
//       twilioUrl,
//       headers: {
//         'Authorization': 'Basic ' + base64Encode(utf8.encode('YOUR_ACCOUNT_SID:YOUR_AUTH_TOKEN')),
//         'Content-Type': 'application/x-www-form-urlencoded',
//       },
//       body: {
//         'To': '+92xxxxxxxxxx',  // Receiver's phone number
//         'From': '+1YourTwilioNumber',  // Your Twilio phone number
//         'Url': 'https://yourfirebaseapp.com/twiml.xml',  // TwiML file URL
//       },
//     );

//     if (response.statusCode == 201) {
//       print('Call triggered successfully!');
//     } else {
//       print('Failed to trigger call: ${response.body}');
//     }
//   } else {
//     print('No file selected');
//   }
// }
