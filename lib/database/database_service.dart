import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:podo_words/learning/models/topic.dart';
import 'package:podo_words/learning/models/word.dart';

class DatabaseService {

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const int topicsPerPage = 20;

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
}
