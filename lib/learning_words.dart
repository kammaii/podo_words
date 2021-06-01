import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:podo_words/learning_words_complete.dart';
import 'package:podo_words/learning_words_quiz1.dart';
import 'package:podo_words/my_colors.dart';
import 'package:podo_words/word.dart';
import 'learning_words_quiz3.dart';

class LearningWords extends StatefulWidget {

  List<Word> words;

  LearningWords(this.words);


  @override
  _LearningWordsState createState() => _LearningWordsState();
}

class _LearningWordsState extends State<LearningWords> {
  List<Word> words = [];
  int wordIndex = 0;
  String front = "";
  String back = "";
  String pronunciation = "";
  bool isQuizOn = true;

  Widget wordCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30.0),
      child: Material(
        elevation: 1,
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                front,
                textScaleFactor: 3,
                style: TextStyle(
                  fontWeight: FontWeight.bold
                ),
              ),
              SizedBox(height: 20.0),
              Text(
                pronunciation,
                textScaleFactor: 2,
              ),
              SizedBox(height: 30.0),
              Text(
                back,
                textScaleFactor: 2,
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    words = widget.words;
    if(wordIndex < words.length) {
      front = words[wordIndex].front;
      back = words[wordIndex].back;
      pronunciation = words[wordIndex].pronunciation;
    } else {
      front = '';
      back = '';
      pronunciation = '';
    }


    return Scaffold(
      body: SafeArea(
        child: Container(
          color: MyColors().purpleLight,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: LinearPercentIndicator(
                      animateFromLastPercent: true,
                      animation: true,
                      leading: IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      lineHeight: 8.0,
                      percent: wordIndex / words.length,
                      backgroundColor: MyColors().navyLight,
                      progressColor: MyColors().purple,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text('(${wordIndex + 1} / ${words.length})'),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Quiz'),
                  Switch(
                    value: isQuizOn,
                    activeTrackColor: MyColors().navyLight,
                    activeColor: MyColors().purple,
                    onChanged: (value) {
                      setState(() {
                        isQuizOn = value;
                      });
                    },
                  ),
                ],
              ),
              Expanded(
                child: Swiper(
                  itemBuilder: (context, index) {
                    return wordCard();
                  },
                  loop: false,
                  itemCount: words.length + 1,
                  viewportFraction: 0.7,
                  scale: 0.7,
                  onIndexChanged: (index) {
                    setState(() {
                      wordIndex = index;
                      //todo: index가 4의 배수이거나 마지막 index일 때 퀴즈1으로 이동
                      //todo : 마지막 index일 때는 isLastQuiz = true 추가
                      if(index >= words.length) {
                        if(isQuizOn) {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => LearningWordsQuiz3(words)));
                        } else {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LearningWordsComplete(words)));
                        }

                      } else if(isQuizOn && index != 0 && index % 4 == 0) {
                        List<Word> wordQuizList = [];

                        for (int i = 1; i < 5; i++) {
                          int count = index - i;
                          Word word = Word(words[count].front, words[count].back, words[count].pronunciation);
                          wordQuizList.add(word);
                        }
                        Navigator.push(context, MaterialPageRoute(builder: (context) => LearningWordsQuiz3(words)));
                      }
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: IconButton(
                  icon: Icon(Icons.multitrack_audio, color: MyColors().purple,),
                  iconSize: 100.0,
                  onPressed: () => print('play button pressed'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
