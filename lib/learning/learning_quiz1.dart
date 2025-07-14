import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_words/common/divider_text.dart';
import 'package:podo_words/common/list_mix.dart';
import 'package:podo_words/common/my_colors.dart';
import 'package:podo_words/common/play_audio.dart';
import 'package:podo_words/common/play_audio_button.dart';
import 'package:podo_words/common/word.dart';
import 'package:podo_words/common/words.dart';

import 'learning_quiz_frame.dart';

class LearningQuiz1 extends StatefulWidget {

  List<Word> wordList;
  int wordsNoForQuiz;
  LearningQuiz1(this.wordsNoForQuiz, this.wordList);

  @override
  _LearningQuiz1State createState() => _LearningQuiz1State();
}

class _LearningQuiz1State extends State<LearningQuiz1> {
  int quizIndex = 0;
  late String front;
  late String back;
  late String audio;
  late String image;
  List<int> mixedIndex = List<int>.generate(4, (index) => index);
  List<Color> borderColor = List<Color>.generate(4, (index) => Colors.white);
  bool isAnswerCheck = false;
  bool isCorrectAnswer = false;
  LearningQuizFrameState? learningQuizFrameState;


  void checkAnswer() {
    if(isAnswerCheck) {
      if(isCorrectAnswer) { // 정답
        PlayAudio().playCorrect();
        quizIndex++;

      } else {
        PlayAudio().playWrong();
      }

      Future.delayed(const Duration(seconds: 1), () {
        if(quizIndex < 4) {
          setState(() {
            isAnswerCheck = false;
            for (int i = 0; i < borderColor.length; i++) {
              borderColor[i] = Colors.white;
            }
          });

        } else {
          learningQuizFrameState!.setState(() {
            learningQuizFrameState!.quizNo = 1;
          });
        }
      });

    } else {
      print('정답 : $back');
      ListMix().getMixedList(mixedIndex);
    }
  }


  @override
  void initState() {
    super.initState();
    if(widget.wordsNoForQuiz != 4) {
      quizIndex = 4 - widget.wordsNoForQuiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    learningQuizFrameState = context.findAncestorStateOfType<LearningQuizFrameState>();

    front = widget.wordList[quizIndex].front;
    back = widget.wordList[quizIndex].back;
    audio = widget.wordList[quizIndex].audio;
    image = widget.wordList[quizIndex].image;
    PlayAudio().playWord(audio);

    checkAnswer();

    return Scaffold(
      body: SafeArea(
        child: Container(
          color: MyColors().purpleLight,
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              PlayAudioButton(audio),
              DividerText().getDivider('select correct word'),
              Expanded(
                child: Padding(
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
                        Image searchedImage = Image.asset(
                            'assets/images/words/${widget.wordList[mixedIndex[index]].image}',
                            errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                              return SizedBox(height: 0);
                            }
                        );

                        return Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: InkWell(
                            onTap: (){
                              if(!isAnswerCheck) {
                                setState(() {
                                  if (mixedIndex[index] == quizIndex) {
                                    isCorrectAnswer = true;
                                    borderColor[index] = MyColors().purple;
                                  } else {
                                    isCorrectAnswer = false;
                                    borderColor[index] = MyColors().red;
                                  }
                                  isAnswerCheck = true;
                                });
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20.0),
                                boxShadow: [BoxShadow(color: borderColor[index], spreadRadius: 1)]
                              ),
                              child: Center(
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: searchedImage,
                                        )
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Text(
                                          widget.wordList[mixedIndex[index]].back,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                              ),
                            ),
                          ),
                        );
                      }
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
