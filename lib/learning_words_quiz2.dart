import 'package:flutter/material.dart';
import 'package:podo_words/divider_text.dart';
import 'package:podo_words/play_audio.dart';
import 'package:podo_words/word.dart';
import 'list_mix.dart';
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
  List<String> audio = [];
  List<int> mixedIndexFront = List<int>.generate(4, (index) => index);
  List<int> mixedIndexBack = List<int>.generate(4, (index) => index);
  List<int> checkedIndex = [4, 4];
  List<int> answeredIndex = [];


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
                        PlayAudio().playWord(audio[mixedIndexFront[checkedIndex[0]]]);
                        answeredIndex.add(mixedIndexFront[checkedIndex[0]]);

                      } else {
                        print('오답');
                        PlayAudio().playWrong();
                      }

                      initCheck();
                      if(answeredIndex.length == 4) {
                        Navigator.pop(context);
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
  void initState() {
    super.initState();
    ListMix().getMixedList(mixedIndexFront);
    ListMix().getMixedList(mixedIndexBack);

    for(Word word in widget.words) {
      front.add(word.front);
      back.add(word.back);
      audio.add(word.audio);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: MyColors().purpleLight,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    child: wordItem(true)
                  ),
                ),
                DividerText().getDivider('match correct words'),
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
