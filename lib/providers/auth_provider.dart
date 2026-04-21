import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quickbite/models/user_model.dart';
import 'package:quickbite/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthService? _authService;
  UserModel? user;
  bool isLoading = false;
  String? errorMessage;
  bool _firebaseInitialized = false;

  bool get isAuthenticated => user != null;
  bool get firebaseAvailable => _firebaseInitialized;

  AuthProvider() {
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    try {
      // Check if Firebase is initialized
      FirebaseAuth.instance;
      _authService = AuthService();
      _firebaseInitialized = true;
    } catch (e) {
      _firebaseInitialized = false;
      debugPrint('Firebase not available: $e');
    }
  }

  Future<void> loadCurrentUser() async {
    if (!_firebaseInitialized || _authService == null) {
      user = null;
      notifyListeners();
      return;
    }
    final firebaseUser = _authService!.currentUser;
    if (firebaseUser == null) {
      user = null;
      notifyListeners();
      return;
    }
    isLoading = true;
    notifyListeners();
    final profile = await _authService!.fetchUserProfile(firebaseUser.uid);
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
    if (!_firebaseInitialized || _authService == null) {
      errorMessage = 'Authentication not available - Firebase not configured';
      notifyListeners();
      return false;
    }
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
      final credential = await _authService!.signIn(email, password);
      final firebaseUser = credential.user;
      if (firebaseUser == null) return false;
      user =
          await _authService!.fetchUserProfile(firebaseUser.uid) ??
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
    if (!_firebaseInitialized || _authService == null) {
      errorMessage = 'Authentication not available - Firebase not configured';
      notifyListeners();
      return false;
    }
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
      final credential = await _authService!.signUp(email, password);
      final firebaseUser = credential.user;
      if (firebaseUser == null) return false;
      user = await _authService!.createUserDocument(
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
    if (_firebaseInitialized && _authService != null) {
      await _authService!.signOut();
    }
    user = null;
    notifyListeners();
  }
}
