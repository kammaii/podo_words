
import 'package:cloud_firestore/cloud_firestore.dart';

class Word {
  final String id;
  final int orderId;
  final String front;
  final String back;
  final String pronunciation;
  final String? image;
  final String? audio;

  // --- 사용자 학습 정보 ---
  final DateTime? lastStudied;
  final int reviewCount;

  bool? shouldQuiz;

  static const String ID = 'id';
  static const String ORDER_ID = 'orderId';
  static const String FRONT = 'front';
  static const String BACK = 'back';
  static const String PRONUNCIATION = 'pronunciation';
  static const String IMAGE = 'image';
  static const String AUDIO = 'audio';
  static const String LAST_STUDIED = 'lastStudied';
  static const String REVIEW_COUNT = 'reviewCount';

  Word({
    required this.id,
    required this.orderId,
    required this.front,
    required this.back,
    required this.pronunciation,
    this.audio,
    this.image,
    this.lastStudied,
    this.reviewCount = 0,
  });


  /// Topics/.../Words 컬렉션(단어 원본)으로부터 객체 생성
  factory Word.fromTopicSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Word(
      id: doc.id,
      orderId: data[ORDER_ID],
      front: data[FRONT] ?? '',
      back: data[BACK] ?? '',
      pronunciation: data[PRONUNCIATION] ?? '',
      audio: data[AUDIO],
      image: data[IMAGE],
    );
  }

  /// Users/.../MyWords 컬렉션(사용자 학습 정보)으로부터 객체 생성
  /// 이 객체는 'front', 'back' 등 원본 정보가 비어있음
  factory Word.fromMyWordSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Word(
      id: doc.id,
      orderId: 0,
      front: '',
      back: '',
      pronunciation: '',
      // 학습 정보만 파싱
      lastStudied: (data[LAST_STUDIED] as Timestamp?)?.toDate(),
      reviewCount: data[REVIEW_COUNT] ?? 0,
    );
  }

  ///  두 종류의 데이터를 결합하여 완전한 새 객체를 만드는 메소드
  Word copyWith({
    required int orderId,
    required String front,
    required String back,
    required String pronunciation,
    String? audio,
    String? image,
  }) {
    return Word(
      id: id,
      orderId: orderId,
      front: front,
      back: back,
      pronunciation: pronunciation,
      audio: audio ?? '',
      image: image ?? '',
      lastStudied: lastStudied,
      reviewCount: reviewCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Word && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}