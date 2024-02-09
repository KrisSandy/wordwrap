import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wordwrap/models/word.dart';

class UserWordsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getAll(String uid, int status) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('words')
        .where('status', isEqualTo: status)
        .snapshots();
  }

  Future<void> add(String uid, Word word) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('words')
        .doc(word.word)
        .set(word.toJson());
  }

  Future<void> update(String uid, Word word) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('words')
        .doc(word.word)
        .update(word.toJson());
  }

  Future<void> delete(String uid, String word) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('words')
        .doc(word)
        .delete();
  }
}
