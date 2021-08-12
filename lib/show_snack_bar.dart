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
            msg,
            style: TextStyle(color: MyColors().red, fontWeight: FontWeight.bold, fontSize: 15.0),
          ),
        )
    );
  }
}