import 'package:flutter/material.dart';

class AppBarInfo {

  String title;

  AppBarInfo(String title) {
    this.title = title;
  }

  AppBar getAppBar() {
    return AppBar(
      title: Text(title),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.article_outlined,
            color: Colors.white,
          ),
          onPressed: () {

          },
        ),
        IconButton(
          icon: Icon(
            Icons.assignment_turned_in_outlined,
            color: Colors.white,
          ),
          onPressed: () {
          },
        ),
      ],
    );
  }
}
