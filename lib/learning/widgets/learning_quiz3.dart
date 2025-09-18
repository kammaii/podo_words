import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_words/learning/controllers/learning_controller.dart';
import 'package:podo_words/learning/hangul_service.dart';
import 'package:podo_words/learning/models/word.dart';
import 'package:podo_words/learning/pages/learning_complete_page.dart';
import 'package:podo_words/learning/widgets/audio_button.dart';
import 'package:podo_words/learning/widgets/divider_text.dart';

import '../../common/my_colors.dart';
import '../list_mix.dart';

class LearningQuiz3 extends StatefulWidget {
  const LearningQuiz3({super.key});

  @override
  _LearningQuiz3State createState() => _LearningQuiz3State();
}

class _LearningQuiz3State extends State<LearningQuiz3> {
  final controller = Get.find<LearningController>();
  final _hangulService = HangulService();

  late final List<Word> _quizWords;
  late Word _currentWord;
  int _currentQuizIndex = 0;

  late List<String> _correctJamoSequence; // 정답 자모 순서
  late List<int> _correctDecimalSequence; // 정답 십진수 순서
  late List<String> _shuffledJamoOptions; // 섞인 자모 선택지

  List<int> _clickedOptionIndices = []; // 클릭한 선택지의 인덱스
  String _currentAnswer = ''; // 현재 조립된 정답 문자열
  int _currentJamoIndex = 0;// 맞춰야 할 자모의 순서

  @override
  void initState() {
    super.initState();
    _quizWords = controller.getQuizWords();
    _setupNewQuizRound(0); // 첫 번째 퀴즈 설정
  }

  /// 새로운 단어로 퀴즈 라운드를 설정하는 함수
  void _setupNewQuizRound(int quizIndex) {
    setState(() {
      _currentQuizIndex = quizIndex;
      _currentWord = _quizWords[quizIndex];

      controller.audioController.playWordAudio(_currentWord);

      // 한글 서비스를 사용하여 자모 분해
      final decomposed = _hangulService.decompose(_currentWord.front);
      _correctJamoSequence = decomposed.jamoList;
      _correctDecimalSequence = decomposed.decimalList;

      // 선택지용 자모 리스트 생성 (공백, 빈 받침 등 제외)
      _shuffledJamoOptions = List.from(_correctJamoSequence)
        ..removeWhere((jamo) => jamo == '' || jamo == ' ' || jamo == '/' || jamo == '=');
      ListMix().getMixedList(_shuffledJamoOptions);

      // 라운드 상태 초기화
      _currentAnswer = '';
      _clickedOptionIndices = [];
      _currentJamoIndex = 0;

      _skipEmptyOrSpecialChars(); // 공백/특수문자 건너뛰기
    });
  }

  /// 자모 선택지를 탭했을 때 호출
  void _onJamoTapped(int gridIndex) {
    if (_clickedOptionIndices.contains(gridIndex)) return; // 이미 클릭한 자모는 무시

    // 정답 체크
    if (_correctJamoSequence[_currentJamoIndex] == _shuffledJamoOptions[gridIndex]) {
      // 정답일 경우
      setState(() {
        _clickedOptionIndices.add(gridIndex);
        _updateAnswer(); // 정답 문자열 업데이트
        _currentJamoIndex++;
        _skipEmptyOrSpecialChars();
      });

      // 현재 단어를 모두 맞췄는지 확인
      if (_currentAnswer == _currentWord.front) {
        _handleQuizCompletion();
      }
    } else {
      // 오답일 경우
      controller.audioController.playWrong();
    }
  }

