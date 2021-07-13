import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'my_colors.dart';

class ShowSnackBar {

  getSnackBar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: MyColors().pink,
          content: Text(
            'It needs more than 4 words to start learning.',
            style: TextStyle(color: MyColors().red, fontWeight: FontWeight.bold, fontSize: 18.0),
          ),
        )
    );
  }
}