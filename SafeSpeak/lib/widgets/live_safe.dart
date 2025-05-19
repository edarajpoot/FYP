import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:login/widgets/LiveSafe/BusStationCard.dart';
import 'package:login/widgets/LiveSafe/GasStation.dart';
import 'package:login/widgets/LiveSafe/HospitalCard.dart';
import 'package:login/widgets/LiveSafe/PharmacyCard.dart';
import 'package:login/widgets/LiveSafe/PoliceStationCard.dart';
import 'package:url_launcher/url_launcher.dart';

class LiveSafe extends StatelessWidget {
  const LiveSafe({super.key});

  static Future<void> openMap(String location) async {
    String googleURL = 'https://www.google.ca/maps/search/$location';
    final Uri _url = Uri.parse(googleURL);
    try{
      await launchUrl(_url);
    } catch(e) {
      Fluttertoast.showToast(msg: "Something went wrong!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      width: MediaQuery.of(context).size.width,
      child: ListView(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: [
          Policestationcard(onMapFunction: openMap),
          Hospitalcard(onMapFunction: openMap),
          Pharmacycard(onMapFunction: openMap),
          Busstationcard(onMapFunction: openMap),
          Gasstationcard(onMapFunction: openMap),
        ],
      ),
    );
  }
}