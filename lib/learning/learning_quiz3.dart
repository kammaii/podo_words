import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_words/common/divider_text.dart';
import 'package:podo_words/learning/learning_complete.dart';
import 'package:podo_words/common/play_audio.dart';
import 'package:podo_words/common/play_audio_button.dart';
import 'package:podo_words/common/word.dart';
import 'package:podo_words/learning/learning_controller.dart';
import 'package:podo_words/learning/word_card.dart';
import '../common/list_mix.dart';
import '../common/my_colors.dart';
import 'package:unicode/unicode.dart';

class LearningQuiz3 extends StatefulWidget {
  @override
  _LearningQuiz3State createState() => _LearningQuiz3State();
}

class _LearningQuiz3State extends State<LearningQuiz3> {
  int quizIndex = 0;
  late String front;
  late String back;
  late String audio;
  late List<String> jamo;
  late List<String> mixedJamo;
  late List<int> jamoDecimal;
  int answerCount = 0;
  late List<int> clickedIndex;

  List<String> choList = [
    "ㄱ",
    "ㄲ",
    "ㄴ",
    "ㄷ",
    "ㄸ",
    "ㄹ",
    "ㅁ",
    "ㅂ",
    "ㅃ",
    "ㅅ",
    "ㅆ",
    "ㅇ",
    "ㅈ",
    "ㅉ",
    "ㅊ",
    "ㅋ",
    "ㅌ",
    "ㅍ",
    "ㅎ"
  ];
  List<String> jungList = [
    "ㅏ",
    "ㅐ",
    "ㅑ",
    "ㅒ",
    "ㅓ",
    "ㅔ",
    "ㅕ",
    "ㅖ",
    "ㅗ",
    "ㅘ",
    "ㅙ",
    "ㅚ",
    "ㅛ",
    "ㅜ",
    "ㅝ",
    "ㅞ",
    "ㅟ",
    "ㅠ",
    "ㅡ",
    "ㅢ",
    "ㅣ"
  ];
  List<String> jongList = [
    "",
    "ㄱ",
    "ㄲ",
    "ㄳ",
    "ㄴ",
    "ㄵ",
    "ㄶ",
    "ㄷ",
    "ㄹ",
    "ㄺ",
    "ㄻ",
    "ㄼ",
    "ㄽ",
    "ㄾ",
    "ㄿ",
    "ㅀ",
    "ㅁ",
    "ㅂ",
    "ㅄ",
    "ㅅ",
    "ㅆ",
    "ㅇ",
    "ㅈ",
    "ㅊ",
    "ㅋ",
    "ㅌ",
    "ㅍ",
    "ㅎ"
  ];

  final controller = Get.find<LearningController>();
  List<Word> words = [];

  @override
  void initState() {
    super.initState();
    words = controller.getQuizWords();
  }

  List<String> decomposeHangul(String front) {
    // 돈을 벌다
    List<String> frontSplit = front.split(''); // 돈,을, ,벌,다
    List<String> decomposed = [];
    jamoDecimal = [];
    for (String str in frontSplit) {
      if (str != ' ' && str != '=' && str != '/') {
        var uniCode = toRune(str);

        int cho = ((uniCode - 44032) / 28) ~/ 21;
        int jung = (((uniCode - 44032) / 28) % 21).toInt();
        int jong = ((uniCode - 44032) % 28).toInt();

        decomposed.add(choList[cho]); //ㄷ
        decomposed.add(jungList[jung]); //ㅗ
        decomposed.add(jongList[jong]); //ㄴ

        jamoDecimal.add(cho);
        jamoDecimal.add(jung);
        jamoDecimal.add(jong);
      } else {
        decomposed.add(str);
      }
    }
    return decomposed;
  }

  String answer = '';
  int answerCho = 0;
  int answerJung = 0;
  int answerJong = 0;

