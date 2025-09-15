import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:podo_words/user/user_model.dart';

class UserService {
  final _db = FirebaseFirestore.instance;
  final _messaging = FirebaseMessaging.instance;
  final String _collection = 'Users';

  // 사용자 정보 스트림 (UserController에서 사용)
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamUser(String userId) {
    return _db.collection(_collection).doc(userId).snapshots();
  }

  // 사용자 정보 가져오기 (초기화 시 사용)
  Future<DocumentSnapshot<Map<String, dynamic>>> getUser(String userId) {
    return _db.collection(_collection).doc(userId).get();
  }

  // 새로운 사용자 생성
  Future<void> createUser(String userId) async {
    final newUser = {
      UserModel.ID: userId,
      UserModel.FCM_PERMISSION: await fcmRequest(),
      UserModel.FCM_TOKEN: await FirebaseMessaging.instance.getToken(),
      UserModel.CURRENT_STREAK: 0,
      UserModel.MAX_STREAK: 0,
      UserModel.SIGN_IN_DATE: DateTime.now(),
      UserModel.TIMEZONE: await FlutterTimezone.getLocalTimezone(),
    };
    await _db.collection(_collection).doc(userId).set(newUser);
  }

  // 사용자 정보 업데이트
  Future<void> updateUser(String userId, Map<String, dynamic> data) {
    return _db.collection(_collection).doc(userId).update(data);
  }

  Future<bool> fcmRequest() async {
    final settings = await _messaging.requestPermission();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  Future<bool> getFcmPermission() async {
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  Future<String?> getFcmToken() async {
    try {
      final token = await _messaging.getToken();
      print('FCM Token: $token');
      return token;
    } catch (e) {
      print('FCM 토큰을 가져오는 데 실패했습니다: $e');
      return null;
    }
  }

  Future<void> addInactiveWord(String userId, String wordId) {
    return _db.collection(_collection).doc(userId).update({
      UserModel.INACTIVE_WORDS: FieldValue.arrayUnion([wordId]),
    });
  }

  Future<void> removeInactiveWord(String userId, String wordId) {
    return _db.collection(_collection).doc(userId).update({
      UserModel.INACTIVE_WORDS: FieldValue.arrayRemove([wordId]),
    });
  }
}