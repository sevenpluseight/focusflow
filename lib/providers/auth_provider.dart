import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:focusflow/services/services.dart';
import 'package:provider/provider.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;
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
  String? get userEmail => _user?.email;
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
    notifyListeners();
  }

  void clearError() {
    _setError(null);
    _setMessage(null);
  }

  // Check if email matches current user
  bool doesEmailMatch(String email) {
    return _user?.email?.toLowerCase() == email.toLowerCase();
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
  Future<User?> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final user = await _authService.signUp(
        username: username,
        email: email,
        password: password,
      );

      _setUser(user);
      return user;
    } catch (e) {
      _setError(e.toString());
      return null;
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
      _setMessage(
        "If this email exists, a reset link was sent. Check your inbox.",
      );
    } catch (_) {
      _setMessage(
        "If this email exists, a reset link was sent. Check your inbox.",
      );
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  // Future<void> signOut() async {
  //   await _authService.signOut();
  //   _setUser(null);
  // }

  Future<void> signOut(BuildContext context) async {
    _resetAllProviders(context);

    await _authService.signOut();
    _setUser(null);
  }

  void _resetAllProviders(BuildContext context) {
    try {
      final adminUsersProvider = Provider.of<AdminUsersProvider>(
        context,
        listen: false,
      );
      adminUsersProvider.reset();
    } catch (e) {}
    try {
      final adminStatsProvider = Provider.of<AdminStatsProvider>(
        context,
        listen: false,
      );
      adminStatsProvider.reset();
    } catch (e) {}
  }
}
