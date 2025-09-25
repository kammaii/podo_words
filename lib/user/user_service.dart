import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:podo_words/database/local_storage_service.dart';
import 'package:podo_words/user/user_model.dart';

import '../learning/models/word_model.dart';

class UserService {
  final _db = FirebaseFirestore.instance;
  final _messaging = FirebaseMessaging.instance;

  final String KEY_IN_ACTIVE_WORDS = 'inActiveWords';
  final String KEY_MY_WORDS = 'myWords';
  final String USERS = 'Users';
  final String MY_WORDS = 'MyWords';

  /// 여러 단어의 복습 기록(lastStudied, reviewCount)을 일괄 업데이트합니다.
  /// 단, 오늘 이미 학습한 단어는 업데이트하지 않습니다.
  Future<void> updateMyWordsProgress(String userId, List<Word> reviewedWords) async {
    if (reviewedWords.isEmpty) return;

    final batch = _db.batch();
    final myWordsRef = _db.collection(USERS).doc(userId).collection(MY_WORDS);
    int updateCount = 0;

    for (final word in reviewedWords) {
      if (word.lastStudied != null && _isToday(word.lastStudied!)) {
        continue;
      }

      final docRef = myWordsRef.doc(word.id);
      batch.update(docRef, {
        Word.LAST_STUDIED: FieldValue.serverTimestamp(),
        Word.REVIEW_COUNT: FieldValue.increment(1),
      });
      updateCount++;
    }

    if(updateCount > 0) {
      await batch.commit();
      print("${reviewedWords.length}개 단어의 복습 기록이 업데이트되었습니다.");
    } else {
      print("업데이트할 복습이 없습니다.");
    }
  }

  ///  주어진 날짜가 오늘인지 확인하는 헬퍼 함수
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  /// 이미 추가된 단어는 제외하고, 새로 추가된 단어의 개수를 반환합니다.
  Future<int> addNewlyLearnedWords(String userId, List<Word> newWords) async {
    if (newWords.isEmpty) return 0;

    final myWordsRef = _db.collection(USERS).doc(userId).collection(MY_WORDS);

    // 1. 기존에 학습한 단어 ID들을 먼저 가져옵니다.
    final existingWordsSnapshot = await myWordsRef.get();
    final existingWordIds = existingWordsSnapshot.docs.map((doc) => doc.id).toSet();

    // 2. 일괄 쓰기(Batch) 준비
    final batch = _db.batch();
    int newlyAddedCount = 0;

    for (final word in newWords) {
      // 3. 아직 학습하지 않은 새로운 단어인지 확인
      if (!existingWordIds.contains(word.id)) {
        final newMyWordRef = myWordsRef.doc(word.id);
        final newData = {
          Word.ID: word.id,
          Word.LAST_STUDIED: FieldValue.serverTimestamp(),
          Word.REVIEW_COUNT: 0,
        };
        batch.set(newMyWordRef, newData);
        newlyAddedCount++;
      }
    }

    // 4. 새로운 단어가 있을 경우에만 배치 커밋
    if (newlyAddedCount > 0) {
      await batch.commit();
    }

    return newlyAddedCount;
  }

  /// 사용자의 MyWords 서브컬렉션에서 여러 단어를 일괄 삭제합니다.
  Future<void> removeMyWords(String userId, List<String> wordIdsToDelete) {
    if (wordIdsToDelete.isEmpty) return Future.value();

    final batch = _db.batch();
    final myWordsRef = _db.collection(USERS).doc(userId).collection(MY_WORDS);

    for (final wordId in wordIdsToDelete) {
      batch.delete(myWordsRef.doc(wordId));
    }

    return batch.commit();
  }

