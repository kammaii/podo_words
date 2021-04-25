import 'package:flutter/material.dart';
import 'package:podo_words/my_colors.dart';

class WordListItem extends StatelessWidget {

  final String front;
  final String back;
  final String audio;
  final bool isActive;
  Color textColor;
  Color backColor;

  WordListItem(this.front, this.back, this.isActive, {this.audio});

  @override
  Widget build(BuildContext context) {

    if(isActive) {
      textColor = MyColors().purple;
      backColor = Colors.white;
    } else {
      textColor = MyColors().navyLight;
      backColor = MyColors().navyLightLight;
    }

    return Card(
      color: backColor,
      child: InkWell(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(front, style: TextStyle(color: textColor, fontSize: 20.0),),
              VerticalDivider(color: MyColors().navyLight, thickness: 2.0,),
              Text(back, style: TextStyle(color: textColor, fontSize: 20.0),)
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
