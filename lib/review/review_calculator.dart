import '../learning/models/word_model.dart';

// 복습 우선순위를 나타내는 열거형(enum)
enum ReviewPriority { Urgent, Recommended, Good }

class ReviewCalculator {
  // 복습 횟수(key)에 따른 다음 복습 간격(value) 정의
  static const Map<int, Duration> _reviewIntervals = {
    0: Duration(days: 1),    // 학습 직후 (reviewCount = 0) -> 1일 후 복습
    1: Duration(days: 3),    // 1회 복습 후 -> 3일 후 복습
    2: Duration(days: 7),    // 2회 복습 후 -> 7일 후 복습
    3: Duration(days: 15),   // 3회 복습 후 -> 15일 후 복습
    4: Duration(days: 30),   // 4회 복습 후 -> 30일 후 복습
    // 필요에 따라 더 추가...
  };

  /// MyWord 객체를 받아 복습 우선순위를 계산하여 반환합니다.
  ReviewPriority getPriority(Word myWord) {
    final now = DateTime.now();

    // reviewCount에 맞는 복습 간격을 가져옵니다. 5회 이상이면 60일로 고정 (예시)
    final reviewInterval = _reviewIntervals[myWord.reviewCount] ?? const Duration(days: 60);

    // 마지막 학습일로부터 얼마나 지났는지 계산
    print(myWord.front);
    final timeSinceLastStudy = now.difference(myWord.lastStudied!);

    // 복습 시점이 지났는지 여부로 우선순위 결정
    if (timeSinceLastStudy >= reviewInterval) {
      return ReviewPriority.Urgent; // 복습 시점 지남 -> 긴급
    } else if (timeSinceLastStudy.inHours >= reviewInterval.inHours * 0.7) {
      return ReviewPriority.Recommended; // 복습 시점이 70% 이상 경과 -> 추천
    } else {
      return ReviewPriority.Good; // 아직 기억이 생생함 -> 좋음
    }
  }
}