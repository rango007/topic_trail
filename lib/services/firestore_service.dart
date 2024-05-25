import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createTopic(
      String topicName, String creatorId, List<Map<String, dynamic>> questions) async {
    String topicId = _db.collection('topics').doc().id;

    await _db.collection('topics').doc(topicId).set({
      'name': topicName,
      'creatorId': creatorId,
    });

    for (var question in questions) {
      await _db
          .collection('topics')
          .doc(topicId)
          .collection('questions')
          .doc(question['id'])
          .set(question);
    }
  }

  Stream<QuerySnapshot> getTopics() {
    return _db.collection('topics').snapshots();
  }

  Future<DocumentSnapshot> getInitialQuestion(String topicId) async {
    return await _db
        .collection('topics')
        .doc(topicId)
        .collection('questions')
        .limit(1)
        .get()
        .then((querySnapshot) => querySnapshot.docs.first);
  }

  Future<DocumentSnapshot> getQuestion(String topicId, String questionId) async {
    return await _db
        .collection('topics')
        .doc(topicId)
        .collection('questions')
        .doc(questionId)
        .get();
  }
}
