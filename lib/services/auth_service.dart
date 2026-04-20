import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quickbite/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signUp(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<UserModel> createUserDocument({
    required String id,
    required String name,
    required String email,
  }) async {
    final userModel = UserModel(id: id, name: name, email: email);
    await _firestore.collection('users').doc(id).set(userModel.toMap());
    return userModel;
  }

  Future<UserModel?> fetchUserProfile(String userId) async {
    final snapshot = await _firestore.collection('users').doc(userId).get();
    if (snapshot.exists) {
      return UserModel.fromMap(snapshot.data()!, snapshot.id);
    }
    return null;
  }
}
