import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:podo_words/database/local_storage_service.dart';
import 'package:podo_words/user/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../learning/models/word.dart';

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

  // 사용자가 MyWords 마이그레이션 대상인지 확인하는 함수
  bool _needsMyWordsMigration() {
    // 1단계: 완료 플래그 확인
    if (LocalStorageService().getBool(LocalStorageService.KEY_MY_WORDS_MIGRATED)) return false;

    // 2단계: 로컬 데이터 확인
    if (LocalStorageService().myWords.isEmpty) return false;

    // 모든 조건을 통과하면 마이그레이션 대상으로 확정
    return true;
  }

  // 마이그레이션 실행 함수
  Future<void> _migrateMyWordsToFirestore(String userId) async {
    List<Word> oldMyWords = LocalStorageService().myWords;

    if (oldMyWords.isEmpty) {
      print("마이그레이션할 'My Words' 데이터가 없습니다.");
      return;
    }

    print("Firestore에서 전체 단어 목록을 가져와 조회용 맵을 생성합니다...");

    // 1. Firestore의 모든 단어를 한 번에 가져와 조회용 맵 생성
    final allWordsSnapshot = await _db.collectionGroup('Words').get();
    final wordLookupMap = <String, String>{}; // Key: 'front|back', Value: wordId
    for (final doc in allWordsSnapshot.docs) {
      final word = Word.fromJson(doc.data());
      final key = '${word.front}|${word.back}';
      wordLookupMap[key] = word.id;
    }

    print("조회용 맵 생성 완료. 로컬 데이터와 비교를 시작합니다...");

    // 2. 일괄 쓰기(Batch) 준비
    final batch = _db.batch();
    final myWordsCollectionRef = _db.collection('Users').doc(userId).collection('MyWords');
    int migratedCount = 0;

    // 3. SharedPreferences의 단어 목록을 순회하며 배치 작업 추가
    for (final oldWord in oldMyWords) {
      final key = '${oldWord.front}|${oldWord.back}';
      final wordId = wordLookupMap[key]; // 맵에서 고유 ID 조회

      if (wordId != null) {
        // 일치하는 ID를 찾았으면, 서브컬렉션에 새로 만들 문서의 참조를 지정
        final newMyWordRef = myWordsCollectionRef.doc(wordId);

        // 저장할 데이터 정의
        final newData = {
          'id': wordId,
          'lastStudied': DateTime.now(),
          'reviewCount': 0,
        };

        // 배치에 'set' 작업 추가
        batch.set(newMyWordRef, newData);
        migratedCount++;
      }
    }

    // 4. 모든 작업이 담긴 배치를 한 번에 커밋(실행)
    if (migratedCount > 0) {
      await batch.commit();
      print("$migratedCount개의 단어를 MyWords 서브컬렉션으로 성공적으로 마이그레이션했습니다.");
    } else {
      print("MyWords 서브컬렉션으로 마이그레이션할 단어가 없습니다.");
    }
  }

  // [통합 실행] 마이그레이션 필요 여부를 확인하고, 필요 시 실행하는 함수
  Future<void> runMyWordsMigrationIfNeeded(String userId) async {
    final bool needsMigration = _needsMyWordsMigration();

    if (needsMigration) {
      print("MyWords 마이그레이션을 시작합니다...");

      try {
        await _migrateMyWordsToFirestore(userId);

        // 마이그레이션 성공 후 플래그 저장
        LocalStorageService().setMyWordsMigrated();
        print("MyWords 마이그레이션이 성공적으로 완료되었습니다.");
      } catch (e) {
        print("MyWords 마이그레이션 중 오류 발생: $e");
      } finally {
        // TODO: 로딩 UI 숨기기
      }
    } else {
      print("MyWords 마이그레이션이 필요하지 않습니다.");
    }
  }
}
