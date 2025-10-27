import 'package:flutter/material.dart';
import 'package:focusflow/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  String? _infoMessage;
  String? _username;
  String? _role;

  // Getters
  User? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get infoMessage => _infoMessage;
  String? get username => _username;
  String? get role => _role;
  AuthService get authService => _authService;

  // Private setters
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _setMessage(String? message) {
    _infoMessage = message;
    notifyListeners();
  }

  void _setUser(User? user) {
    _user = user;
    if (user != null) fetchUserData();
    notifyListeners();
  }

  void clearError() {
    _setError(null);
    _setMessage(null);
  }

  // Sign in
  Future<void> signIn(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      _setError("Please fill in both email and password.");
      return;
    }

    _setLoading(true);
    _setError(null);
    _setMessage(null);

    try {
      final user = await _authService.signIn(email, password);
      if (user == null) {
        _setError("Invalid email or password.");
      } else {
        _setUser(user);
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with Google
  Future<void> signInWithGoogle() async {
    _setLoading(true);
    _setError(null);

    try {
      final user = await _authService.signInWithGoogle();
      if (user == null) {
        _setError("Google sign-in canceled or failed.");
      } else {
        _setUser(user);
      }
    } catch (e) {
      _setError("Google sign-in failed: $e");
    } finally {
      _setLoading(false);
    }
  }

  // Sign up
  Future<void> signUp({
    required String username,
    required String email,
    required String password,
    String role = "user",
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

      _setUser(user);

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

  // Reset password
  Future<void> resetPassword(String email) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (normalizedEmail.isEmpty) {
      _setError("Please enter a valid email.");
      return;
    }

    _setLoading(true);
    _setError(null);
    _setMessage(null);

    try {
      // Firebase will send a reset email if the account exists
      await _auth.sendPasswordResetEmail(email: normalizedEmail);

      // Show generic message regardless of success or failure
      _setMessage(
        "If this email exists, a reset link was sent. Check your inbox."
      );
    } on FirebaseAuthException catch (e) {
      // Only catch invalid email formats
      if (e.code == 'invalid-email') {
        _setError("Invalid email format.");
      } else {
        // All other cases show the generic message
        _setMessage(
          "If this email exists, a reset link was sent. Check your inbox."
        );
      }
    } catch (e) {
      // Generic message for any other error
      _setMessage(
        "If this email exists, a reset link was sent. Check your inbox."
      );
    } finally {
      _setLoading(false);
    }
  }

  // Fetch user data
  Future<void> fetchUserData() async {
    if (_user == null) return;

    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc(_user!.uid);
      final doc = await docRef.get();

      if (!doc.exists) {
        await docRef.set({
          'uid': _user!.uid,
          'username': _user!.displayName ?? 'User',
          'email': _user!.email,
          'role': 'user',
          'signInMethod': 'google',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      final data = (await docRef.get()).data();
      _username = data?['username'];
      _role = data?['role'];
      notifyListeners();
    } catch (e) {
      _setError("Failed to fetch user data: $e");
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _authService.signOut();
    _setUser(null);
    _username = null;
    _role = null;
  }
}
