import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:login/model/contactModel.dart';
import 'package:login/model/keywordModel.dart';
import 'package:login/model/usermodel.dart';
import 'package:login/screens/HistoryScreen.dart';
import 'package:login/screens/home.dart';
import 'package:login/screens/newKeyword.dart';
import 'package:login/screens/settings.dart';

class MyNavigationBar extends StatelessWidget {
  final UserModel user;
  final List<KeywordModel> allKeywords;
  final List<ContactModel> contacts;

  const MyNavigationBar({
    Key? key,
    required this.user,
    required this.allKeywords,
    required this.contacts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController(
      user: user,
      allKeywords: allKeywords,
      contacts: contacts,
    ));

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: Obx(
  () => CurvedNavigationBar(
    index: controller.selectedIndex.value,
    height: 60.0,
    backgroundColor: Colors.transparent,
    color: Color.fromRGBO(230, 240, 234, 1),
    buttonBackgroundColor: Color.fromRGBO(37, 66, 43, 1),
    animationDuration: Duration(milliseconds: 400),
    onTap: (index) {
      controller.selectedIndex.value = index;
    },
    items: [
      Icon(
        Icons.home,
        size: 30,
        color: controller.selectedIndex.value == 0 ? Colors.white : const Color.fromRGBO(37, 66, 43, 1),
      ),
      Icon(
        Icons.search,
        size: 30,
        color: controller.selectedIndex.value == 1 ? Colors.white : const Color.fromRGBO(37, 66, 43, 1),
      ),
      Icon(
        Icons.history,
        size: 30,
        color: controller.selectedIndex.value == 2 ? Colors.white : const Color.fromRGBO(37, 66, 43, 1),
      ),
      Icon(
        Icons.settings,
        size: 30,
        color: controller.selectedIndex.value == 3 ? Colors.white : const Color.fromRGBO(37, 66, 43, 1),
      ),
    ],
  ),
),

      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;
  late final List<Widget> screens;

  NavigationController({
    required UserModel user,
    required List<KeywordModel> allKeywords,
    required List<ContactModel> contacts,
  }) {
    screens = [
      HomePage(user: user, allKeywords: allKeywords, contacts: contacts),
      AllKeywords(user: user),
      CallHistoryScreen(),
      ProfileScreen(user: user),
    ];
  }
}
