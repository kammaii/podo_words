import 'package:flutter/material.dart';
import 'package:podo_words/common/my_colors.dart';
import 'package:podo_words/review/review_calculator.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../learning/models/myword_model.dart';

class ReviewWordTile extends StatelessWidget {
  final MyWord myWord;
  final ReviewPriority priority;

  const ReviewWordTile({
    required this.myWord,
    required this.priority,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Color priorityColor;
    final String priorityText;
    final IconData priorityIcon;
    final double percent;

    switch (priority) {
      case ReviewPriority.Urgent:
        priorityColor = MyColors().red;
        priorityText = 'Review Now!';
        priorityIcon = Icons.local_fire_department;
        percent = 1.0;
        break;
      case ReviewPriority.Recommended:
        priorityColor = MyColors().mustard;
        priorityText = 'Recommended';
        priorityIcon = Icons.recommend;
        percent = 0.75;
        break;
      case ReviewPriority.Good:
        priorityColor = MyColors().green;
        priorityText = 'Good';
        priorityIcon = Icons.check_circle;
        percent = 0.25;
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(myWord.front, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(myWord.back, style: const TextStyle(fontSize: 18)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(priorityIcon, color: priorityColor, size: 20),
                const SizedBox(width: 8),
                Text(priorityText, style: TextStyle(color: priorityColor, fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('Reviewed: ${myWord.reviewCount} times', style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),
            LinearPercentIndicator(
              percent: percent,
              lineHeight: 8.0,
              backgroundColor: priorityColor.withOpacity(0.2),
              progressColor: priorityColor,
              barRadius: const Radius.circular(4),
            ),
          ],
        ),
      ),
    );
  }
}