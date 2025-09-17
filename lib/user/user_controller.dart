import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:podo_words/user/user_model.dart';
import 'package:podo_words/user/user_service.dart';

// 앱 전역에서 사용자 상태를 관리
class UserController extends GetxController {
  final _userService = UserService();
  StreamSubscription? _userSubscription;

  final Rxn<UserModel> user = Rxn<UserModel>();

  // WordListPage 에서 inactiveWordIds의 변경에만 Obx()가 반응하도록 하기 위해 변수를 따로 만듦.
  final RxSet<String> inactiveWordIds = <String>{}.obs;

  // 사용자가 로그인했을 때 호출되어 사용자 데이터를 초기화하고 실시간 구독을 시작합니다.
  Future<void> initUser(String userId) async {
    // 기존 구독이 있다면 취소
    _userSubscription?.cancel();

    final userDoc = await _userService.getUser(userId);
    final now = DateTime.now();

    if (userDoc.exists) {
      // --- 기존 사용자일 경우 ---
      print('기존 사용자($userId) 데이터를 불러옵니다.');

      // Streak 연속 기록 확인
      final lastStudyTimestamp = userDoc.data()![UserModel.LAST_STUDY_DATE] as Timestamp?;
      if (lastStudyTimestamp != null) {
        final lastStudyDate = lastStudyTimestamp.toDate();
        final today = DateTime(now.year, now.month, now.day);
        final yesterday = today.subtract(const Duration(days: 1));
        final lastDate = DateTime(lastStudyDate.year, lastStudyDate.month, lastStudyDate.day);

        if (lastDate.isBefore(yesterday)) {
          print('연속 학습 기록이 중단되었습니다. streak를 0으로 초기화합니다.');
          await _userService.updateUser(userId, {
            UserModel.CURRENT_STREAK: 0,
          });
        }
      }

      // FCM 토큰, 타임존 등 로그인 시마다 업데이트가 필요한 정보들
      final fcmPermission = await _userService.getFcmPermission();
      final fcmToken = await _userService.getFcmToken();
      final timezone = await FlutterTimezone.getLocalTimezone();

      await _userService.updateUser(userId, {
        UserModel.SIGN_IN_DATE: now,
        UserModel.FCM_PERMISSION: fcmPermission,
        UserModel.FCM_TOKEN: fcmToken,
        UserModel.TIMEZONE: timezone,
      });

    } else {
      // --- 신규 사용자일 경우 ---
      print('새 사용자($userId)를 생성합니다.');
      await _userService.createUser(userId);
    }

    // MyWords 마이그레이션
    await _userService.runMyWordsMigrationIfNeeded(userId);

    // 사용자 데이터의 실시간 스트림 구독 시작
    _listenToUser(userId);
  }

  void _listenToUser(String userId) {
    _userSubscription?.cancel();
    _userSubscription = _userService.streamUser(userId).listen((snapshot) {
      if (snapshot.exists) {
        final userModel = UserModel.fromSnapshot(snapshot);
        user.value = userModel;
        inactiveWordIds.assignAll(userModel.inactiveWords.toSet());
      }
    });
  }

  // 오늘 학습을 진행했는지 여부를 반환합니다.
  bool get hasStudyToday {
    if (user.value!.lastStudyDate == null) return false;

    final now = DateTime.now();
    // lastStudyDate를 현재 시간대 기준으로 변환할 필요 없이, 날짜만 비교
    return now.year == user.value!.lastStudyDate!.year &&
        now.month == user.value!.lastStudyDate!.month &&
        now.day == user.value!.lastStudyDate!.day;
  }

  // 학습 연속 기록 업데이트 로직
  Future<void> updateStreak() async {
    if (user.value == null || hasStudyToday) return;

    final now = DateTime.now();
    int newStreak = user.value!.currentStreak + 1;
    int newMaxStreak = (newStreak > user.value!.maxStreak) ? newStreak : user.value!.maxStreak;

    await _userService.updateUser(user.value!.id, {
      UserModel.LAST_STUDY_DATE: now,
      UserModel.CURRENT_STREAK: newStreak,
      UserModel.MAX_STREAK: newMaxStreak,
    });
  }

  int get currentStreak {
    return user.value!.currentStreak;
  }

  int get maxStreak {
    return user.value!.maxStreak;
  }

  // 특정 단어를 비활성 목록에 추가합니다.
  void addInactiveWord(String wordId) {
    if (user.value == null) return;
    _userService.addInactiveWord(user.value!.id, wordId);
  }

  // 특정 단어를 비활성 목록에서 제거합니다.
  void removeInactiveWord(String wordId) {
    if (user.value == null) return;
    _userService.removeInactiveWord(user.value!.id, wordId);
  }

  // 로그아웃 또는 컨트롤러 종료 시 스트림 구독을 취소합니다.
  void disposeUserSubscription() {
    _userSubscription?.cancel();
    user.value = null;
    inactiveWordIds.clear();
    print('사용자 정보 스트림 구독이 해제되었습니다.');
  }

  @override
  void onClose() {
    _userSubscription?.cancel();
    super.onClose();
  }
}