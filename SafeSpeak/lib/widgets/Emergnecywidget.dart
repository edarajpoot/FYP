import 'package:flutter/material.dart';
import 'package:login/widgets/Emergencies/AmbulanceEmergency.dart';
import 'package:login/widgets/Emergencies/FireBrigadeEmergency.dart';
import 'package:login/widgets/Emergencies/PoliceEmergency.dart';
import 'package:login/widgets/Emergencies/RescueEmergency.dart';

class Emergnecywidget extends StatelessWidget {
  const Emergnecywidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 180,
      child: ListView(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: [
          PoliceEmergency(),
          AmbulanceEmergency(),
          FirebrigadeEmergency(),
          RescueEmergency(),
        ],
      ),
    );
  }
}