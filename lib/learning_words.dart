import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:podo_words/learning_words_bar.dart';
import 'package:podo_words/words.dart';

class LearningWords extends StatefulWidget {

  final int lessonIndex;

  LearningWords(this.lessonIndex);


  @override
  _LearningWordsState createState() => _LearningWordsState();
}

class _LearningWordsState extends State<LearningWords> {
  Words words;
  int wordIndex = 0;
  String front;
  String back;
  List<String> image;

  @override
  Widget build(BuildContext context) {
    words = Words().getWords(widget.lessonIndex);
    front = words.front[wordIndex];
    back = words.back[wordIndex];
    image = words.image;

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
                        return Image.network(image[index]);
                      },
                      itemCount: image.length,
                      pagination: SwiperPagination(),
                      control: SwiperControl(),
                      viewportFraction: 0.8,
                      scale: 0.9,
                      onIndexChanged: (index) {
                        setState(() {
                          //todo: 단어 변경
                          wordIndex = index;
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
                Text(
                  back,
                  textScaleFactor: 2,
                ),
                IconButton(
                  icon: Icon(Icons.play_circle_outline),
                  iconSize: 150.0,
                  onPressed: () => print('play button pressed'),
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
                if(wordIndex < words.front.length - 1) {
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
