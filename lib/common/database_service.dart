import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:podo_words/common/topic.dart';
import 'package:podo_words/common/word.dart';

class Database {

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Topic>> getTopics() async {
    QuerySnapshot snapshot = await _db.collection('Topics').get();
    return snapshot.docs.map((doc) => Topic.fromJson(doc.data() as Map<String, dynamic>)).toList();
  }

  Future<List<Word>> getWords(String topicId) async {
    try {
      // 경로: /Topics/{topicId}/Words
      QuerySnapshot snapshot = await _db
          .collection('Topics')
          .doc(topicId)
          .collection('Words')
          .get();

      return snapshot.docs.map((doc) {
        return Word.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();

    } catch (e) {
      // 에러 처리
      print("Error getting words for topic $topicId: $e");
      return []; // 에러 발생 시 빈 리스트 반환
    }
  }
}
