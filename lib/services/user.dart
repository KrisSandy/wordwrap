import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wordwrap/models/user.dart';
import 'package:wordwrap/services/auth.dart';

class UserService {
  static final CollectionReference<Map<String, dynamic>> _users =
      FirebaseFirestore.instance.collection('users');

  Future<User> getUser() async {
    final user = AuthService.user;
    if (user == null) {
      return Future.error('User is not logged in');
    }
    final docRef = _users.doc(user.uid);
    final snapshot = await docRef.get();
    if (snapshot.exists) {
      return User.fromJson(snapshot.data()!);
    } else {
      final newUser = User(
        uid: user.uid,
        displayName: user.displayName,
        email: user.email,
        photoURL: user.photoURL,
      );
      await docRef.set(newUser.toJson());
      return newUser;
    }
  }

  static Stream<User?> userStream() {
    final user = AuthService.user;
    if (user == null) {
      return Stream.value(null);
    }
    return _users.doc(user.uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return User.fromJson(snapshot.data()!);
      }
      return null;
    });
  }
}
