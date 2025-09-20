import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:podo_words/common/my_colors.dart';
import 'package:podo_words/learning/pages/learning_page.dart';
import 'package:podo_words/review/review_calculator.dart';
import 'package:podo_words/review/review_flashcard_page.dart';
import 'package:podo_words/learning/models/word_model.dart';
import 'package:podo_words/learning/widgets/word_list.dart';
import 'package:podo_words/review/review_word_tile.dart';
import 'package:podo_words/user/user_controller.dart';
import '../database/local_storage_service.dart';
import '../learning/models/myword_model.dart';
import '../learning/widgets/show_snack_bar.dart';
import '../user/user_service.dart';



class ReviewListPage extends StatefulWidget {
  @override
  ReviewPageState createState() => ReviewPageState();
}

class ReviewPageState extends State<ReviewListPage> {

// GetX 컨트롤러 및 서비스 인스턴스 가져오기
  final userController = Get.find<UserController>();
  final userService = UserService();

  // 로컬 UI 상태를 관리하는 변수들
  final List<bool> _toggleSelections = [true, false, false];
  String _searchInput = "";
  bool _isDeleteMode = false;
  final Set<String> _wordsToDelete = {}; // 삭제할 단어들의 ID를 저장

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
          final List<MyWord> allMyWords = userController.myWords.toList();
          final Set<String> inactiveWordIds = userController.inactiveWordIds;

          // 2. 검색 및 필터링 로직 적용
          final List<MyWord> myWordsInList;
          if (_searchInput.isNotEmpty) {
            myWordsInList = allMyWords.where((myWord) =>
            myWord.front.toLowerCase().contains(_searchInput.toLowerCase()) ||
                myWord.back.toLowerCase().contains(_searchInput.toLowerCase())).toList();
          } else if (_toggleSelections[1]) { // Active 필터
            myWordsInList = allMyWords.where((myWord) => !inactiveWordIds.contains(myWord.id)).toList();
          } else if (_toggleSelections[2]) { // Inactive 필터
            myWordsInList = allMyWords.where((myWord) => inactiveWordIds.contains(myWord.id)).toList();
          } else { // 'All' 필터 (기본)
            myWordsInList = allMyWords;
          }

          return Scaffold(
            body: Column(
              children: [
                // --- 검색창 및 필터 버튼 UI ---
                Container(
                  decoration: BoxDecoration(
                    color: MyColors().navyLight,
                    borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        focusNode: _focusNode,
                        controller: _textFieldController,
                        decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                borderSide: BorderSide.none),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                borderSide: BorderSide.none),
                            hintText: 'Search your words',
                            filled: true,
                            fillColor: Colors.white
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                              children: [
                                _buildToggleButton(Icons.all_inclusive, 0),
                                _buildToggleButton(Icons.check, 1),
                                _buildToggleButton(Icons.close, 2),
                              ]
                          )
                      ),
                    ],
                  ),
                ),
                // --- 단어 개수 및 안내 문구 ---
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(child: Text(
                          !_isDeleteMode ? '- Swipe to activate/deactivate.' : '- Select words to delete.',
                          style: TextStyle(color: MyColors().purple, fontSize: 15)
                      )),
                      Icon(Icons.assistant_photo_outlined, color: MyColors().purple),
                      Text(myWordsInList.length.toString(), style: TextStyle(fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: MyColors().purple)),
                    ],
                  ),
                ),
                // --- 단어 목록 ---
                Expanded(
                  child: GestureDetector(
                    onLongPress: () {
                      _focusNode.unfocus();
                      setState(() {
                        _isDeleteMode = !_isDeleteMode;
                        if (!_isDeleteMode) _wordsToDelete.clear(); // 삭제 모드 해제 시 선택 초기화
                      });
                    },
                    child: ListView.builder(
                      itemCount: myWordsInList.length,
                      itemBuilder: (context, index) {
                        final myWord = myWordsInList[index];

                        // 1. 각 단어의 복습 우선순위를 계산합니다.
                        final priority = _reviewCalculator.getPriority(myWord);

                        // 2. 새로운 ReviewWordTile 위젯을 반환합니다.
                        return ReviewWordTile(
                          myWord: myWord,
                          priority: priority,
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
                _isDeleteMode ? Icons.delete_forever : Icons.play_arrow_rounded,
                color: _isDeleteMode ? MyColors().red : MyColors().green,
                size: _isDeleteMode ? 40.0 : 50.0,
              ),
              onPressed: () {
                _focusNode.unfocus();

                if (myWordsInList.isNotEmpty) {
                  showCupertinoModalPopup(
                    context: context,
                    builder: (_) => _isDeleteMode ? _deleteBtnClick() : _playBtnClick(myWordsInList),
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

  Widget _buildToggleButton(IconData icon, int toggleIndex) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            backgroundColor: _toggleSelections[toggleIndex] ? MyColors().purple : Colors.white,
            foregroundColor: _toggleSelections[toggleIndex] ? Colors.white : MyColors().navyLight,
            side: BorderSide.none,
          ),
          child: Icon(icon),
          onPressed: () {
            setState(() {
              _textFieldController.clear();
              _focusNode.unfocus();
              for (int i = 0; i < _toggleSelections.length; i++) {
                _toggleSelections[i] = (i == toggleIndex);
              }
            });
          },
        ),
      ),
    );
  }

  CupertinoActionSheet _playBtnClick(List<MyWord> myWordsInList) {

    final shouldShowAds = !userController.user.value!.isPremium;

    return CupertinoActionSheet(
      message: const Text('Select review mode', style: TextStyle(fontSize: 20)),
      actions: [
        CupertinoActionSheetAction(
          child: const Text('Quiz'),
          onPressed: () {
            Get.back();
            if (myWordsInList.length >= 4) {
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

  CupertinoAlertDialog _deleteBtnClick() {
    return CupertinoAlertDialog(
      title: Icon(Icons.delete_forever, size: 50.0, color: MyColors().red),
      content: Text('${_wordsToDelete.length} words will be deleted.\nAre you sure?',
          style: TextStyle(color: MyColors().wine, fontSize: 20.0)),
      actions: [
        CupertinoDialogAction(child: const Text('Cancel'), onPressed: () => Get.back()),
        CupertinoDialogAction(
          isDestructiveAction: true,
          child: const Text('Delete'),
          onPressed: () {
            final userId = userController.user.value?.id;
            if (userId != null && _wordsToDelete.isNotEmpty) {
              // UserService를 통해 Firestore 데이터 삭제
              userService.removeMyWords(userId, _wordsToDelete.toList());
            }
            setState(() {
              _isDeleteMode = false;
              _wordsToDelete.clear();
            });
            Get.back();
          },
        )
      ],
    );
  }
}