  /// 정답 문자열을 조립하고 업데이트하는 함수
  void _updateAnswer() {
    String newAnswer = '';

    // 현재까지 맞춘 자모의 개수만큼을 기반으로 문자열을 재조립합니다.
    int tempJamoIndex = 0; // _correctJamoSequence를 순회할 인덱스
    int tempDecimalIndex = 0; // _correctDecimalSequence를 순회할 인덱스

    while (tempJamoIndex <= _currentJamoIndex && tempJamoIndex < _correctJamoSequence.length) {
      // 1. 초성 처리
      if (_correctJamoSequence[tempJamoIndex] == ' ' || _correctJamoSequence[tempJamoIndex] == '/' || _correctJamoSequence[tempJamoIndex] == '=') {
        newAnswer += _correctJamoSequence[tempJamoIndex];
        tempJamoIndex++;
        continue;
      }
      final cho = _correctDecimalSequence[tempDecimalIndex];
      newAnswer += HangulService.choList[cho];
      tempJamoIndex++;
      if (tempJamoIndex > _currentJamoIndex) break;

      // 2. 중성 처리
      final jung = _correctDecimalSequence[tempDecimalIndex + 1];
      newAnswer = newAnswer.substring(0, newAnswer.length - 1);
      newAnswer += _hangulService.assemble(cho: cho, jung: jung);
      tempJamoIndex++;
      if (tempJamoIndex > _currentJamoIndex) break;

      // 3. 종성 처리
      if (_correctJamoSequence[tempJamoIndex] != '') {
        final jong = _correctDecimalSequence[tempDecimalIndex + 2];
        newAnswer = newAnswer.substring(0, newAnswer.length - 1);
        newAnswer += _hangulService.assemble(cho: cho, jung: jung, jong: jong);
      }
      tempJamoIndex++;

      // 한 음절(초/중/종) 처리가 끝나면 십진수 인덱스를 3 증가시킵니다.
      tempDecimalIndex += 3;
    }

    _currentAnswer = newAnswer;
  }

  /// 정답 순서에서 공백, 빈 받침 등을 건너뛰는 함수
  void _skipEmptyOrSpecialChars() {
    while (_currentJamoIndex < _correctJamoSequence.length) {
      final nextJamo = _correctJamoSequence[_currentJamoIndex];
      if (nextJamo == '' || nextJamo == ' ' || nextJamo == '/' || nextJamo == '=') {
        _currentAnswer += nextJamo;
        _currentJamoIndex++;
      } else {
        break;
      }
    }
  }

  /// 한 단어를 모두 맞췄을 때 처리
  void _handleQuizCompletion() {
    controller.audioController.playCorrect();
    Future.delayed(const Duration(seconds: 1), _moveToNextQuizOrFinish);
  }

  /// 다음 퀴즈로 넘어가거나 전체 학습을 완료하는 함수
  void _moveToNextQuizOrFinish() {
    if (_currentQuizIndex + 1 < _quizWords.length) {
      _setupNewQuizRound(_currentQuizIndex + 1);
    } else {
      controller.setQuizComplete();
      if (controller.isLastWord) {
        Get.to(() => LearningCompletePage());
      } else {
        controller.content.removeLast();
        controller.audioController.playWordAudio(controller.getThisWord());
        controller.update();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // build 메소드에서는 UI를 그리는 데만 집중
    if (_quizWords.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      color: MyColors().purpleLight,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Center(child: AudioButton(_currentWord)), // [수정] Word 객체 전달
          ),
          Text(_currentWord.back, style: TextStyle(color: MyColors().purple)),
          DividerText().getDivider('Listen & Answer'),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            padding: const EdgeInsets.all(15.0),
            height: 60.0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Center(child: Text(_currentAnswer, style: const TextStyle(fontSize: 25))),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              shrinkWrap: true,
              itemCount: _shuffledJamoOptions.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                childAspectRatio: 1.2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
              ),
              itemBuilder: (context, index) {
                final isClicked = _clickedOptionIndices.contains(index);
                return InkWell(
                  onTap: () => _onJamoTapped(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isClicked ? MyColors().purpleLight : Colors.white,
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Center(
                      child: Text(
                        _shuffledJamoOptions[index],
                        style: TextStyle(
                          decoration: isClicked ? TextDecoration.lineThrough : TextDecoration.none,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}