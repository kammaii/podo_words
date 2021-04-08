import 'package:flutter/material.dart';

class WordListItem extends StatelessWidget {

  final String front;
  final String back;
  final String audio;

  WordListItem(this.front, this.back, {this.audio});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
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
        onTap: (){
          //todo: 오디오 플레이
          print('audio play');
        },
      ),
    );
  }
}
