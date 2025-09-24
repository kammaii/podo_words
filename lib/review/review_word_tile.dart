import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:podo_words/common/my_colors.dart';
import 'package:podo_words/review/review_calculator.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:podo_words/user/user_service.dart';
import 'package:swipe_to/swipe_to.dart';

import '../learning/controllers/audio_controller.dart';
import '../learning/models/myword_model.dart';
import '../user/user_controller.dart';

class ReviewWordTile extends StatelessWidget {
  final MyWord myWord;
  final ReviewPriority priority;
  final bool isActive;

  ReviewWordTile({
    super.key,
    required this.myWord,
    required this.priority,
    required this.isActive,
  });

  final userController = Get.find<UserController>();


  @override
  Widget build(BuildContext context) {
    final userService = UserService();
    final userId = userController.user.value?.id;
    final Color priorityColor;
    final double percent;
    final Widget swipeBackground;

    void onSwipeCallback() {
      if (userId == null) return;
      // 현재 상태에 따라 반대되는 작업을 수행
      if (isActive) {
        userService.addInactiveWord(userId, myWord.id);
      } else {
        userService.removeInactiveWord(userId, myWord.id);
      }
    }

    if(isActive) {
      swipeBackground = Padding(padding: EdgeInsets.only(left: 20), child: Icon(Icons.visibility_off, color: Colors.red));
      switch (priority) {
        case ReviewPriority.Urgent:
          priorityColor = MyColors().red;
          percent = 0.1; // 완전히 비어 보이지 않도록 약간의 값을 줌
          break;
        case ReviewPriority.Recommended:
          priorityColor = MyColors().mustard;
          percent = 0.5;
          break;
        case ReviewPriority.Good:
          priorityColor = MyColors().green;
          percent = 1.0;
          break;
      }
    } else {
      swipeBackground = Padding(padding: EdgeInsets.only(left: 20), child: Icon(Icons.visibility, color: Colors.green));
      priorityColor = Colors.grey.shade400;
      percent = 0;
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
                  radius: 22.0,
                  lineWidth: 5.0,
                  percent: percent,
                  center: !isActive
                      ? Icon(Icons.visibility_off, color: priorityColor, size: 20)
                      : Text(
                    '${(percent * 100).toInt()}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: priorityColor,
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