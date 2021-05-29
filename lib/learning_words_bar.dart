import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:podo_words/my_colors.dart';

class LearningWordsBar extends StatefulWidget {
  @override
  _LearningWordsBarState createState() => _LearningWordsBarState();
}

class _LearningWordsBarState extends State<LearningWordsBar> {

  bool isEngOn = true; //todo: DB에서 가져오기

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        Expanded(
          child: LinearPercentIndicator(
            width: 180.0,
            lineHeight: 10.0,
            percent: 0.5,
            backgroundColor: Colors.grey,
            progressColor: Colors.blue,
          ),
        ),
        Text('Quiz'),
        SizedBox(width: 10.0,),
        Switch(
          value: isEngOn,
          activeTrackColor: MyColors().navyLight,
          activeColor: MyColors().purple,
          onChanged: (value) {
            setState(() {
              isEngOn = value;
              if(value) {
                //todo: 영어 켜기

              } else {
                //todo: 영어 끄기
              }
            });
          },
        )
      ],
    );
  }
}
