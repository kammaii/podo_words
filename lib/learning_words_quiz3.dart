import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:podo_words/divider_text.dart';
import 'package:podo_words/play_audio.dart';
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
  int quizIndex = 0;
  String front = "";
  String back = "";
  List<String> jamo = [];
  List<int> jamoDecimal = [];
  List<int> mixedIndex = [];
  int answerCount = 0;
  List<int> clickedIndex = [];

  List<String> choList = ["ㄱ", "ㄲ", "ㄴ", "ㄷ", "ㄸ", "ㄹ", "ㅁ", "ㅂ", "ㅃ", "ㅅ" ,"ㅆ", "ㅇ" ,"ㅈ", "ㅉ", "ㅊ", "ㅋ", "ㅌ" ,"ㅍ", "ㅎ"];
  List<String> jungList =["ㅏ", "ㅐ", "ㅑ", "ㅒ", "ㅓ", "ㅔ", "ㅕ", "ㅖ", "ㅗ", "ㅘ", "ㅙ", "ㅚ", "ㅛ", "ㅜ", "ㅝ", "ㅞ", "ㅟ", "ㅠ", "ㅡ", "ㅢ", "ㅣ"];
  List<String> jongList = ["", "ㄱ", "ㄲ", "ㄳ", "ㄴ", "ㄵ", "ㄶ", "ㄷ", "ㄹ", "ㄺ", "ㄻ", "ㄼ", "ㄽ", "ㄾ", "ㄿ", "ㅀ", "ㅁ", "ㅂ", "ㅄ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"];


  List<String> decomposeHangul(String front) {
    List<String> frontSplit = front.split('');
    List<String> decomposed = [];
    jamoDecimal = [];
    for(String str in frontSplit) {
      var uniCode = toRune(str);

      int cho = ((uniCode - 44032) / 28) ~/ 21;
      int jung = (((uniCode - 44032) / 28) % 21).toInt();
      int jong = ((uniCode - 44032) % 28).toInt();

      decomposed.add(choList[cho]);
      decomposed.add(jungList[jung]);
      if(jong != 0) {
        decomposed.add(jongList[jong]);
      }

      jamoDecimal.add(cho);
      jamoDecimal.add(jung);
      jamoDecimal.add(jong);
    }
    return decomposed;
  }

  //todo: 입력한 자모음이 순서에 맞으면 글자로 만들기

  String answer = '';
  int answerCho = 0;
  int answerJung = 0;
  int answerJong = 0;

  void setAnswer(int answeredDecimal) { // mixedIndex
    if(answerCount%3 == 0) { // 초성
      answer = answer + jamo[answerCount];
      answerCho = answeredDecimal;
      answerCount++;

    } else if (answerCount%3 == 1) { // 중성
      answer = answer.substring(0, answer.length - 1);
      answer = answer + assembleHangul(cho: answerCho, jung: answeredDecimal);
      answerJung = answeredDecimal;
      answerCount++;

    } else {  // 종성
      answer = answer.substring(0, answer.length - 1);
      answer = answer + assembleHangul(cho: answerCho, jung: answerJung, jong: answeredDecimal);
      answerCho = 0;
      answerJung = 0;
      answerJong = 0;
      answerCount++;
    }
  }

  String assembleHangul({required int cho, int jung = 0, int jong = 0}) {
    int decimal = (cho * 588 + jung * 28 + jong) + 44032;
    return String.fromCharCode(decimal);
  }

  void setQuiz() {
    front = widget.words[quizIndex].front;
    back = widget.words[quizIndex].back;
    jamo = decomposeHangul(front);
    mixedIndex = MixIndex().getMixedIndex(jamo.length);
    answer = '';
    clickedIndex = [];
    print('정답 : $front');
    print('자모 : $jamo');
    print('자모십진수 : $jamoDecimal');
    print('랜덤인덱스 : $mixedIndex');
  }


  @override
  Widget build(BuildContext context) {

    if(answerCount == 0) {
      setQuiz();
    }

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
                    child: Center(child: Text(answer, textScaleFactor: 1.5)),
                  ),
                ),
                SizedBox(height: 20.0),
                GridView.builder(
                    shrinkWrap: true,
                    itemCount: jamo.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount (
                      crossAxisCount: 4,
                      childAspectRatio: 1,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                    ),
                    itemBuilder: (context, index) {
                      Color bgBtn;
                      TextDecoration textDecoration;
                      if(clickedIndex.contains(index)) {
                        bgBtn = MyColors().purpleLight;
                        textDecoration = TextDecoration.lineThrough;
                      } else {
                        bgBtn = Colors.white;
                        textDecoration = TextDecoration.none;
                      }

                      return Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: InkWell(
                          onTap: (){
                            //정답 체크
                            int answeredDecimal = jamoDecimal[mixedIndex[index]];
                            if(answeredDecimal == jamoDecimal[answerCount]) { // 정답
                              setState(() {
                                PlayAudio().playCorrect();
                                clickedIndex.add(index);
                                setAnswer(answeredDecimal);

                                if(answerCount >= jamo.length) {  // 다음 퀴즈로 넘어가기
                                  answerCount = 0;
                                  quizIndex++;

                                  if(quizIndex >= widget.words.length) {  // 모든 퀴즈 완료
                                    Navigator.pop(context);
                                  }
                                }
                              });
                              
                            } else {
                              PlayAudio().playWrong();
                            }
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                  color: bgBtn,
                                  borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Center(
                                child: Text(jamo[mixedIndex[index]],
                                  textScaleFactor: 1.5,
                                  style: TextStyle(
                                    decoration: textDecoration
                                  ),
                                ),
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
