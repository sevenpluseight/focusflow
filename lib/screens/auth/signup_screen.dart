import 'package:flutter/material.dart';
import 'dart:math';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  double _passwordStrength = 0.0;
  String _passwordStrengthLabel = "";
  bool _passwordsMatch = false;

  // Password validation helpers
  bool _hasUppercase(String password) => RegExp(r'[A-Z]').hasMatch(password);
  bool _hasSpecial(String password) =>
      RegExp(r'[!@#\$&*~%^()\-_=+{}\[\]:;,.<>?]').hasMatch(password);
  bool _hasSequential(String password) =>
      RegExp(r'(?:abc|123|qwe|password)', caseSensitive: false)
          .hasMatch(password);
  bool _isLongEnough(String password) => password.length >= 8;

  void _checkPasswordStrength(String password) {
    double strength = 0;

    final hasUppercase = _hasUppercase(password);
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasDigits = password.contains(RegExp(r'[0-9]'));
    final hasSpecial = _hasSpecial(password);
    final isLongEnough = _isLongEnough(password);
    final hasSequential = _hasSequential(password);

    if (hasUppercase) strength += 0.2;
    if (hasLowercase) strength += 0.2;
    if (hasDigits) strength += 0.2;
    if (hasSpecial) strength += 0.2;
    if (isLongEnough) strength += 0.2;
    if (hasSequential) strength -= 0.3;

    strength = max(0, min(1, strength));

    String label;
    if (strength < 0.3) {
      label = "Weak 😕";
    } else if (strength < 0.6) {
      label = "Medium 😐";
    } else if (strength < 0.8) {
      label = "Strong 💪";
    } else {
      label = "Very Strong 🔥";
    }

    setState(() {
      _passwordStrength = strength;
      _passwordStrengthLabel = label;
    });
  }

  void _checkPasswordsMatch() {
    final match =
        _passwordController.text == _confirmPasswordController.text &&
        _confirmPasswordController.text.isNotEmpty;

    setState(() {
      _passwordsMatch = match;
    });
  }

  Future<void> _signUp() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      setState(() => _errorMessage = "Please fill in all fields.");
      return;
    }
    if (!_isLongEnough(password)) {
      setState(() => _errorMessage = "Password must be at least 8 characters.");
      return;
    }
    if (!_hasUppercase(password)) {
      setState(() =>
          _errorMessage = "Password must contain at least one uppercase letter.");
      return;
    }
    if (!_hasSpecial(password)) {
      setState(() =>
          _errorMessage = "Password must contain at least one special character.");
      return;
    }
    if (_hasSequential(password)) {
      setState(() =>
          _errorMessage = "Password should not contain easy patterns like 'abc' or '123'.");
      return;
    }
    if (password != confirmPassword) {
      setState(() => _errorMessage = "Passwords do not match.");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Future.delayed(const Duration(seconds: 2)); // Simulate sign-up
      if (email == "test@example.com") {
        _errorMessage = "This email is already registered.";
      } else {
        if (mounted) Navigator.of(context).pop();
      }
    } catch (e) {
      _errorMessage = "Sign-up failed: $e";
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildRequirement(String text, bool met) {
    return Row(
      children: [
        Icon(
          met ? Icons.check_circle : Icons.circle_outlined,
          color: met ? const Color(0xFFBFFB4F) : Colors.white24,
          size: 16,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: met ? Colors.white70 : Colors.white38,
            fontSize: 13,
          ),
        ),
      ],
    );
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
            borderSide:
                const BorderSide(color: Color(0xFFBFFB4F), width: 2),
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF222428),
        appBar: AppBar(
          title: const Text("Sign Up", style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF222428),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Create Your Account",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Username
                  TextField(
                    controller: _usernameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: "Username"),
                  ),
                  const SizedBox(height: 16),

                  // Email
                  TextField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: "Email"),
                  ),
                  const SizedBox(height: 16),

                  // Password
                  TextField(
                    controller: _passwordController,
                    obscureText: !_passwordVisible,
                    style: const TextStyle(color: Colors.white),
                    onChanged: (value) {
                      _checkPasswordStrength(value);
                      _checkPasswordsMatch();
                    },
                    decoration: InputDecoration(
                      labelText: "Password",
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Strength bar
                  LinearProgressIndicator(
                    value: _passwordStrength,
                    backgroundColor: Colors.white10,
                    color: _passwordStrength < 0.3
                        ? Colors.redAccent
                        : _passwordStrength < 0.6
                            ? Colors.orangeAccent
                            : _passwordStrength < 0.8
                                ? Colors.lightGreen
                                : const Color(0xFFBFFB4F),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _passwordStrengthLabel,
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ),

                  // Password requirements (moved here ✅)
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Password requirements:",
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      _buildRequirement("8+ characters", _isLongEnough(_passwordController.text)),
                      _buildRequirement("1 uppercase letter", _hasUppercase(_passwordController.text)),
                      _buildRequirement("1 special character", _hasSpecial(_passwordController.text)),
                      _buildRequirement("No easy patterns like 'abc' or '123'",
                          !_hasSequential(_passwordController.text)),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Confirm password
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: !_confirmPasswordVisible,
                    style: const TextStyle(color: Colors.white),
                    onChanged: (_) => _checkPasswordsMatch(),
                    decoration: InputDecoration(
                      labelText: "Confirm Password",
                      suffixIcon: IconButton(
                        icon: Icon(
                          _confirmPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          setState(() {
                            _confirmPasswordVisible = !_confirmPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),

                  // ✅ Match / ❌ Not match indicator
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _confirmPasswordController.text.isEmpty
                          ? ""
                          : _passwordsMatch
                              ? "✅ Passwords match"
                              : "❌ Passwords do not match",
                      style: TextStyle(
                        color: _passwordsMatch ? Colors.lightGreen : Colors.redAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  const SizedBox(height: 20),

                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _signUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFBFFB4F),
                            minimumSize: const Size.fromHeight(48),
                            foregroundColor: Colors.black,
                          ),
                          child: const Text(
                            "Next",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      "Already have an account? Sign In",
                      style: TextStyle(color: Color(0xFFBFFB4F)),
                    ),
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