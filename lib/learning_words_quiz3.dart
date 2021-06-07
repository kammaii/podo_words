import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:podo_words/divider_text.dart';
import 'package:podo_words/word.dart';
import 'mix_index.dart';
import 'my_colors.dart';
import 'package:unicode/unicode.dart';

class LearningWordsQuiz3 extends StatefulWidget {

  List<Word> words = [];
  LearningWordsQuiz3(this.words);

  @override
  _LearningWordsQuiz3State createState() => _LearningWordsQuiz3State();
}

class _LearningWordsQuiz3State extends State<LearningWordsQuiz3> {
  int wordIndex = 0;
  String front = "";
  String back = "";
  List<String> hangul = [];
  List<int> mixedIndex = [];


  List<String> cho = ["ㄱ", "ㄲ", "ㄴ", "ㄷ", "ㄸ", "ㄹ", "ㅁ", "ㅂ", "ㅃ", "ㅅ" ,"ㅆ", "ㅇ" ,"ㅈ", "ㅉ", "ㅊ", "ㅋ", "ㅌ" ,"ㅍ", "ㅎ"];
  List<String> jung =["ㅏ", "ㅐ", "ㅑ", "ㅒ", "ㅓ", "ㅔ", "ㅕ", "ㅖ", "ㅗ", "ㅘ", "ㅙ", "ㅚ", "ㅛ", "ㅜ", "ㅝ", "ㅞ", "ㅟ", "ㅠ", "ㅡ", "ㅢ", "ㅣ"];
  List<String> jong = ["", "ㄱ", "ㄲ", "ㄳ", "ㄴ", "ㄵ", "ㄶ", "ㄷ", "ㄹ", "ㄺ", "ㄻ", "ㄼ", "ㄽ", "ㄾ", "ㄿ", "ㅀ", "ㅁ", "ㅂ", "ㅄ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"];


  List<String> decomposeHangul(String front) {
    List<String> frontSplit = front.split('');
    List<String> decomposed = [];
    for(String str in frontSplit) {
      var uniCode = toRune(str);
      int cho = ((((uniCode - 0xAC00) / 28) / 21) + 0x1100).toInt();
      int jung = ((((uniCode - 0xAC00) / 28) % 21) + 0x1161).toInt();
      int jong = ((((uniCode - 0xAC00) % 28)) + 0x11A8 - 1).toInt();
      decomposed.add(String.fromCharCode(cho));
      decomposed.add(String.fromCharCode(jung));
      if(jong != 4519) {
        decomposed.add(String.fromCharCode(jong));
      }
    }
    return decomposed;
  }


  @override
  Widget build(BuildContext context) {

    front = widget.words[wordIndex].front;
    back = widget.words[wordIndex].back;

    hangul = decomposeHangul(front);
    mixedIndex = MixIndex().getMixedIndex(hangul.length);


    return Scaffold(
      body: SafeArea(
        child: Container(
          color: MyColors().purpleLight,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                IconButton(
                  icon: Icon(Icons.multitrack_audio, color: MyColors().purple,),
                  iconSize: 100.0,
                  onPressed: () => print('play button pressed'),
                ),
                DividerText().getDivider('Listen & Answer'),
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Center(child: Text(front, textScaleFactor: 1.5)),
                  ),
                ),
                SizedBox(height: 20.0),
                GridView.builder(
                    shrinkWrap: true,
                    itemCount: hangul.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount (
                      crossAxisCount: 4,
                      childAspectRatio: 1,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                    ),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: InkWell(
                          onTap: (){
                            setState(() {

                            });
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Center(
                                child: Text(hangul[mixedIndex[index]], textScaleFactor: 1.5),
                              )
                          ),
                        ),
                      );
                    }
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
