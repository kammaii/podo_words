import 'package:flutter/material.dart';

class WordListItem extends StatelessWidget {

  String front;
  String back;

  WordListItem(this.front, this.back);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(front),
          Text(back)
        ]
      ),
    );
  }
}
