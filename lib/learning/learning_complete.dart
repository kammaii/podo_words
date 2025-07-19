import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:podo_words/common/data_storage.dart';
import 'package:podo_words/learning/learning_controller.dart';
import 'package:podo_words/main_frame.dart';
import 'package:podo_words/common/my_colors.dart';
import 'package:podo_words/common/play_audio.dart';
import 'package:podo_words/common/show_snack_bar.dart';
import 'package:podo_words/common/word.dart';
import 'package:podo_words/common/words.dart';
import 'package:in_app_review/in_app_review.dart';

class LearningComplete extends StatelessWidget {
  late int totalWords;
  late int myWords;
  late double percent;
  late int countNewWords;

  final controller = Get.find<LearningController>();

  @override
  Widget build(BuildContext context) {
    final words = List<Word>.from(controller.words)..removeLast(); // Last Word 카드 제거
    totalWords = Words().getTotalWordsLength();
    bool isFirstLesson = DataStorage().myWords.isEmpty;
    countNewWords = DataStorage().addMyWords(words);
    myWords = DataStorage().myWords.length;
    percent = (myWords / totalWords).toDouble();
    PlayAudio().playYay();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SafeArea(
          child: Container(
            color: MyColors().purpleLight,
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: 20.0),
                  Text('Congratulations!',
                      style: TextStyle(fontSize: 30, color: MyColors().purple, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularPercentIndicator(
                          animation: true,
                          animationDuration: 1200,
                          circularStrokeCap: CircularStrokeCap.round,
                          radius: 150.0,
                          lineWidth: 10.0,
                          percent: percent,
                          center: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('${(percent * 100).toInt().toString()}%',
                                  style: TextStyle(color: MyColors().purple, fontSize: 40)),
                              Text('($myWords / $totalWords)', style: TextStyle(color: MyColors().purple)),
                            ],
                          ),
                          progressColor: MyColors().purple,
                        ),
                        Image.asset('assets/images/confetti.png')
                      ],
                    ),
                  ),
                  Text('You have learned', style: TextStyle(color: MyColors().purple, fontSize: 20)),
                  SizedBox(height: 10.0),
                  Text('${words.length} words',
                      style: TextStyle(color: MyColors().purple, fontWeight: FontWeight.bold, fontSize: 30)),
                  SizedBox(height: 30.0),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: InkWell(
                      onTap: () {
                        print('바이)');
                        ShowSnackBar()
                            .getSnackBar(context, '$countNewWords new words are added on your review page');
                        Get.offAll(() => MainFrame(), arguments: isFirstLesson);
                      },
                      child: Material(
                        color: MyColors().purple,
                        borderRadius: BorderRadius.circular(30.0),
                        elevation: 5.0,
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Center(
                              child:
                                  Text('Go to main', style: TextStyle(color: Colors.white, fontSize: 20))),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
