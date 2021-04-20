import 'package:flutter/material.dart';

class WordListItem extends StatelessWidget {

  final String front;
  final String back;
  final String audio;
  final bool isActive;
  Color setColor;

  WordListItem(this.front, this.back, this.isActive, {this.audio});

  @override
  Widget build(BuildContext context) {

    if(isActive) {
      setColor = Colors.black;
    } else {
      setColor = Colors.grey;
    }

    return Card(
      child: InkWell(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(front, style: TextStyle(color: setColor),),
              Text(back, style: TextStyle(color: setColor),)
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
