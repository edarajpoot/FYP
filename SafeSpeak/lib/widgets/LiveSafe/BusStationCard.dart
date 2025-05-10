import 'package:flutter/material.dart';

class Busstationcard extends StatelessWidget {
  final Function? onMapFunction;
  const Busstationcard({super.key,this.onMapFunction,});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Column(
        children: [
          InkWell(
            onTap: () => {
              onMapFunction!('bus stops near me')
            },
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(230, 240, 234, 1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.directions_bus, size: 45, color: Color.fromRGBO(37, 66, 43, 1),),
                      SizedBox(height: 10),
                      Text(
                        'Bus Stops',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
