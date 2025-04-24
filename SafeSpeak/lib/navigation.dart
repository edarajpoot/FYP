import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/state_manager.dart';
import 'package:login/model/contactModel.dart';
import 'package:login/model/keywordModel.dart';
import 'package:login/model/usermodel.dart';
import 'package:login/screens/home.dart';
import 'package:login/screens/settings.dart';

class MyNavigationBar extends StatelessWidget {
  final UserModel user;
  final KeywordModel? keywordData;
  final List<ContactModel> contacts;
  const MyNavigationBar({
    Key? key, 
    required this.user,
    required this.keywordData,
    required this.contacts,
    }): super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController(
      user: user,
      keywordData: keywordData,
      contacts: contacts,
    ));
    return Scaffold(
      bottomNavigationBar: Obx(
        () => NavigationBar(
          height: 80,
          elevation: 0,
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (index) => controller.selectedIndex.value = index,
            destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            NavigationDestination(
              icon: Icon(Icons.history),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
      body: Obx(()=> controller.screens[controller.selectedIndex.value]),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;
  late final List<Widget> screens;

  NavigationController({
    required UserModel user,
    required KeywordModel? keywordData,
    required List<ContactModel> contacts,
  }) {
    screens = [
      HomePage(user: user, keywordData: keywordData, contacts: contacts),
      const Center(child: Text("Search")),
      const Center(child: Text("Notifications")),
      ProfileScreen(user: user,),
    ];
  }
}