  /// 주어진 ID 목록에 해당하는 Word 문서들을 실시간으로 감지
  Stream<List<Word>> streamWordsByIds(List<String> wordIds) {
    if (wordIds.isEmpty) {
      return Stream.value([]); // ID 목록이 비어있으면 빈 스트림 반환
    }
    // 'whereIn' 쿼리는 한 번에 최대 30개의 ID를 조회할 수 있습니다.
    // 실제 프로덕션에서는 30개씩 나누어 여러 번 쿼리하는 로직이 필요할 수 있습니다.
    return _db
        .collectionGroup('Words')
        .where('id', whereIn: wordIds)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Word.fromTopicSnapshot(doc)).toList());
  }

  Stream<List<Word>> streamMyWords(String userId) {
    return _db
        .collection(USERS)
        .doc(userId)
        .collection(MY_WORDS) // MyWords 서브컬렉션 경로
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Word.fromMyWordSnapshot(doc)).toList());
  }

  // 사용자 정보 스트림 (UserController에서 사용)
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamUser(String userId) {
    return _db.collection(USERS).doc(userId).snapshots();
  }

  // 사용자 정보 가져오기 (초기화 시 사용)
  Future<DocumentSnapshot<Map<String, dynamic>>> getUser(String userId) {
    return _db.collection(USERS).doc(userId).get();
  }

  // 새로운 사용자 생성
  Future<void> createUser(String userId) async {
    final newUser = {
      UserModel.ID: userId,
      UserModel.FCM_PERMISSION: await fcmRequest(),
      UserModel.FCM_TOKEN: await FirebaseMessaging.instance.getToken(),
      UserModel.CURRENT_STREAK: 0,
      UserModel.MAX_STREAK: 0,
      UserModel.SIGN_IN_DATE: FieldValue.serverTimestamp(),
      UserModel.TIMEZONE: await FlutterTimezone.getLocalTimezone(),
    };
    await _db.collection(USERS).doc(userId).set(newUser);
  }

  // 사용자 정보 업데이트
  Future<void> updateUser(String userId, Map<String, dynamic> data) {
    return _db.collection(USERS).doc(userId).update(data);
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
    return _db.collection(USERS).doc(userId).update({
      UserModel.INACTIVE_WORDS: FieldValue.arrayUnion([wordId]),
    });
  }

  Future<void> removeInactiveWord(String userId, String wordId) {
    return _db.collection(USERS).doc(userId).update({
      UserModel.INACTIVE_WORDS: FieldValue.arrayRemove([wordId]),
    });
  }

  // 사용자가 MyWords 마이그레이션 대상인지 확인하는 함수
  bool _needsMyWordsMigration() {
    print('1. 마이그레이션 키: ${LocalStorageService().getBool(LocalStorageService.KEY_MY_WORDS_MIGRATED)}');
    // 1단계: 완료 플래그 확인
    if (LocalStorageService().getBool(LocalStorageService.KEY_MY_WORDS_MIGRATED)) return false;

    print('2. 로컬마이월드: ${LocalStorageService().getStringList(KEY_IN_ACTIVE_WORDS).isEmpty}');
    // 2단계: 로컬 데이터 확인
    if (LocalStorageService().getStringList(KEY_IN_ACTIVE_WORDS).isEmpty) return false;

    // 모든 조건을 통과하면 마이그레이션 대상으로 확정
    return true;
  }

  // 마이그레이션 실행 함수
  Future<void> _migrateMyWordsToFirestore(String userId) async {
    final List<String> myWordsJson = LocalStorageService().getStringList(KEY_MY_WORDS);
    final List<String> inactiveFronts = LocalStorageService().getStringList(KEY_IN_ACTIVE_WORDS);

    // MyWords 데이터 변환
    final List<String> oldMyWordKeys = [];
    if (myWordsJson.isNotEmpty) {
      for (int i = 0; i < myWordsJson.length; i++) {
        final myWordJson = json.decode(myWordsJson[i]);
        final front = myWordJson[Word.FRONT] as String;
        final back = myWordJson[Word.BACK] as String;
        oldMyWordKeys.add('$front|$back');
      }
    } else {
      print("마이그레이션할 데이터가 없습니다.");
      return;
    }

    print("Firestore에서 전체 단어 목록을 가져와 조회용 맵을 생성합니다...");

    // 1. Firestore의 모든 단어를 한 번에 가져와 조회용 맵 생성
    final allWordsSnapshot = await _db.collectionGroup('Words').get();
    final wordLookupMap = <String, String>{}; // Key: 'front|back', Value: wordId
    for (final doc in allWordsSnapshot.docs) {
      final word = Word.fromTopicSnapshot(doc);
      final key = '${word.front}|${word.back}';
      wordLookupMap[key] = word.id;
    }

    print("조회용 맵 생성 완료. 로컬 데이터와 비교를 시작합니다...");

    // 2. 일괄 쓰기(Batch) 준비
    final batch = _db.batch();
    final userDocRef = _db.collection(USERS).doc(userId);
    ;
    int migratedCount = 0;

    // 3-1. MyWords 마이그레이션 작업 추가
    final myWordsCollectionRef = userDocRef.collection(MY_WORDS);
    for (final key in oldMyWordKeys) {
      final wordId = wordLookupMap[key]; // 맵에서 고유 ID 조회

      if (wordId != null) {
        // 일치하는 ID를 찾았으면, 서브컬렉션에 새로 만들 문서의 참조를 지정
        final newMyWordRef = myWordsCollectionRef.doc(wordId);

        // 저장할 데이터 정의
        final newData = {
          Word.ID: wordId,
          Word.LAST_STUDIED: FieldValue.serverTimestamp(),
          Word.REVIEW_COUNT: 0,
        };

        // 배치에 'set' 작업 추가
        batch.set(newMyWordRef, newData);
        migratedCount++;
      }
    }

    // 3-2. inactiveWords 마이그레이션 작업 추가
    final List<String> inactiveWordIds = [];
    for (final front in inactiveFronts) {
      // inactiveWords는 front만 있으므로, 맵의 키와 부분 일치하는 것을 찾아야 함
      // (주의: 동음이의어가 있을 경우 첫 번째로 찾아지는 단어의 id를 사용하게 됨)
      final matchingKey = wordLookupMap.keys.firstWhere((k) => k.startsWith('$front|'), orElse: () => '');
      if (matchingKey.isNotEmpty) {
        inactiveWordIds.add(wordLookupMap[matchingKey]!);
      }
    }

    if (inactiveWordIds.isNotEmpty) {
      // Users 문서의 inactiveWords 필드를 업데이트하는 작업을 배치에 추가
      batch.update(userDocRef, {UserModel.INACTIVE_WORDS: inactiveWordIds});
      print("${inactiveWordIds.length}개의 inactiveWords를 마이그레이션 준비 완료.");
    }

    // 4. 모든 작업이 담긴 배치를 한 번에 커밋(실행)
    await batch.commit();
    print("Firestore 배치 작업이 완료되었습니다.");
    if (migratedCount > 0) {
      print("$migratedCount개의 단어를 MyWords 서브컬렉션으로 성공적으로 마이그레이션했습니다.");
    }
  }

  // [통합 실행] 마이그레이션 필요 여부를 확인하고, 필요 시 실행하는 함수
  Future<void> runMyWordsMigrationIfNeeded(String userId) async {
    // todo: final bool needsMigration = _needsMyWordsMigration();
    if (false) {
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
