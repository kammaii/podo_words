import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class LearningWordsBar extends StatefulWidget {
  @override
  _LearningWordsBarState createState() => _LearningWordsBarState();
}

class _LearningWordsBarState extends State<LearningWordsBar> {

  final List<bool> toggleList = List.generate(2, (_) => false);

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
        Text('Eng'),
        SizedBox(width: 10.0,),
        ToggleButtons(
          children: [
            Text('ON'),
            Text('OFF'),
          ],
          onPressed: (int index) {
            setState(() {
              for (int i=0; i<toggleList.length; i++) {
                if (i == index) {
                  toggleList[i] = true;
                } else {
                  toggleList[i] = false;
                }
              }
              switch (index) {
                case 0 :
                //todo: on 클릭
                  break;

                case 1 :
                //todo: off 클릭
                  break;
              }
            });
          },
          isSelected: toggleList,
          color: Colors.grey,
          selectedColor: Colors.purple,
        )
      ],
    );
  }
}
