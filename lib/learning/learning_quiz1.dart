import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_words/common/divider_text.dart';
import 'package:podo_words/common/list_mix.dart';
import 'package:podo_words/common/my_colors.dart';
import 'package:podo_words/common/play_audio.dart';
import 'package:podo_words/common/play_audio_button.dart';
import 'package:podo_words/common/word.dart';
import 'package:podo_words/learning/learning_controller.dart';
import 'package:podo_words/learning/learning_quiz2.dart';

class LearningQuiz1 extends StatefulWidget {
  @override
  _LearningQuiz1State createState() => _LearningQuiz1State();
}

class _LearningQuiz1State extends State<LearningQuiz1> {
  int quizIndex = 0;
  late List<int> mixedIndex;
  late List<Color> borderColor;
  bool isCorrectAnswer = false;
  final controller = Get.find<LearningController>();
  late List<Word> words;

  @override
  void initState() {
    super.initState();
    words = controller.getQuizWords();
    mixedIndex = List<int>.generate(words.length, (index) => index);
    borderColor = List<Color>.generate(words.length, (index) => Colors.white);
    ListMix().getMixedList(mixedIndex);
    PlayAudio().playWord(words.first.audio);
  }

  void checkAnswer() {
    if (isCorrectAnswer) {
      // 정답
      PlayAudio().playCorrect();
      quizIndex++;
    } else {
      PlayAudio().playWrong();
    }

    Future.delayed(const Duration(seconds: 1), () {
      if (quizIndex < words.length) {
        // 다음 문제
        setState(() {
          for (int i = 0; i < borderColor.length; i++) {
            borderColor[i] = Colors.white;
          }
          ListMix().getMixedList(mixedIndex);
          PlayAudio().playWord(words[quizIndex].audio);
        });
      } else {
        controller.content.last = LearningQuiz2();
        controller.update();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: MyColors().purpleLight,
      child: Column(
        children: [
          PlayAudioButton(words[quizIndex].audio),
          DividerText().getDivider('select correct word'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: GridView.builder(
                  shrinkWrap: true,
                  itemCount: words.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                    crossAxisSpacing: 20.0,
                    mainAxisSpacing: 20.0,
                  ),
                  itemBuilder: (context, index) {
                    Image wordImage = Image.asset(
                      'assets/images/words/${words[mixedIndex[index]].image}',
                      errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                        return Image.asset('assets/images/words/transparent.png');
                      },
                    );

                    return Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            if (mixedIndex[index] == quizIndex) {
                              isCorrectAnswer = true;
                              borderColor[index] = MyColors().purple;
                            } else {
                              isCorrectAnswer = false;
                              borderColor[index] = MyColors().red;
                            }
                          });
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            checkAnswer();
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20.0),
                              boxShadow: [BoxShadow(color: borderColor[index], spreadRadius: 1)]),
                          child: Center(
                              child: Column(
                            children: [
                              Expanded(
                                  child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: wordImage,
                              )),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text(
                                  words[mixedIndex[index]].back,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ],
                          )),
                        ),
                      ),
                    );
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
