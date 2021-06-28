import 'package:flutter/material.dart';
import 'package:podo_words/divider_text.dart';
import 'package:podo_words/learning_words_quiz2.dart';
import 'package:podo_words/learning_words_quiz_frame.dart';
import 'package:podo_words/list_mix.dart';
import 'package:podo_words/my_colors.dart';
import 'package:podo_words/play_audio.dart';
import 'package:podo_words/play_audio_button.dart';
import 'package:podo_words/word.dart';
import 'package:podo_words/words.dart';

class LearningWordsQuiz1 extends StatefulWidget {

  List<Word> wordList;
  int wordsNoForQuiz;
  LearningWordsQuiz1(this.wordsNoForQuiz, this.wordList);

  @override
  _LearningWordsQuiz1State createState() => _LearningWordsQuiz1State();
}

class _LearningWordsQuiz1State extends State<LearningWordsQuiz1> {
  int quizIndex = 0;
  late String front;
  late String back;
  late String audio;
  List<int> mixedIndex = List<int>.generate(4, (index) => index);
  List<Color> borderColor = List<Color>.generate(4, (index) => Colors.white);
  bool isAnswerCheck = false;
  bool isCorrectAnswer = false;
  LearningWordsQuizFrameState? learningWordsQuizFrameState;


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
          learningWordsQuizFrameState!.setState(() {
            learningWordsQuizFrameState!.quizNo = 1;
          });
          //Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LearningWordsQuiz2(widget.wordList)));
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
    learningWordsQuizFrameState = context.findAncestorStateOfType<LearningWordsQuizFrameState>();
    print('러닝 : $learningWordsQuizFrameState');

    front = widget.wordList[quizIndex].front;
    back = widget.wordList[quizIndex].back;
    audio = widget.wordList[quizIndex].audio;
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
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              PlayAudioButton(audio),
              DividerText().getDivider('select correct word'),
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
                              boxShadow: [BoxShadow(color: borderColor[index], spreadRadius: 0.1)]
                            ),
                            child: Center(
                                child: Text(
                                  widget.wordList[mixedIndex[index]].back,
                                  textScaleFactor: 1.5,
                                  textAlign: TextAlign.center,
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
