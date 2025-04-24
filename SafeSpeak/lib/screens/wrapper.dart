import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login/screens/home.dart';
import 'package:login/screens/splash.dart';
import 'package:login/database_service.dart';
import 'package:login/model/usermodel.dart';
import 'package:login/model/keywordModel.dart';
import 'package:login/model/contactModel.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen(); // Initial loading state
          }

          if (snapshot.hasData) {
            User? user = snapshot.data;
            if (user == null) return const SplashScreen();

            return FutureBuilder<UserModel?>(
              future: DatabaseService().getUserData(user.uid),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const SplashScreen();
                }

                if (userSnapshot.hasData && userSnapshot.data != null) {
                  // Fetch the keywordData and contacts
                  return FutureBuilder<KeywordModel?>(
                    future: DatabaseService().getKeywordData(user.uid),
                    builder: (context, keywordSnapshot) {
                      if (keywordSnapshot.connectionState == ConnectionState.waiting) {
                        return const SplashScreen();
                      }

                      if (keywordSnapshot.hasData && keywordSnapshot.data != null) {
                        // Fetch the contacts based on the keyword data
                        return FutureBuilder<List<ContactModel>>(
                          future: DatabaseService().getContactList(
                            user.uid, 
                            keywordSnapshot.data?.keywordID ?? 'default_keyword',                          ),
                          builder: (context, contactsSnapshot) {
                            if (contactsSnapshot.connectionState == ConnectionState.waiting) {
                              return const SplashScreen();
                            }

                            if (contactsSnapshot.hasData && contactsSnapshot.data != null) {
                              return HomePage(
                                user: userSnapshot.data!,
                                keywordData: keywordSnapshot.data,
                                contacts: contactsSnapshot.data!,
                              );
                            } else {
                              return const SplashScreen();
                            }
                          },
                        );
                      } else {
                        return const SplashScreen();
                      }
                    },
                  );
                } else {
                  return const SplashScreen();
                }
              },
            );
          } else {
            return const SplashScreen();
          }
        },
      ),
    );
  }
}
