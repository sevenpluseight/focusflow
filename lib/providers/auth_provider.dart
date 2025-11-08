import 'package:flutter/material.dart';
import 'package:focusflow/models/models.dart';
import 'package:focusflow/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _errorMessage;
  String? _infoMessage;

  AuthProvider() {
    _auth.authStateChanges().listen((user) {
      _setUser(user);
    });
  }

  // Getters
  User? get user => _user;
  UserModel? get userModel => _userModel;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get infoMessage => _infoMessage;
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
    if (user != null) {
      fetchUserData();
    } else {
      _userModel = null;
    }
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
    required double dailyTargetHours,
    required int workInterval,
    required int breakInterval,
    required String focusType,
    String role = "user",
  }) async {
    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        dailyTargetHours <= 0 ||
        workInterval <= 0 ||
        breakInterval <= 0 ||
        focusType.isEmpty) {
      _setError("Please complete all required fields before creating your account.");
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

      final newUser = UserModel(
        uid: user.uid,
        username: username,
        email: email,
        role: role,
        signInMethod: 'email',
        createdAt: Timestamp.now(),
        dailyTargetHours: dailyTargetHours,
        workInterval: workInterval,
        breakInterval: breakInterval,
        focusType: focusType,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(newUser.toMap(), SetOptions(merge: true));

      _setUser(user); // Automatically fetch data after creation
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _setError(
          "This email is already linked to an existing account.\nPlease use your original sign-in method.",
        );
      } else {
        _setError(e.message ?? "An unexpected Firebase error occurred.");
      }
    } catch (e) {
      _setError("An unexpected error occurred: $e");
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
      await _auth.sendPasswordResetEmail(email: normalizedEmail);
      _setMessage("If this email exists, a reset link was sent. Check your inbox.");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        _setError("Invalid email format.");
      } else {
        _setMessage("If this email exists, a reset link was sent. Check your inbox.");
      }
    } catch (_) {
      _setMessage("If this email exists, a reset link was sent. Check your inbox.");
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
        // Create default Firestore doc if missing (e.g. Google sign-in user)
        final newUser = UserModel(
          uid: _user!.uid,
          username: _user!.displayName ?? 'User',
          email: _user!.email ?? '',
          role: 'user',
          signInMethod: 'google',
          createdAt: Timestamp.now(),
          dailyTargetHours: 2,
          workInterval: 25,
          breakInterval: 5,
          focusType: 'Breeze',
        );

        await docRef.set(newUser.toMap(), SetOptions(merge: true));
        _userModel = newUser;
      } else {
        _userModel = UserModel.fromFirestore(doc);

        // Clamp invalid values (in case of old data)
        _userModel = _userModel!.copyWith(
          dailyTargetHours: (_userModel!.dailyTargetHours ?? 4).clamp(1, 8).toDouble(),
          workInterval: (_userModel!.workInterval ?? 50).clamp(25, 120),
          breakInterval: (_userModel!.breakInterval ?? 10).clamp(5, 60),
          focusType: _userModel!.focusType ?? 'Breeze',
        );
      }

      notifyListeners();
    } catch (e) {
      _setError("Failed to fetch user data: $e");
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _authService.signOut();
    _setUser(null);
  }
}
