import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:podo_words/common/my_colors.dart';
import 'package:podo_words/review/review_calculator.dart';
import 'package:podo_words/user/user_service.dart';
import 'package:swipe_to/swipe_to.dart';

import '../learning/controllers/audio_controller.dart';
import '../learning/models/word_model.dart';
import '../user/user_controller.dart';

class ReviewWordTile extends StatelessWidget {
  final Word myWord;
  final ReviewStatus status;
  final bool isActive;

  ReviewWordTile({
    super.key,
    required this.myWord,
    required this.status,
    required this.isActive,
  });

  final userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    final userService = UserService();
    final userId = userController.user.value?.id;
    final priority = status.priority;
    final percent = status.memoryPercent;
    final Widget swipeBackground;
    final Color priorityColor;

    void onSwipeCallback() {
      if (userId == null) return;
      if (Get.isSnackbarOpen) {
        Get.back();
      }

      // 현재 상태에 따라 반대되는 작업을 수행
      if (isActive) {
        userController.addInactiveWord(myWord.id);
        Get.snackbar(
          "'${myWord.front}' is deactivated.", // 제목
          "Click 'undo' to reactivate.", // 내용
          mainButton: TextButton(
            onPressed: () {
              // '실행 취소' 버튼을 누르면 컨트롤러의 undo 함수 호출
              userController.undoDeactivateWord();
              if (Get.isSnackbarOpen) {
                Get.back();
              }
            },
            child: const Text('Undo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black.withAlpha(200),
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      } else {
        userService.removeInactiveWord(userId, myWord.id);
      }
    }

    if (isActive) {
      swipeBackground =
          Padding(padding: EdgeInsets.only(left: 20), child: Icon(Icons.visibility_off, color: Colors.red));
      switch (priority) {
        case ReviewPriority.Urgent:
          priorityColor = MyColors().red;
          break;
        case ReviewPriority.Recommended:
          priorityColor = MyColors().mustard;
          break;
        case ReviewPriority.Good:
          priorityColor = MyColors().green;
          break;
      }
    } else {
      swipeBackground =
          Padding(padding: EdgeInsets.only(left: 20), child: Icon(Icons.visibility, color: Colors.green));
      priorityColor = Colors.grey.shade400;
    }

    return SwipeTo(
      onLeftSwipe: (details) => onSwipeCallback(),
      onRightSwipe: (details) => onSwipeCallback(),
      leftSwipeWidget: swipeBackground,
      rightSwipeWidget: swipeBackground,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        elevation: 2,
        color: isActive ? Colors.white : Colors.grey.shade100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          // 카드 왼쪽에 우선순위 색상으로 테두리 효과
          side: BorderSide(color: priorityColor, width: 1),
        ),
        child: InkWell(
          onTap: () {
            if (myWord.audio != null) {
              AudioController().playWordAudio(myWord);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                CircularPercentIndicator(
                  radius: 24.0,
                  lineWidth: 5.0,
                  percent: isActive ? percent : 0.0,
                  center: !isActive
                      ? Icon(Icons.visibility_off, color: priorityColor, size: 20)
                      : FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: Text(
                              '${(percent * 100).toInt()}%',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: priorityColor,
                              ),
                            ),
                          ),
                        ),
                  progressColor: priorityColor,
                  backgroundColor: priorityColor.withAlpha(50),
                  circularStrokeCap: CircularStrokeCap.round,
                  animation: true,
                ),
                const SizedBox(width: 16),

                // 2. 중앙: 단어 정보 (front, back)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        myWord.front,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          decoration: isActive ? TextDecoration.none : TextDecoration.lineThrough,
                          color: isActive ? Colors.black87 : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        myWord.back,
                        style: TextStyle(
                          fontSize: 16,
                          color: isActive ? Colors.black54 : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // 3. 오른쪽: 복습 횟수 및 오디오 버튼
                if (myWord.audio != null)
                  IconButton(
                    icon: Icon(Icons.volume_up, color: MyColors().purple),
                    onPressed: () {
                      if (myWord.audio != null) {
                        AudioController().playWordAudio(myWord);
                      }
                    },
                  ),
                Text(
                  'x${myWord.reviewCount}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
