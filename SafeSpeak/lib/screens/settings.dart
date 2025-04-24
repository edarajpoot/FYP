import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:login/database_service.dart';
import 'package:login/model/usermodel.dart';
import 'package:login/screens/backgroungServices.dart';
import 'package:login/screens/login.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel user;
  const ProfileScreen({
    Key? key, 
    required this.user,
  }): super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEmergencyMode = true;

  Future<void> signout() async {
    await FirebaseAuth.instance.signOut();
    FlutterBackgroundService().invoke('stopService');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LogInScreen()),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 25.0),
          child: Text(
            "Setting",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(37, 66, 43, 1),
              fontSize: 25,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: Row(
                  children: [
                    SizedBox(width: 16),
                    Container(
                      height: 100,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 22),
                          Text(
                            widget.user.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(37, 66, 43, 1),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            widget.user.email,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color.fromRGBO(37, 66, 43, 1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            // Account Settings List
            Expanded(
              child: ListView(
                children: [
                  _buildSettingItem(
                    title: "Edit",
                    onTap: () {
                      // Handle Edit
                    },
                  ),
                  _buildSettingToggle(
                    title: "Emergency Mode",
                    value: _isEmergencyMode,
                    onChanged: (value) async {
                      setState(() {
                        _isEmergencyMode = value;
                      });

                      if (!value) {
                        FlutterBackgroundService().invoke('stopService');
                      } else {
                        final keyword = await DatabaseService().getKeywordData(widget.user.id);
                      if (keyword != null) {
                        final contacts = await DatabaseService().getContactList(widget.user.id, keyword.keywordID!);
                        await initializeService(contacts, keyword); // Starts service (or resumes)
  
                        // Explicitly re-invoke start-listening to pass new data
                        List<Map<String, dynamic>> contactMaps = contacts.map((e) => e.toJson()).toList();
                        FlutterBackgroundService().invoke('start-listening', {
                          'contacts': contactMaps,
                          'keywordText': keyword.voiceText,
                      });

                    } else {
                        print("⚠️ No keyword set for this user.");
                      }
                    }
                  }

                  )
                ],
              ),
            ),
            // Log Out Button
            ElevatedButton(
              onPressed: () {
                signout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(37, 66, 43, 1), 
                foregroundColor: Colors.white,                
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text(
                "Log Out",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({required String title, required VoidCallback onTap}) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(fontSize: 16, color: Color.fromRGBO(37, 66, 43, 1)),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 18, color: Color.fromRGBO(37, 66, 43, 1)),
      onTap: onTap,
    );
  }

  Widget _buildSettingToggle({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(fontSize: 16, color: Color.fromRGBO(37, 66, 43, 1)),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Color.fromRGBO(37, 66, 43, 1),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ProfileScreen(user: UserModel(id: "Id", name: "areeba", email: "email", phoneNo: "phoneNo", emergencyMode: false),),
  ));
}
