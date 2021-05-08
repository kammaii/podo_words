import 'dart:math';

import 'package:flutter/material.dart';
import 'package:podo_words/learning_words_bar.dart';
import 'package:podo_words/word.dart';

class LearningWordsQuiz1 extends StatefulWidget {

  List<Word> wordList;
  LearningWordsQuiz1(this.wordList);

  @override
  _LearningWordsQuiz1State createState() => _LearningWordsQuiz1State();
}

class _LearningWordsQuiz1State extends State<LearningWordsQuiz1> {
  int wordIndex = 0;
  String front;
  String back;
  List<int> mixedIndex;

  @override
  Widget build(BuildContext context) {
    front = widget.wordList[wordIndex].front;
    back = widget.wordList[wordIndex].back;
    mixedIndex = MixedIndex();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SafeArea(
          child: Column(
            children: [
              LearningWordsBar(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    front,
                    textScaleFactor: 5,
                  ),
                  IconButton(
                    icon: Icon(Icons.play_circle_outline),
                    iconSize: 80.0,
                    onPressed: () => print('play button pressed'),
                  ),
                ]
                ),
              Divider(
                color: Colors.black,
              ),
              Expanded(
                child: GridView.builder(
                    shrinkWrap: true,
                    itemCount: 4,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount (
                      crossAxisCount: 2,
                      childAspectRatio: 1,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                    ),
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: (){},
                        child: Container(
                          color: Colors.yellow,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: FlutterLogo(),
                              ),
                              Text('word'),
                            ],
                          ) ,
                        ),
                      );
                    }
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

List<int> MixedIndex() {
  //todo: 0~3까지 숫자 리스트 섞는 함수
  int randomNumber = Random().nextInt(4) - 1;
  List<int> newIndex;
  return newIndex;
}
