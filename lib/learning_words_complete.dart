import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:podo_words/data_storage.dart';
import 'package:podo_words/main_frame.dart';
import 'package:podo_words/my_colors.dart';
import 'package:podo_words/play_audio.dart';
import 'package:podo_words/word.dart';
import 'package:podo_words/words.dart';

class LearningWordsComplete extends StatelessWidget {

  late int totalWords;
  late int myWords;
  late double percent;
  List<Word> words;
  late int countNewWords;

  LearningWordsComplete(this.words);

  @override
  Widget build(BuildContext context) {
    totalWords = Words().getTotalWordsLength();
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
                      center: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('${(percent*100).toInt().toString()}%', textScaleFactor: 3,
                            style: TextStyle(color: MyColors().purple)),
                          Text('($myWords / $totalWords)',
                              style: TextStyle(color: MyColors().purple)),
                        ],
                      ),
                      progressColor: MyColors().purple,
                    ),
                  ),
                  Text('You have learned', textScaleFactor: 1.5,
                    style: TextStyle(color: MyColors().purple)),
                  SizedBox(height: 10.0),
                  Text('${words.length} words', textScaleFactor: 2,
                    style: TextStyle(color: MyColors().purple, fontWeight: FontWeight.bold)),
                  SizedBox(height: 30.0),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: InkWell(
                      onTap: (){
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: MyColors().pink,
                              content: Text(
                                '$countNewWords new words are added on your review page',
                                style: TextStyle(color: MyColors().red, fontSize: 15.0),
                                textAlign: TextAlign.center,
                              ),
                            )
                        );
                        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => MainFrame()), (Route<dynamic> route) => false);
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
