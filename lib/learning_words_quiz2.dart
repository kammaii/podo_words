import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:podo_words/learning_words_bar.dart';
import 'package:podo_words/word.dart';
import 'mix_index.dart';
import 'my_colors.dart';

class LearningWordsQuiz2 extends StatefulWidget {

  List<Word> words;

  LearningWordsQuiz2(this.words);

  @override
  _LearningWordsQuiz2State createState() => _LearningWordsQuiz2State();
}

class _LearningWordsQuiz2State extends State<LearningWordsQuiz2> {
  List<String> front = [];
  List<String> back = [];
  List<int> mixedIndexFront = MixIndex().getMixedIndex(4);
  List<int> mixedIndexBack = MixIndex().getMixedIndex(4);
  List<int> checkedIndex = [4, 4];
  List<int> answeredIndex = [];
  AudioPlayer player = AudioPlayer();

  @override
  void dispose() {
    super.dispose();
    player.dispose();
  }

  void initCheck() {
    checkedIndex = [4,4];
  }

  Widget wordItem(bool isFront) {
    List<String> words;
    List<int> mixedIndex;

    if(isFront) {
      words = front;
      mixedIndex = mixedIndexFront;

    } else {
      words = back;
      mixedIndex = mixedIndexBack;
    }

    return GridView.builder(
        shrinkWrap: true,
        itemCount: 4,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount (
          crossAxisCount: 2,
          childAspectRatio: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        itemBuilder: (context, index) {

          Color borderColor = Colors.white;
          Color backgroundColor = Colors.white;

          if(isFront && index == checkedIndex[0] || !isFront && index == checkedIndex[1]) {
            borderColor = MyColors().purple;
          }

          if(answeredIndex.contains(mixedIndex[index])) {
            backgroundColor = MyColors().purpleLight;
            return Center(
              child: Text(words[mixedIndex[index]], textScaleFactor: 1.5,
                  style: TextStyle(decoration: TextDecoration.lineThrough)),
            );

          } else {
            return Padding(
              padding: const EdgeInsets.all(1.0),
              child: InkWell(
                onTap: (){
                  setState(() {
                    if(isFront) {
                      checkedIndex[0] = index;
                    } else {
                      checkedIndex[1] = index;
                    }

                    if(checkedIndex[0] != 4 && checkedIndex[1] != 4) {
                      if(mixedIndexFront[checkedIndex[0]] == mixedIndexBack[checkedIndex[1]]) {  // 정답
                        print('정답');
                        answeredIndex.add(mixedIndexFront[checkedIndex[0]]);

                      } else {
                        print('오답');
                      }

                      initCheck();
                      if(answeredIndex.length == 4) {
                        // todo: 다음 퀴즈로 이동
                      }
                    }
                  });
                },
                child: Container(
                    decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [BoxShadow(color: borderColor, spreadRadius: 0.1)]
                    ),
                    child: Center(
                      child: Text(words[mixedIndex[index]], textScaleFactor: 1.5),
                    )
                ),
              ),
            );
          }
        }
    );
  }


  @override
  Widget build(BuildContext context) {

    for(Word word in widget.words) {
      front.add(word.front);
      back.add(word.back);
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SafeArea(
          child: Container(
            color: MyColors().purpleLight,
            child: Column(
              children: [
                LearningWordsBar(),
                Expanded(
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    child: wordItem(true)
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 50.0),
                  child: Row(
                    children: [
                      Expanded(child: Divider(color: MyColors().navy)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Text('match correct words', style: TextStyle(color: MyColors().navy),),
                      ),
                      Expanded(child: Divider(color: MyColors().navy))
                    ],
                  ),
                ),
                Expanded(
                    child: wordItem(false)
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
