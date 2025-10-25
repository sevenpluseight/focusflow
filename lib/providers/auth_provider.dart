import 'package:flutter/material.dart';
import 'package:focusflow/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      _setError("Please fill in both email and password.");
      return;
    }

    _setLoading(true);
    _setError(null);

    try {
      final user = await _authService.signIn(email, password);
      if (user == null) _setError("Invalid email or password.");
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithGoogle() async {
    _setLoading(true);
    _setError(null);

    try {
      final user = await _authService.signInWithGoogle();
      if (user == null) _setError("Google sign-in canceled or failed.");
    } catch (e) {
      _setError("Google sign-in failed: $e");
    } finally {
      _setLoading(false);
    }
  }

  /// Sign-up with role
  Future<void> signUp({
    required String username,
    required String email,
    required String password,
    String role = "user", // Default role
  }) async {
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      _setError("Please fill in all fields.");
      return;
    }

    _setLoading(true);
    _setError(null);

    try {
      final User? user = await _authService.signUp(
        username: username,
        email: email,
        password: password,
      );

      if (user == null) {
        _setError("Failed to create account.");
        return;
      }

      // Save user in Firestore with role
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'username': username,
        'email': email,
        'role': role,
        'signInMethod': 'email',
        'createdAt': FieldValue.serverTimestamp(),
      });

    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _setError(
          "This email is already linked to an existing account.\nPlease use your original sign-in method."
        );
      } else {
        _setError(e.message);
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetPassword(String email) async {
    if (email.isEmpty) {
      _setError("Please enter your email to reset password.");
      return;
    }

    _setLoading(true);
    _setError(null);

    try {
      await _authService.resetPassword(email);
      _setError("Password reset email sent to $email.");
    } catch (e) {
      _setError("Failed to send reset link: $e");
    } finally {
      _setLoading(false);
    }
  }

  void clearError() => _setError(null);
}
