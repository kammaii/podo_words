import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:podo_words/data_storage.dart';
import 'package:podo_words/main_learning.dart';
import 'package:podo_words/my_colors.dart';
import 'package:podo_words/play_audio.dart';
import 'package:podo_words/word.dart';
import 'package:podo_words/words.dart';

class LearningWordsComplete extends StatelessWidget {

  int totalWords = 0;
  int myWords = 0;
  double percent = 0;
  List<Word> words;

  LearningWordsComplete(this.words);

  @override
  Widget build(BuildContext context) {
    totalWords = Words().getTotalWordsLength();
    DataStorage().addMyWords(words);
    myWords = DataStorage().myWords.length;
    percent = (myWords / totalWords).toDouble();
    //PlayAudio().playYay();


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
                  Text('Congratulations!', textScaleFactor: 2,
                    style: TextStyle(color: MyColors().purple, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: CircularPercentIndicator(
                      animation: true,
                      animationDuration: 1200,
                      circularStrokeCap: CircularStrokeCap.round,
                      radius: 200.0,
                      lineWidth: 10.0,
                      percent: percent,
                      center: Text('${(percent*100).toInt().toString()}%', textScaleFactor: 3,
                        style: TextStyle(color: MyColors().purple)),
                      progressColor: MyColors().purple,
                    ),
                  ),
                  Text('You have learned', textScaleFactor: 1.5,
                    style: TextStyle(color: MyColors().purple)),
                  SizedBox(height: 10.0),
                  Text('${words.length} words', textScaleFactor: 2,
                    style: TextStyle(color: MyColors().purple)),
                  SizedBox(height: 30.0),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: InkWell(
                      onTap: (){
                        DataStorage().addMyWords(words);
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => MainLearning()));
                      },
                      child: Material(
                        color: MyColors().purple,
                        borderRadius: BorderRadius.circular(30.0),
                        elevation: 5.0,
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Center(
                              child: Text('Go to main', textScaleFactor: 1.5,
                                style: TextStyle(color: Colors.white)
                              )
                          ),
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
