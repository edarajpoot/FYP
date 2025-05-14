import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class FirebrigadeEmergency extends StatelessWidget {
  const FirebrigadeEmergency({super.key});

  _makeEmergencyCall(String number) async {
    await FlutterPhoneDirectCaller.callNumber(number);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, bottom: 5),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          onTap: () => _makeEmergencyCall("16"),
          child: Container(
            height: 180,
            width: MediaQuery.of(context).size.width * 0.7,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromRGBO(37, 66, 43, 1),
                  Color.fromRGBO(230, 240, 234, 1),
                ])
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Color.fromRGBO(230, 240, 234, 1),
                    radius: 20,
                    child: Icon(Icons.fire_extinguisher, color: Color.fromRGBO(37, 66, 43, 1),),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Fire Brigade",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width * 0.06,
                          fontWeight: FontWeight.bold,
                        ),),
              
                        Text("Call for Fire Emergencies",
                        style: TextStyle(
                          color: Colors.white70,
                          overflow: TextOverflow.ellipsis,
                          fontSize: MediaQuery.of(context).size.width * 0.045,
                        ),),
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              height: 30,
                              width: 80,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Text("1-6",
                                style: TextStyle(
                                  color: Color.fromRGBO(37, 66, 43, 1),
                                  fontSize: MediaQuery.of(context).size.width * 0.055,
                                  fontWeight: FontWeight.bold,
                                ),),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          
          ),
        ),
      ),
    );
  }
}