import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:podo_words/learning_words_bar.dart';
import 'package:podo_words/learning_words_quiz1.dart';
import 'package:podo_words/my_colors.dart';
import 'package:podo_words/word.dart';
import 'package:podo_words/words.dart';

class LearningWords extends StatefulWidget {

  final int lessonIndex;

  LearningWords(this.lessonIndex);


  @override
  _LearningWordsState createState() => _LearningWordsState();
}

class _LearningWordsState extends State<LearningWords> {
  List<Word> words;
  int wordIndex = 0;
  String front;
  String back;
  List<String> images;

  @override
  Widget build(BuildContext context) {
    words = Words().getWords(widget.lessonIndex);
    front = words[wordIndex].front;
    back = words[wordIndex].back;
    images = [];
    for(int i=0; i<words.length; i++) {
      String image = words[i].image;
      images.add(image);
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SafeArea(
          child: GestureDetector(
            child: Column(
              children: [
                LearningWordsBar(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Swiper(
                      itemBuilder: (context, index) {
                        return Image.network(images[index]);
                      },
                      itemCount: images.length,
                      pagination: SwiperPagination(),
                      control: SwiperControl(),
                      viewportFraction: 0.7,
                      scale: 0.7,
                      onIndexChanged: (index) {
                        setState(() {
                          wordIndex = index;

                          //todo: index가 4의 배수이거나 마지막 index일 때 퀴즈1으로 이동
                          //todo : 마지막 index일 때는 isLastQuiz = true 추가
                          if(index % 4 == 0 || index == images.length) {
                            List<Word> wordQuizList = [];

                            for (int i = 1; i < 5; i++) {
                              int count = index-i;
                              Word word = Word(words[count].front, words[count].back, words[count].image);
                              wordQuizList.add(word);
                            }
                            Navigator.push(context, MaterialPageRoute(builder: (context) => LearningWordsQuiz1(wordQuizList)));
                          }
                        });
                      },
                    )
                  ),
                ),
                AnimatedSwitcher(
                  child: Text(
                    front,
                    textScaleFactor: 3,
                    key: ValueKey<String>(front),
                  ),
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return ScaleTransition(child: child, scale: animation);
                  },
                ),
                SizedBox(height: 10.0,),
                Text(
                  back,
                  textScaleFactor: 2,
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
            onPanUpdate: (detail) {
              if (detail.delta.dx > 0) {

                if(wordIndex > 0) {
                  wordIndex--;
                  print('오른쪽 스와이프');

                } else {
                  //todo: 퀴즈로 이동
                }

              } else {
                if(wordIndex < words.length - 1) {
                  wordIndex++;
                  print('왼쪽 스와이프');
                }
              }
            },
          ),
        ),
      ),
    );
  }
}
