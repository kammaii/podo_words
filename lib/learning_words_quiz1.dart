import 'dart:math';

import 'package:flutter/material.dart';
import 'package:podo_words/learning_words_bar.dart';
import 'package:podo_words/mix_index.dart';
import 'package:podo_words/my_colors.dart';
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
    mixedIndex = MixIndex().getMixedIndex(widget.wordList.length);

    return Scaffold(
      body: SafeArea(
        child: Container(
          color: MyColors().purpleLight,
          child: Column(
            children: [
              LearningWordsBar(),
              SizedBox(height: 20.0),
              IconButton(
                icon: Icon(Icons.multitrack_audio, color: MyColors().purple,),
                iconSize: 100.0,
                onPressed: () => print('play button pressed'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                child: Row(
                  children: [
                    Expanded(child: Divider(color: MyColors().navy)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Text('select correct word', style: TextStyle(color: MyColors().navy),),
                    ),
                    Expanded(child: Divider(color: MyColors().navy))
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: GridView.builder(
                    shrinkWrap: true,
                    itemCount: 4,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount (
                      crossAxisCount: 2,
                      childAspectRatio: 1,
                      crossAxisSpacing: 20.0,
                      mainAxisSpacing: 20.0,
                    ),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: InkWell(
                          onTap: (){},
                          child: Material(
                            elevation: 1.0,
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            child: Center(
                                child: Text(
                                  widget.wordList[mixedIndex[index]].back,
                                  textScaleFactor: 1.5,
                                )
                            ),
                          ),
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
