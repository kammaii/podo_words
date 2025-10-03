import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:podo_words/learning/list_mix.dart';
import 'package:podo_words/common/my_colors.dart';
import 'package:podo_words/learning/controllers/audio_controller.dart';
import 'package:podo_words/learning/models/word_model.dart';
import 'package:podo_words/learning/controllers/learning_controller.dart';
import 'package:podo_words/learning/widgets/learning_quiz3.dart';
import 'package:podo_words/learning/widgets/divider_text.dart';

class LearningQuiz2 extends StatefulWidget {
  const LearningQuiz2({super.key});

  @override
  _LearningQuiz2State createState() => _LearningQuiz2State();
}

class _LearningQuiz2State extends State<LearningQuiz2> {
  final controller = Get.find<LearningController>();
  StreamSubscription<PlayerState>? _subscription;

  late final List<Word> _quizWords;
  late final List<int> _mixedFrontIndices;
  late final List<int> _mixedBackIndices;

  // 선택된 아이템의 '그리드 인덱스'를 저장 (null은 선택되지 않음을 의미)
  int? _selectedFrontIndex;
  int? _selectedBackIndex;

  // 정답을 맞춘 단어의 '원본 인덱스'를 저장
  final Set<int> _correctlyMatchedOriginalIndices = {};

  @override
  void initState() {
    super.initState();
    // 1. GetX 컨트롤러에서 단어 목록을 한 번만 가져와 상태 변수에 저장
    _quizWords = controller.getQuizWords();
    final length = _quizWords.length;

    // 2. 각 목록의 순서를 섞을 인덱스 리스트 생성
    _mixedFrontIndices = List.generate(length, (i) => i);
    _mixedBackIndices = List.generate(length, (i) => i);
    ListMix().getMixedList(_mixedFrontIndices);
    ListMix().getMixedList(_mixedBackIndices);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  // 아이템을 탭했을 때 호출되는 메인 핸들러
  void _onItemTapped(bool isFront, int tappedGridIndex) {
    // 이미 맞춘 단어는 탭해도 반응 없음
    final originalIndex = isFront ? _mixedFrontIndices[tappedGridIndex] : _mixedBackIndices[tappedGridIndex];
    if (_correctlyMatchedOriginalIndices.contains(originalIndex)) return;

    setState(() {
      if (isFront) {
        _selectedFrontIndex = tappedGridIndex;
      } else {
        _selectedBackIndex = tappedGridIndex;
      }
    });

    // 양쪽 모두 아이템이 선택되었는지 확인
    if (_selectedFrontIndex != null && _selectedBackIndex != null) {
      _checkForMatch();
    }
  }

  // 선택된 두 아이템이 정답인지 확인하는 함수
  void _checkForMatch() {
    final originalFrontIndex = _mixedFrontIndices[_selectedFrontIndex!];
    final originalBackIndex = _mixedBackIndices[_selectedBackIndex!];

    // 정답일 경우
    if (originalFrontIndex == originalBackIndex) {
      final correctWord = _quizWords[originalFrontIndex];
      controller.audioController.playWordAudio(correctWord);

      setState(() {
        _correctlyMatchedOriginalIndices.add(originalFrontIndex);
        _selectedFrontIndex = null;
        _selectedBackIndex = null;
      });

      // 모든 문제를 다 맞췄는지 확인
      if (_correctlyMatchedOriginalIndices.length == _quizWords.length) {
        _onQuizCompleted();
      }
    }
    // 오답일 경우
    else {
      controller.audioController.playWrong();
      setState(() {
        _selectedFrontIndex = null;
        _selectedBackIndex = null;
      });
    }
  }

  /// 모든 문제를 맞췄을 때 다음 화면으로 넘어가는 함수
  void _onQuizCompleted() {
    _subscription = controller.audioController.audioPlayer.playerStateStream.listen((event) {
      if (event.processingState == ProcessingState.completed) {
        _subscription?.cancel();
        controller.content.last = LearningQuiz3();
        controller.update();
      }
    });
  }

  Widget _buildWordsGrid({required bool isFront}) {
    final mixedIndices = isFront ? _mixedFrontIndices : _mixedBackIndices;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      // Expanded 위젯 내부이므로 스크롤 방지
      itemCount: _quizWords.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5, // 비율 조절
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      itemBuilder: (context, gridIndex) {
        final originalIndex = mixedIndices[gridIndex];
        final word = _quizWords[originalIndex];
        final text = isFront ? word.front : word.back;

        // UI 상태 결정
        final isCorrectlyMatched = _correctlyMatchedOriginalIndices.contains(originalIndex);
        final isSelected = isFront ? gridIndex == _selectedFrontIndex : gridIndex == _selectedBackIndex;

        if (isCorrectlyMatched) {
          // 정답을 맞춘 아이템
          return Center(
            child: Text(text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                  decoration: TextDecoration.lineThrough,
                )),
          );
        } else {
          // 아직 맞추지 않은 아이템
          return InkWell(
            onTap: () => _onItemTapped(isFront, gridIndex),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(
                  color: isSelected ? MyColors().purple : Colors.white,
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(50),
                    spreadRadius: 1,
                    blurRadius: 3,
                  )
                ],
              ),
              child: Center(
                child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20))),
              ),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: MyColors().purpleLight,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Expanded(
            child: Container(alignment: Alignment.center, child: _buildWordsGrid(isFront: true)),
          ),
          DividerText().getDivider('match correct words'),
          Expanded(
            child: Container(alignment: Alignment.center, child: _buildWordsGrid(isFront: false)),
          ),
        ],
      ),
    );
  }
}
