import 'package:flutter/material.dart';
import 'package:podo_words/divider_text.dart';
import 'package:podo_words/learning_words_complete.dart';
import 'package:podo_words/play_audio.dart';
import 'package:podo_words/word.dart';
import 'list_mix.dart';
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
  List<String> mixedJamo = [];
  List<int> jamoDecimal = [];
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
      decomposed.add(jongList[jong]);

      jamoDecimal.add(cho);
      jamoDecimal.add(jung);
      jamoDecimal.add(jong);
    }
    return decomposed;
  }

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
    mixedJamo = new List<String>.from(jamo);
    mixedJamo.removeWhere((element) => element == '');
    ListMix().getMixedList(mixedJamo);
    answer = '';
    clickedIndex = [];
    print('정답 : $front');
    print('자모 : $jamo');
    print('랜덤자모 : $mixedJamo');
    print('자모십진수 : $jamoDecimal');
  }


  @override
  Widget build(BuildContext context) {

    if(answerCount == 0 && quizIndex < widget.words.length) {
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
                    itemCount: mixedJamo.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount (
                      crossAxisCount: 4,
                      childAspectRatio: 1,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                    ),

                    itemBuilder: (context, index) {
                      bool visible;
                      Color bgBtn;
                      TextDecoration textDecoration;

                      if(clickedIndex.contains(index)) {
                        bgBtn = MyColors().purpleLight;
                        textDecoration = TextDecoration.lineThrough;
                      } else {
                        bgBtn = Colors.white;
                        textDecoration = TextDecoration.none;
                      }

                      if(mixedJamo[index] == '') {
                        visible = false;
                      } else {
                        visible = true;
                      }

                      return Visibility(
                        visible: visible,
                        child: Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: InkWell(
                            onTap: () {
                              if (!clickedIndex.contains(index)) {
                                //정답 체크
                                if (jamo[answerCount] == '') { // 받침 없는 경우
                                  answerCount++;
                                }
                                if (jamo[answerCount] == mixedJamo[index]) { // 정답
                                  setState(() {
                                    clickedIndex.add(index);
                                    setAnswer(jamoDecimal[answerCount]);

                                    if (answerCount >= jamo.length - 1 &&
                                        jamo[jamo.length - 1] == '' ||
                                        answerCount >= jamo.length) { // 다음 퀴즈로 넘어가기
                                      PlayAudio().playCorrect();
                                      Future.delayed(
                                          const Duration(seconds: 1), () {
                                        setState(() {
                                          answerCount = 0;
                                          quizIndex++;
                                          if (quizIndex >= widget.words
                                              .length) { // 모든 퀴즈 완료
                                            Navigator.of(context)
                                                .pushAndRemoveUntil(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        LearningWordsComplete(
                                                            widget.words)), (
                                                Route<
                                                    dynamic> route) => false);
                                          }
                                        });
                                      });
                                    }
                                  });
                                } else {
                                  PlayAudio().playWrong();
                                }
                              }
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                  color: bgBtn,
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: Center(
                                  child: Text(mixedJamo[index],
                                    textScaleFactor: 1.5,
                                    style: TextStyle(
                                        decoration: textDecoration
                                    ),
                                  ),
                                )
                            ),
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
