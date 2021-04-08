import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:podo_words/words.dart';

class LearningWords extends StatefulWidget {

  final int lessonIndex;

  LearningWords(this.lessonIndex);


  @override
  _LearningWordsState createState() => _LearningWordsState();
}

class _LearningWordsState extends State<LearningWords> {
  final List<bool> toggleList = List.generate(2, (_) => false);
  Words words;
  int wordIndex;

  @override
  Widget build(BuildContext context) {
    words = Words(widget.lessonIndex);
    wordIndex = 0;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SafeArea(
          child: GestureDetector(
            child: Column(
              children: [
                Row(
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
                ),
                Image.asset('images/sample.png'),
                Text(words.getFront()[wordIndex], textScaleFactor: 3,),
                Text(words.getPronunciation()[wordIndex], textScaleFactor: 2,),
                IconButton(
                  icon: Icon(Icons.play_circle_outline),
                  iconSize: 150.0,
                  onPressed: () => print('play button pressed'),
                )
              ],
            ),
            onPanUpdate: (detail) {
              if (detail.delta.dx > 0) {
                print('오른쪽 스와이프');
                if(wordIndex < words.getFront().length - 1) {
                  wordIndex++;
                } else {
                  //todo: 퀴즈로 이동
                }
              } else {
                print('왼쪽 스와이프');
                if(wordIndex > 0) {
                  wordIndex--;
                }
              }
              setState(() {
                //todo: 단어 변경
              });
            },
          ),
        ),
      ),
    );
  }
}
