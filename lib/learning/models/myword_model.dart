// user/my_word_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class MyWord {
  // --- 학습 진행 정보 ---
  final String id;
  final DateTime? lastStudied;
  final int reviewCount;

  // --- 단어 원본 정보 ---
  final String front;
  final String back;
  final String pronunciation;
  final String? audio;
  final String? image;

  static const String LAST_STUDIED = 'lastStudied';
  static const String REVIEW_COUNT = 'reviewCount';

  MyWord({
    // 학습 진행 정보
    required this.id,
    required this.lastStudied,
    required this.reviewCount,
    // 단어 원본 정보 (기본값 설정)
    this.front = '',
    this.back = '',
    this.pronunciation = '',
    this.audio,
    this.image,
  });

  /// Users/../MyWords 서브컬렉션 문서로부터 '학습 진행 정보'만 파싱
  factory MyWord.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    print('아이디: ${doc.id}');
    return MyWord(
      id: doc.id,
      lastStudied: (data[LAST_STUDIED] as Timestamp?)?.toDate(),
      reviewCount: data[REVIEW_COUNT] ?? 0,
    );
  }

  ///  두 종류의 데이터를 결합하여 완전한 새 객체를 만드는 메소드
  MyWord copyWith({
    String? front,
    String? back,
    String? pronunciation,
    String? audio,
    String? image,
  }) {
    return MyWord(
      id: id,
      lastStudied: lastStudied,
      reviewCount: reviewCount,
      front: front ?? this.front,
      back: back ?? this.back,
      pronunciation: pronunciation ?? this.pronunciation,
      audio: audio ?? this.audio,
      image: image ?? this.image,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is MyWord && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}