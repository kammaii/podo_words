import 'package:flutter/material.dart';

class WordListItem extends StatelessWidget {

  final String front;
  final String back;

  WordListItem(this.front, this.back);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(front),
            Text(back)
          ]
        ),
      ),
    );
  }
}
