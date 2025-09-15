import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:podo_words/database/local_storage_service.dart';
import 'package:podo_words/database/database_service.dart';
import 'package:podo_words/common/my_colors.dart';
import 'package:podo_words/learning/controllers/audio_controller.dart';
import 'package:podo_words/user/user_controller.dart';
import 'package:podo_words/learning/models/word.dart';
import 'package:podo_words/learning/controllers/learning_controller.dart';
import 'package:podo_words/main_frame.dart';
import 'package:podo_words/user/user_model.dart';

import '../widgets/show_snack_bar.dart';

class LearningCompletePage extends StatelessWidget {
  final learningController = Get.find<LearningController>();
  final userController  = Get.find<UserController>();


  @override
  Widget build(BuildContext context) {
    AudioController().playYay();
    userController.updateStreak();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SafeArea(
          child: Container(
            color: MyColors().purpleLight,
            child: Center(
              child: FutureBuilder<int>(
                future: DatabaseService().getTotalWordCount(),
                builder: (context, snapshot) {

                  if(snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  int totalWords = snapshot.data ?? 1000;
                  bool isFirstLesson = LocalStorageService().myWords.isEmpty;
                  List<Word> learnedWords = learningController.words;
                  int countNewWords = LocalStorageService().addMyWords(learnedWords);
                  int myWords = LocalStorageService().myWords.length;
                  double percent = (myWords / totalWords).toDouble();

                  return Column(
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
                      Text('${learnedWords.length} words',
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
                  );
                }
              ),
            ),
          ),
        ),
      ),
    );
  }
}
