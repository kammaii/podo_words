import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:podo_words/common/divider_text.dart';
import 'package:podo_words/common/list_mix.dart';
import 'package:podo_words/common/my_colors.dart';
import 'package:podo_words/common/play_audio.dart';
import 'package:podo_words/common/word.dart';
import 'package:podo_words/learning/learning_controller.dart';
import 'package:podo_words/learning/learning_quiz3.dart';

class LearningQuiz2 extends StatefulWidget {
  @override
  _LearningQuiz2State createState() => _LearningQuiz2State();
}

class _LearningQuiz2State extends State<LearningQuiz2> {
  List<String> wordsFront = [];
  List<String> wordsBack = [];
  List<String> wordsAudio = [];
  late List<int> mixedIndexFront;
  late List<int> mixedIndexBack;
  List<int> checkedIndex = [4, 4];
  List<int> answeredIndex = [];
  final controller = Get.find<LearningController>();
  StreamSubscription<PlayerState>? _subscription;

  @override
  void initState() {
    super.initState();
    for (Word word in controller.getQuizWords()) {
      wordsFront.add(word.front);
      wordsBack.add(word.back);
      wordsAudio.add(word.audio);
    }
    final length = wordsFront.length;
    mixedIndexFront = List<int>.generate(length, (index) => index);
    mixedIndexBack = List<int>.generate(length, (index) => index);
    ListMix().getMixedList(mixedIndexFront);
    ListMix().getMixedList(mixedIndexBack);
  }

  Widget wordsItem({required bool isFront}) {
    List<String> words;
    List<int> mixedIndex;

    if (isFront) {
      words = wordsFront;
      mixedIndex = mixedIndexFront;
    } else {
      words = wordsBack;
      mixedIndex = mixedIndexBack;
    }

    return GridView.builder(
        shrinkWrap: true,
        itemCount: words.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        itemBuilder: (context, index) {
          Color borderColor = Colors.white;
          Color backgroundColor = Colors.white;

          if (isFront) {
            if (index == checkedIndex[0]) {
              borderColor = MyColors().purple;
            }
          } else {
            if (index == checkedIndex[1]) {
              borderColor = MyColors().purple;
            }
          }

          if (answeredIndex.contains(mixedIndex[index])) {
            backgroundColor = MyColors().purpleLight;
            return Center(
              child: Text(words[mixedIndex[index]],
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, decoration: TextDecoration.lineThrough)),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.all(1.0),
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (isFront) {
                      checkedIndex[0] = index;
                    } else {
                      checkedIndex[1] = index;
                    }

                    if (checkedIndex[0] != 4 && checkedIndex[1] != 4) {
                      if (mixedIndexFront[checkedIndex[0]] == mixedIndexBack[checkedIndex[1]]) {
                        // 정답
                        print('정답');
                        PlayAudio().playWord(wordsAudio[mixedIndexFront[checkedIndex[0]]]);
                        answeredIndex.add(mixedIndexFront[checkedIndex[0]]);
                      } else {
                        print('오답');
                        PlayAudio().playWrong();
                      }

                      checkedIndex = [4, 4];

                      // 모든 정답 맞춤
                      if (answeredIndex.length == words.length) {
                        _subscription = PlayAudio().player.playerStateStream.listen((event) {
                          if (event.processingState == ProcessingState.completed) {
                            _subscription?.cancel();
                            controller.content.last = LearningQuiz3();
                            controller.update();
                          }
                        });
                      }
                    }
                  });
                },
                child: Container(
                    decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [BoxShadow(color: borderColor, spreadRadius: 1)]),
                    child: Center(
                      child: Text(
                        words[mixedIndex[index]],
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20),
                      ),
                    )),
              ),
            );
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: MyColors().purpleLight,
      child: Column(
        children: [
          Expanded(
            child: Container(alignment: Alignment.bottomCenter, child: wordsItem(isFront: true)),
          ),
          DividerText().getDivider('match correct words'),
          Expanded(child: wordsItem(isFront: false)),
        ],
      ),
    );
  }
}
