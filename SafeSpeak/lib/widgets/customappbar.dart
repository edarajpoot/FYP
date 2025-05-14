import 'package:flutter/material.dart';
import 'package:login/util/quotes.dart';

class CustomAppBar extends StatelessWidget {
  final Function? onTap;
  final int? quoteIndex;

  CustomAppBar({this.onTap, this.quoteIndex});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) { // Safely calling onTap if it's not null
          onTap!();
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(14.0), // Optional: Add some padding for the text
        child: Text(
          sweetSayings[quoteIndex ?? 0], // Default to 0 if quoteIndex is null
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color.fromRGBO(37, 66, 43, 0.8)),
        ),
      ),
    );
  }
}
