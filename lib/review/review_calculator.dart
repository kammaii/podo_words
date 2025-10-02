import '../learning/models/word_model.dart';

// 복습 우선순위를 나타내는 열거형(enum)
enum ReviewPriority { Urgent, Recommended, Good }

class ReviewStatus {
  final ReviewPriority priority;
  final double memoryPercent;

  ReviewStatus({required this.priority, required this.memoryPercent});
}

class ReviewCalculator {
  // 복습 횟수(key)에 따른 다음 복습 간격(value) 정의
  static const Map<int, Duration> _reviewIntervals = {
    0: Duration(days: 1),    // 학습 직후 (reviewCount = 0) -> 1일 후 복습
    1: Duration(days: 3),    // 1회 복습 후 -> 3일 후 복습
    2: Duration(days: 7),    // 2회 복습 후 -> 7일 후 복습
    3: Duration(days: 15),   // 3회 복습 후 -> 15일 후 복습
    4: Duration(days: 30),   // 4회 복습 후 -> 30일 후 복습
    5: Duration(days: 60),   // 5회 복습 후 -> 60일 후 복습
    // 필요에 따라 더 추가...
  };

  ///  MyWord 객체를 받아 ReviewStatus(우선순위 + 퍼센트)를 반환
  ReviewStatus getStatus(Word myWord) {
    final now = DateTime.now();
    final reviewInterval = _reviewIntervals[myWord.reviewCount] ?? const Duration(days: 60);
    final timeSinceLastStudy = now.difference(myWord.lastStudied!);

    // --- 기억 강도(%) 계산 ---
    // (전체 복습 간격 - 경과 시간) / 전체 복습 간격
    double memoryPercent = (reviewInterval.inDays - timeSinceLastStudy.inDays) / reviewInterval.inDays;
    // 결과값이 0.0 ~ 1.0 범위 안에 있도록 보정
    memoryPercent = memoryPercent.clamp(0.0, 1.0);

    // --- 우선순위(enum) 결정 ---
    final ReviewPriority priority;
    if (memoryPercent < 0.2) {
      priority = ReviewPriority.Urgent;
    } else if (memoryPercent < 0.6) {
      priority = ReviewPriority.Recommended;
    } else {
      priority = ReviewPriority.Good;
    }

    return ReviewStatus(priority: priority, memoryPercent: memoryPercent);
  }
}