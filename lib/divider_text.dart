import 'package:flutter/material.dart';
import 'my_colors.dart';

class DividerText {

  Widget getDivider(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 50.0),
      child: Row(
        children: [
          Expanded(child: Divider(color: MyColors().navy)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Text(text, style: TextStyle(color: MyColors().navy),),
          ),
          Expanded(child: Divider(color: MyColors().navy))
        ],
      ),
    );
  }
}