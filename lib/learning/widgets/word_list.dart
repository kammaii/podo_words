import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:podo_words/common/my_colors.dart';
import 'package:swipe_to/swipe_to.dart';
import '../../user/user_service.dart';
import '../controllers/audio_controller.dart';
import '../models/word_model.dart';

class WordList extends StatelessWidget {
  final Word word;
  final bool isActive;
  final bool isDeleteMode;
  final Color fontColor;
  final bool? isChecked;
  final ValueChanged<bool?>? onCheckboxChanged;

  const WordList({
    required this.word,
    required this.isActive,
    required this.isDeleteMode,
    required this.fontColor,
    this.isChecked,
    this.onCheckboxChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final double leftMargin = isDeleteMode ? 50.0 : 0.0;
    final Color textColor = isActive ? fontColor : Colors.grey;
    final Color backColor = isActive ? Colors.white : Colors.white30;

    final userService = UserService();
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      height: 80.0,
      child: SwipeTo(
        // 단어 비활성화
        onLeftSwipe: (detail) {
          if (userId != null) {
            userService.addInactiveWord(userId, word.id);
          }
        },
        // 단어 활성화
        onRightSwipe: (detail) {
          if (userId != null) {
            userService.removeInactiveWord(userId, word.id);
          }
        },
        rightSwipeWidget: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          color: Colors.green.shade100,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [Icon(Icons.check, color: Colors.green)],
          ),
        ),
        leftSwipeWidget: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          color: Colors.red.shade100,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [Icon(Icons.cancel_outlined, color: Colors.red)],
          ),
        ),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            // 삭제 모드일 때만 체크박스 표시
            if (isDeleteMode)
              Checkbox(
                value: isChecked,
                onChanged: onCheckboxChanged,
              ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.only(left: leftMargin),
              child: Card(
                color: backColor,
                child: InkWell(
                  onTap: () {
                    if (isDeleteMode) {
                      onCheckboxChanged?.call(!isChecked!);
                    } else {
                      AudioController().playWordAudio(word);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            word.front,
                            style: TextStyle(color: textColor, fontSize: 20.0),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: VerticalDivider(
                            color: MyColors().greenLight,
                            thickness: 1.0,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            word.back,
                            style: TextStyle(color: textColor, fontSize: 20.0),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}