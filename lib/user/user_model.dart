import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String? name;
  final String? fcmToken;
  bool? fcmPermission;
  int currentStreak = 0;
  int maxStreak = 0;
  DateTime? lastStudyDate;
  DateTime signInDate;
  String timezone;
  List<String>? inactiveWords;

  UserModel({
    required this.id,
    this.name,
    this.fcmToken,
    this.fcmPermission,
    required this.currentStreak,
    required this.maxStreak,
    this.lastStudyDate,
    required this.signInDate,
    required this.timezone,
    required this.inactiveWords,
  });

  static const String USERS = 'Users';
  static const String ID = 'id';
  static const String NAME = 'name';
  static const String TIMEZONE = 'timezone';
  static const String CURRENT_STREAK = 'currentStreak';
  static const String MAX_STREAK = 'maxStreak';
  static const String LAST_STUDY_DATE = 'lastStudyDate';
  static const String SIGN_IN_DATE = 'signInDate';
  static const String FCM_TOKEN = 'fcmToken';
  static const String FCM_PERMISSION = 'fcmPermission';
  static const String INACTIVE_WORDS = 'inactiveWords';

  // --- Firestore 데이터 변환을 위한 팩토리 생성자 ---
  factory UserModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return UserModel(
      id: doc.id,
      name: data[NAME],
      fcmToken: data[FCM_TOKEN],
      fcmPermission: data[FCM_PERMISSION],
      currentStreak: data[CURRENT_STREAK] ?? 0,
      maxStreak: data[MAX_STREAK] ?? 0,
      lastStudyDate: (data[LAST_STUDY_DATE] as Timestamp?)?.toDate(),
      signInDate: (data[SIGN_IN_DATE] as Timestamp).toDate(),
      timezone: data[TIMEZONE],
      inactiveWords: List<String>.from(data[INACTIVE_WORDS] ?? []),
    );
  }
}
