import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_words/common/my_colors.dart';
import 'package:podo_words/learning/controllers/learning_controller.dart';
import 'package:podo_words/learning/pages/learning_page.dart';
import 'package:podo_words/review/review_calculator.dart';
import 'package:podo_words/review/review_flashcard_page.dart';
import 'package:podo_words/review/review_word_tile.dart';
import 'package:podo_words/user/user_controller.dart';

import '../learning/models/word_model.dart';
import '../learning/widgets/show_snack_bar.dart';
import '../user/user_service.dart';

// 필터 탭을 위한 열거형
enum ReviewFilter { Priority, All, Inactive }

class ReviewListPage extends StatefulWidget {
  @override
  ReviewPageState createState() => ReviewPageState();
}

class ReviewPageState extends State<ReviewListPage> {

// GetX 컨트롤러 및 서비스 인스턴스 가져오기
  final userController = Get.find<UserController>();
  final learningController = Get.find<LearningController>();
  final userService = UserService();

  // 로컬 UI 상태를 관리하는 변수들
  ReviewFilter _currentFilter = ReviewFilter.Priority;
  String _searchInput = "";

  final _textFieldController = TextEditingController();
  final _focusNode = FocusNode();

  final _reviewCalculator = ReviewCalculator();

  @override
  void initState() {
    super.initState();
    _textFieldController.addListener(() {
      // 검색창의 텍스트가 변경될 때마다 상태 업데이트
      setState(() {
        _searchInput = _textFieldController.text;
      });
    });
  }

