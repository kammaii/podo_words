import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:podo_words/learning/models/topic.dart';
import 'package:podo_words/learning/models/word.dart';

class DatabaseService {

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const int topicsPerPage = 10;

  // 사용자의 문서 변경을 실시간으로 감지하는 Stream을 반환합니다.
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamUser(String userId) {
    return _db.collection('Users').doc(userId).snapshots();
  }

  Future<void> addInactiveWord(String userId, String wordId) {
    final userDocRef = _db.collection('Users').doc(userId);

    // 'inactiveWords' 필드에 wordId를 배열 요소로 추가(Union)합니다.
    //  arrayUnion은 배열에 해당 요소가 이미 존재하면 아무 작업도 하지 않습니다.
    return userDocRef.update({
      'inactiveWords': FieldValue.arrayUnion([wordId]),
    });
  }

  Future<void> removeInactiveWord(String userId, String wordId) {
    final userDocRef = _db.collection('Users').doc(userId);

    // arrayRemove는 배열 필드에서 해당 요소와 일치하는 모든 값을 제거합니다.
    return userDocRef.update({
      'inactiveWords': FieldValue.arrayRemove([wordId]),
    });
  }

  Future<Map<String, dynamic>> getTopicsPaginated({DocumentSnapshot? lastTopicDoc}) async {

    // 1. 쿼리 구성
    Query query = _db
        .collection('Topics')
        .where('isReleased', isEqualTo: true) // [추가] 공개된 토픽만 필터링
        .orderBy('orderId') // orderId 필드로 정렬
        .limit(topicsPerPage);

    // 2. 두 번째 페이지부터는 startAfterDocument 사용
    if (lastTopicDoc != null) {
      query = query.startAfterDocument(lastTopicDoc);
    }

    // 3. 쿼리 실행
    final snapshot = await query.get();

    // 4. Topic 객체로 변환
    final topics = snapshot.docs
        .map((doc) => Topic.fromJson(doc.data() as Map<String, dynamic>))
        .toList();

    // 5. 결과 반환
    return {
      'topics': topics,
      'lastDoc': snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
    };
  }

  Future<List<Word>> getWordsForTopic(String topicId) async {
    final snapshot = await _db
        .collection('Topics')
        .doc(topicId)
        .collection('Words')
        .where('isReleased', isEqualTo: true) // 공개된 단어만 필터링
        .orderBy('orderId') // 단어 순서대로 정렬
        .get();

    return snapshot.docs
        .map((doc) => Word.fromJson(doc.data()))
        .toList();
  }

  Future<int> getTotalWordCount() async {
    // collectionGroup을 사용해 모든 'Words' 하위 컬렉션을 대상으로 쿼리
    final snapshot = await _db
        .collectionGroup('Words')
        .where('isReleased', isEqualTo: true)
        .count()
        .get();

    return snapshot.count ?? 0;
  }


  Future<void> migrateMyWordsToFirestore(String userId, List<Word> oldMyWords) async {
    if (oldMyWords.isEmpty) {
      print("마이그레이션할 'My Words' 데이터가 없습니다.");
      return;
    }

    print("Firestore에서 전체 단어 목록을 가져와 조회용 맵을 생성합니다...");

    // 1. Firestore의 모든 단어를 한 번에 가져와 조회용 맵 생성 (기존과 동일)
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
          'lastStudied': FieldValue.serverTimestamp(), // 서버 시간 기준 현재 시각
          'reviewCount': 0,
          'level': 1, // 망각 곡선을 위한 초기 레벨
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
}
