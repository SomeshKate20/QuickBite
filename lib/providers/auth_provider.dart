import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quickbite/models/user_model.dart';
import 'package:quickbite/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? user;
  bool isLoading = false;
  String? errorMessage;

  bool get isAuthenticated => user != null;

  Future<void> loadCurrentUser() async {
    final firebaseUser = _authService.currentUser;
    if (firebaseUser == null) {
      user = null;
      notifyListeners();
      return;
    }
    isLoading = true;
    notifyListeners();
    final profile = await _authService.fetchUserProfile(firebaseUser.uid);
    user =
        profile ??
        UserModel(
          id: firebaseUser.uid,
          name: firebaseUser.email ?? '',
          email: firebaseUser.email ?? '',
        );
    isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
      final credential = await _authService.signIn(email, password);
      final firebaseUser = credential.user;
      if (firebaseUser == null) return false;
      user =
          await _authService.fetchUserProfile(firebaseUser.uid) ??
          UserModel(
            id: firebaseUser.uid,
            name: firebaseUser.email ?? '',
            email: email,
          );
      return true;
    } on FirebaseAuthException catch (error) {
      errorMessage = error.message;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signup(String name, String email, String password) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
      final credential = await _authService.signUp(email, password);
      final firebaseUser = credential.user;
      if (firebaseUser == null) return false;
      user = await _authService.createUserDocument(
        id: firebaseUser.uid,
        name: name,
        email: email,
      );
      return true;
    } on FirebaseAuthException catch (error) {
      errorMessage = error.message;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    user = null;
    notifyListeners();
  }
}
