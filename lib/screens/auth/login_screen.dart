import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFF222428),
    body: Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App icon
              Image.asset(
                'assets/icons/focusflow_icon.png',  // <-- your icon image
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

              // Email Field
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  filled: true,
                  fillColor: Colors.white10,
                  labelStyle: const TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),

              // Password Field
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  filled: true,
                  fillColor: Colors.white10,
                  labelStyle: const TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),

              // Error Message
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              const SizedBox(height: 20),

              // Buttons
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
                              fontWeight: FontWeight.bold
                              ),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    ),
  );
}
}