import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = "Please fill in both email and password.");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          _errorMessage = "No user found with that email.";
          break;
        case 'wrong-password':
          _errorMessage = "Incorrect password.";
          break;
        case 'invalid-email':
          _errorMessage = "Invalid email address.";
          break;
        default:
          _errorMessage = e.message;
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = "Email and password cannot be blank.");
      return;
    }
    if (password.length < 6) {
      setState(() => _errorMessage = "Password must be at least 6 characters.");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          _errorMessage = "This email is already registered.";
          break;
        case 'invalid-email':
          _errorMessage = "Please enter a valid email.";
          break;
        case 'weak-password':
          _errorMessage = "Password too weak. Try adding numbers or symbols.";
          break;
        default:
          _errorMessage = e.message;
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Google sign-in canceled.";
        });
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      setState(() {
        _errorMessage = "Google sign-in failed: $e";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xFFBFFB4F),
          selectionColor: Color(0x55BFFB4F),
          selectionHandleColor: Color(0xFFBFFB4F),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white10,
          labelStyle: const TextStyle(color: Colors.white70),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white30),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFBFFB4F), width: 2),
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF222428),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 🟡 App icon
                  Image.asset(
                    'assets/icons/focusflow_icon.png',
                    width: 100,
                    height: 100,
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    "FocusFlow",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 📧 Email Field
                  TextField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: "Email"),
                  ),
                  const SizedBox(height: 16),

                  // 🔒 Password Field
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: "Password"),
                  ),
                  const SizedBox(height: 20),

                  // ⚠️ Error Message
                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  const SizedBox(height: 20),

                  // 🔘 Buttons
                  _isLoading
                      ? const CircularProgressIndicator()
                      : Column(
                          children: [
                            ElevatedButton(
                              onPressed: _signIn,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFBFFB4F),
                                minimumSize: const Size.fromHeight(48),
                                foregroundColor: Colors.black,
                              ),
                              child: const Text(
                                "Sign In",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 10),
                            OutlinedButton(
                              onPressed: _register,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFBFFB4F)),
                                minimumSize: const Size.fromHeight(48),
                              ),
                              child: const Text(
                                "Create Account",
                                style: TextStyle(
                                  color: Color(0xFFBFFB4F),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text("Or continue with",
                                style: TextStyle(color: Colors.white70)),
                            const SizedBox(height: 10),
                            OutlinedButton.icon(
                              icon: Image.asset(
                                'assets/icons/google.png',
                                height: 24,
                              ),
                              label: const Text(
                                "Sign in with Google",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFBFFB4F)),
                                minimumSize: const Size.fromHeight(48),
                              ),
                              onPressed: _signInWithGoogle,
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
