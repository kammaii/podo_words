import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

class User {
  User._init();
  static final User _instance = User._init();
  factory User() => _instance;

  late String id;
  String? name;
  String? fcmToken;
  late bool fcmPermission;
  int currentStreak = 0;
  int maxStreak = 0;
  DateTime? lastStudyDate;
  late DateTime signInDate;
  late String timezone;

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

  Future<bool> fcmRequest() async {
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission();
    if(settings.authorizationStatus == AuthorizationStatus.authorized) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> getFcmPermission() async {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    bool permission = settings.authorizationStatus == AuthorizationStatus.authorized;
    print('GET FCM Permission: $permission');
    return permission;
  }


  Future<void> initUser(String userId) async {
    id = userId;
    final docRef = FirebaseFirestore.instance.collection(USERS).doc(id);
    final snapshot = await docRef.get();

    if(snapshot.exists) {
      print('유저 DB를 불러옵니다.');
      final data = snapshot.data()!;
      name = data[NAME] ?? '';
      currentStreak = data[CURRENT_STREAK];
      maxStreak = data[MAX_STREAK];
      if(data[LAST_STUDY_DATE] != null) {
        Timestamp stamp = data[LAST_STUDY_DATE];
        lastStudyDate = stamp.toDate();
      }
      signInDate = DateTime.now();
      fcmPermission = await getFcmPermission();
      fcmToken = await FirebaseMessaging.instance.getToken();
      timezone = await FlutterTimezone.getLocalTimezone();
      print('타임존: $timezone');
      Map<String, dynamic> updateDate = {
        SIGN_IN_DATE: signInDate,
        FCM_PERMISSION: fcmPermission,
        FCM_TOKEN: fcmToken,
        TIMEZONE: timezone,
      };
      docRef.update(updateDate);

    } else {
      print('새 유저 DB를 만듭니다.');
      Map<String, dynamic> newUser = {
        ID: id,
        FCM_PERMISSION: await fcmRequest(),
        FCM_TOKEN: await FirebaseMessaging.instance.getToken(),
        CURRENT_STREAK: 0,
        MAX_STREAK: 0,
        SIGN_IN_DATE: DateTime.now(),
        TIMEZONE: await FlutterTimezone.getLocalTimezone(),
      };
      docRef.set(newUser);
    }
  }
}