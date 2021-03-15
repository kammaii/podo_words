import 'package:flutter/material.dart';

class AppBarInfo extends StatelessWidget {

  AppBarInfo();
  
  @override
  Widget build(BuildContext context) {
    return AppBar(title:
    Text('podo_words'),
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