  @override
  void dispose() {
    _textFieldController.dispose();
    _focusNode.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Obx(() {
          // 1. 실시간 데이터 소스 가져오기
          final List<Word> myWords = userController.myWords.toList();
          final Set<String> inactiveWordIds = userController.inactiveWordIds;

          // --- 필터링 및 정렬 로직 ---
          List<Word> filteredWords;
          // 1. 활성/비활성 필터링
          switch (_currentFilter) {
            case ReviewFilter.Priority:
              filteredWords = myWords.where((w) => !inactiveWordIds.contains(w.id)).toList();
              break;
            case ReviewFilter.Inactive:
              filteredWords = myWords.where((w) => inactiveWordIds.contains(w.id)).toList();
              break;
            case ReviewFilter.All:
              filteredWords = myWords;
              break;
          }

          // 2. 'Priority' 탭일 경우 우선순위로 정렬
          if (_currentFilter == ReviewFilter.Priority) {
            filteredWords.sort((a, b) {
              final statusA = _reviewCalculator.getStatus(a);
              final statusB = _reviewCalculator.getStatus(b);
              return statusA.memoryPercent.compareTo(statusB.memoryPercent); // Urgent(0)가 맨 위로 오도록 정렬
            });
          }

          // 3. 검색어 필터링
          final List<Word> myWordsInList = _searchInput.isNotEmpty
              ? filteredWords.where((w) =>
          w.front.toLowerCase().contains(_searchInput.toLowerCase()) ||
              w.back.toLowerCase().contains(_searchInput.toLowerCase())).toList()
              : filteredWords;


          return Scaffold(
            body: Column(
              children: [
                // --- 검색창 및 필터 버튼 UI ---
                Container(
                  padding: const EdgeInsets.all(8.0), // 전체적인 내부 여백
                  decoration: BoxDecoration(
                    color: MyColors().navyLight,
                    borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withAlpha(20),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: TextField(
                          focusNode: _focusNode,
                          controller: _textFieldController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.search, color: MyColors().purple),
                            border: InputBorder.none,
                            hintText: 'Search your words',
                            contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<ReviewFilter>(
                          segments: const <ButtonSegment<ReviewFilter>>[
                            ButtonSegment<ReviewFilter>(
                                value: ReviewFilter.Priority,
                                label: Text('Priority'),
                                icon: Icon(Icons.local_fire_department)),
                            ButtonSegment<ReviewFilter>(
                                value: ReviewFilter.All,
                                label: Text('All'),
                                icon: Icon(Icons.all_inclusive)),
                            ButtonSegment<ReviewFilter>(
                                value: ReviewFilter.Inactive,
                                label: Text('Inactive'),
                                icon: Icon(Icons.visibility_off)),
                          ],
                          selected: {_currentFilter},
                          onSelectionChanged: (Set<ReviewFilter> newSelection) {
                            setState(() {
                              _currentFilter = newSelection.first;
                              _textFieldController.clear();
                              _focusNode.unfocus();
                            });
                          },
                          style: SegmentedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: MyColors().purple,
                            selectedBackgroundColor: MyColors().purple,
                            selectedForegroundColor: Colors.white,
                            minimumSize: const Size(0, 50),
                            side: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // --- 단어 개수 및 안내 문구 ---
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.info_outline_rounded, color: MyColors().purple),
                        onPressed: () {
                          Get.dialog(
                            AlertDialog(
                              title: Row(
                                children: [
                                  Icon(Icons.info_outline_rounded),
                                  SizedBox(width: 10),
                                  Text('Quick Guide'),
                                ],
                              ),
                              content: const Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('💡 \nSwipe any word to toggle it active/inactive.', style: TextStyle(fontSize: 16)),
                                  SizedBox(height: 15),
                                  Text('💡 \nThe percentage (%) indicates your memory strength. Review words with a lower percentage first!', style: TextStyle(fontSize: 16)),
                                ],
                              ),
                              actions: [
                                TextButton(onPressed: () => Get.back(), child: const Text('OK')),
                              ],
                            )
                          );
                        },
                      ),
                      Row(
                        children: [
                          Icon(Icons.assistant_photo_outlined, color: MyColors().purple),
                          Text(myWordsInList.length.toString(), style: TextStyle(fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: MyColors().purple)),
                        ],
                      )
                    ],
                  ),
                ),
                // --- 단어 목록 ---
                Expanded(
                  child: GestureDetector(
                    child: ListView.builder(
                      itemCount: myWordsInList.length,
                      itemBuilder: (context, index) {
                        final myWord = myWordsInList[index];
                        final status = _reviewCalculator.getStatus(myWord);
                        final isActive = !inactiveWordIds.contains(myWord.id);

                        return ReviewWordTile(
                          key: ValueKey('${myWord.id}_$isActive'),
                          myWord: myWord,
                          status: status,
                          isActive: isActive,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.play_arrow_rounded,
                color: MyColors().green,
                size: 50.0,
              ),
              onPressed: () {
                _focusNode.unfocus();

                if (myWordsInList.isNotEmpty) {
                  showCupertinoModalPopup(
                    context: context,
                    builder: (_) => _playBtnClick(myWordsInList),
                  );
                } else {
                  ShowSnackBar().getSnackBar(context, 'You have no words to review.');
                }
              },
            ),
          );
        }),
      ),
    );
  }


  CupertinoActionSheet _playBtnClick(List<Word> myWordsInList) {

    final shouldShowAds = !userController.isPremium;

    return CupertinoActionSheet(
      message: const Text('Select review mode', style: TextStyle(fontSize: 20)),
      actions: [
        CupertinoActionSheetAction(
          child: const Text('Quiz'),
          onPressed: () {
            Get.back();
            if (myWordsInList.length >= 4) {
              learningController.learningMode = LearningMode.review;
              Get.to(() => LearningPage(), arguments: {
                'shouldShowAds': shouldShowAds,
                'words': myWordsInList,
              });
            } else {
              ShowSnackBar().getSnackBar(context, 'It needs more than 4 words to start a quiz.');
            }
          },
        ),
        CupertinoActionSheetAction(
          child: const Text('Flash Card'),
          onPressed: () {
            Get.back();
            Get.to(() => ReviewFlashCardPage(myWordsInList), arguments: shouldShowAds);
          },
        )
      ],
      cancelButton: CupertinoActionSheetAction(child: const Text('Cancel'), onPressed: () => Get.back()),
    );
  }
}