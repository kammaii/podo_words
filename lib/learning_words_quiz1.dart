import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:podo_words/learning_words_bar.dart';
import 'package:podo_words/learning_words_quiz2.dart';
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
  String front = "";
  String back = "";
  List<int> mixedIndex = [];
  List<Color> borderColor = List<Color>.generate(4, (index) => Colors.white);
  bool isAnswerCheck = false;
  bool isCorrectAnswer = false;
  AudioPlayer player = AudioPlayer();


  @override
  void dispose() {
    super.dispose();
    player.dispose();
  }

  void checkAnswer() async {
    if(isAnswerCheck) {
      if(isCorrectAnswer) { // 정답
        // todo: 정답오디오 재생
        await player.setAsset('assets/audio/correct.mp3');
        wordIndex++;

      } else {
        // todo: 오답오디오 재생
        await player.setAsset('assets/audio/wrong.mp3');
      }
      player.play();


      Future.delayed(const Duration(seconds: 1), () {
        if(wordIndex < 4) {
          setState(() {
            isAnswerCheck = false;
            for (int i = 0; i < borderColor.length; i++) {
              borderColor[i] = Colors.white;
            }
          });
        } else {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LearningWordsQuiz2()));
        }
      });

    } else {
      print('정답 : $back');
      mixedIndex = MixIndex().getMixedIndex(4);
    }
  }


  @override
  Widget build(BuildContext context) {
    front = widget.wordList[wordIndex].front;
    back = widget.wordList[wordIndex].back;

    checkAnswer();

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
                          onTap: (){
                            // todo: 정답 확인 -> border color 표시 -> 맞으면 다음문제 -> 틀리면 다시
                            setState(() {
                              if(mixedIndex[index] == wordIndex) {
                                isCorrectAnswer = true;
                                borderColor[index] = MyColors().purple;
                              } else {
                                isCorrectAnswer = false;
                                borderColor[index] = MyColors().red;
                              }
                              isAnswerCheck = true;
                            });
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