  void setAnswer(int answeredDecimal) {
    if (answerCount % 3 == 0) {
      // 초성
      answer += jamo[answerCount];
      answerCho = answeredDecimal;
      answerCount++;
    } else if (answerCount % 3 == 1) {
      // 중성
      answer = answer.substring(0, answer.length - 1);
      answer += assembleHangul(cho: answerCho, jung: answeredDecimal);
      answerJung = answeredDecimal;
      answerCount++;
    } else {
      // 종성
      answer = answer.substring(0, answer.length - 1);
      answer += assembleHangul(cho: answerCho, jung: answerJung, jong: answeredDecimal);
      answerCho = 0;
      answerJung = 0;
      answerJong = 0;
      answerCount++;
    }

    if (answerCount < jamo.length && jamo[answerCount] == '') {
      // 받침 없는 경우
      answerCount++;
    }

    if (answerCount < jamo.length) {
      if (jamo[answerCount] == ' ' || jamo[answerCount] == '=' || jamo[answerCount] == '/') {
        answer += jamo[answerCount];
        jamo.removeAt(answerCount);
      }
    }
  }

  String assembleHangul({required int cho, int jung = 0, int jong = 0}) {
    int decimal = (cho * 588 + jung * 28 + jong) + 44032;
    return String.fromCharCode(decimal);
  }

  void setQuiz() {
    front = words[quizIndex].front;
    back = words[quizIndex].back;
    audio = words[quizIndex].audio;
    PlayAudio().playWord(audio);
    jamo = decomposeHangul(front);
    mixedJamo = new List<String>.from(jamo);
    mixedJamo.removeWhere((element) => element == '');
    mixedJamo.removeWhere((element) => element == '/');
    mixedJamo.removeWhere((element) => element == '=');
    mixedJamo.removeWhere((element) => element == ' ');
    ListMix().getMixedList(mixedJamo);
    answer = '';
    clickedIndex = [];
    print('정답 : $front');
    print('자모 : $jamo');
    print('랜덤자모 : $mixedJamo');
    print('자모십진수 : $jamoDecimal');
  }

  bool isHintOn = false;

  @override
  Widget build(BuildContext context) {
    if (answerCount == 0 && quizIndex < words.length) {
      setQuiz();
    }

    return Container(
      color: MyColors().purpleLight,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Center(child: PlayAudioButton(audio)),
          ),
          Text(back, style: TextStyle(color: MyColors().purple)),
          Center(
            child: Visibility(
              child: Text(back),
              visible: isHintOn,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
            ),
          ),
          DividerText().getDivider('Listen & Answer'),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(height: 30.0, child: Center(child: Text(answer, style: TextStyle(fontSize: 20)))),
            ),
          ),
          SizedBox(height: 20.0),
          Expanded(
            child: GridView.builder(
                shrinkWrap: true,
                itemCount: mixedJamo.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                ),
                itemBuilder: (context, index) {
                  Color bgBtn;
                  TextDecoration textDecoration;

                  if (clickedIndex.contains(index)) {
                    bgBtn = MyColors().purpleLight;
                    textDecoration = TextDecoration.lineThrough;
                  } else {
                    bgBtn = Colors.white;
                    textDecoration = TextDecoration.none;
                  }

                  return Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: InkWell(
                      onTap: () {
                        if (!clickedIndex.contains(index)) {
                          //정답 체크
                          if (jamo[answerCount] == mixedJamo[index]) {
                            // 정답
                            setState(() {
                              clickedIndex.add(index);
                              setAnswer(jamoDecimal[answerCount]);
                            });

                            if (answer == front) {
                              // 다음 퀴즈로 넘어가기
                              PlayAudio().playCorrect();
                              Future.delayed(const Duration(seconds: 1), () {
                                setState(() {
                                  answerCount = 0;
                                  quizIndex++;
                                  isHintOn = false;
                                  if (quizIndex >= words.length) {
                                    // 퀴즈3 완료
                                    controller.setQuizComplete();
                                    if (controller.isLastWord) {
                                      Get.to(LearningComplete());
                                    } else {
                                      controller.content.removeLast();
                                      PlayAudio().playWord(controller.getThisWord().audio);
                                      controller.update();
                                    }
                                  }
                                });
                              });
                            }
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
                            child: Text(
                              mixedJamo[index],
                              style: TextStyle(decoration: textDecoration, fontSize: 20),
                            ),
                          )),
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }
}
