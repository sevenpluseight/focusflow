import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:focusflow/screens/auth/login_screen.dart';
import 'package:pixelarticons/pixelarticons.dart';

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

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  String? _errorMessage;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _passwordsMatch = false;
  bool _startedTyping = false;
  bool _isEmailValid = false;

  // Password validation flags
  bool _hasLength = false;
  bool _hasUppercase = false;
  bool _hasSpecial = false;
  bool _noSequential = false;

  double _passwordStrength = 0.0;
  String _passwordStrengthLabel = "";

  final Color _primaryColor = const Color(0xFFBFFB4F);

  bool get _isFormValid =>
      _usernameController.text.trim().isNotEmpty &&
      _emailController.text.trim().isNotEmpty &&
      _isEmailValid &&
      _hasLength &&
      _hasUppercase &&
      _hasSpecial &&
      _noSequential &&
      _passwordsMatch &&
      !_isLoading;

  // Validators
  bool _validateEmail(String email) {
    // Basic email structure
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) return false;

    // Restrict to specific domains
    final allowedDomains = ['gmail.com', 'outlook.com', 'yahoo.com'];
    final domain = email.split('@').last.toLowerCase();

    return allowedDomains.contains(domain);
  }

  bool _checkUppercase(String password) => RegExp(r'[A-Z]').hasMatch(password);
  bool _checkSpecial(String password) =>
      RegExp(r'[!@#\$&*~%^()\-_=+{}\[\]:;,.<>?]').hasMatch(password);
  bool _checkSequential(String password) =>
      !RegExp(r'(?:abc|123|qwe|password)', caseSensitive: false)
          .hasMatch(password);
  bool _checkLength(String password) => password.length >= 8;

  void _checkPasswordStrength(String password) {
    if (!_startedTyping && password.isNotEmpty) {
      _startedTyping = true;
    }

    setState(() {
      _hasLength = _checkLength(password);
      _hasUppercase = _checkUppercase(password);
      _hasSpecial = _checkSpecial(password);
      _noSequential = _checkSequential(password);

      double strength = 0;
      if (_hasUppercase) strength += 0.25;
      if (_hasSpecial) strength += 0.25;
      if (_hasLength) strength += 0.25;
      if (_noSequential) strength += 0.25;

      if (strength < 0.3) {
        _passwordStrengthLabel = "Weak 😕";
      } else if (strength < 0.6) {
        _passwordStrengthLabel = "Medium 😐";
      } else if (strength < 0.8) {
        _passwordStrengthLabel = "Strong 💪";
      } else {
        _passwordStrengthLabel = "Very Strong 🔥";
      }

      _passwordStrength = strength;
    });
  }

  void _checkPasswordsMatch() {
    setState(() {
      _passwordsMatch = _passwordController.text ==
              _confirmPasswordController.text &&
          _confirmPasswordController.text.isNotEmpty;
    });
  }

  void _showInfoModal(String title, String message,
      {bool redirectToLogin = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2F33),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (redirectToLogin) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
            child: Text("OK", style: TextStyle(color: _primaryColor)),
          ),
        ],
      ),
    );
  }

  Future<void> _signUp() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();

    if (!_isFormValid) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(userCred.user!.uid).set({
        'uid': userCred.user!.uid,
        'username': username,
        'email': email,
        'signInMethod': 'email',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully! 🎉')),
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _showInfoModal(
          "Email Already Registered",
          "This email is already linked to an existing account.\n\nPlease use your original sign-in method to log in.",
          redirectToLogin: true,
        );
      } else {
        setState(() => _errorMessage = e.message);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _inputDecoration(String label, [Widget? suffixIcon]) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white10,
      labelStyle: const TextStyle(color: Colors.white70),
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white30),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _primaryColor, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPaddingForScroll = 160.0;

    return Theme(
      data: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: _primaryColor,
          selectionColor: _primaryColor.withOpacity(0.3),
          selectionHandleColor: _primaryColor,
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF222428),
        appBar: AppBar(
          backgroundColor: const Color(0xFF222428),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "Sign Up",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Stack(
          children: [
            // scroll area (content)
            Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, bottomPaddingForScroll),
              child: SingleChildScrollView(
                // ensure keyboard doesn't cover input
                reverse: false,
                child: Column(
                  children: [
                    const Text(
                      "Create Your Account",
                      style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 40),

                    // Username
                    TextField(
                      controller: _usernameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration("Username"),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 20),

                    // Email
                    TextField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration("Email"),
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        setState(() {
                          _isEmailValid = _validateEmail(value.trim());
                        });
                      },
                    ),
                    // Email inline info
                    // Align(
                    //   alignment: Alignment.centerLeft,
                    //   child: _emailController.text.isEmpty
                    //       ? const SizedBox.shrink()
                    //       : !_isEmailValid
                    //           ? Padding(
                    //               padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                    //               child: Row(
                    //                 children: const [
                    //                   Icon(Icons.error_outline, color: Colors.redAccent, size: 14),
                    //                   SizedBox(width: 6),
                    //                   Text(
                    //                     "Invalid email format",
                    //                     style: TextStyle(color: Colors.redAccent, fontSize: 12),
                    //                   ),
                    //                 ],
                    //               ),
                    //             )
                    //           : const SizedBox.shrink(),
                    // ),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: _emailController.text.isEmpty
                          ? const SizedBox.shrink()
                          : Row(
                              children: [
                                Icon(
                                  _isEmailValid
                                      ? Pixel.check
                                      : Pixel.alert,
                                  color: _isEmailValid ? Colors.lightGreen : Colors.redAccent,
                                  size: 25,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  _isEmailValid ? "Valid email" : "Invalid email format",
                                  style: TextStyle(
                                    color: _isEmailValid ? Colors.lightGreen : Colors.redAccent,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 20),

                    // Password
                    TextField(
                      controller: _passwordController,
                      obscureText: !_passwordVisible,
                      style: const TextStyle(color: Colors.white),
                      onChanged: (val) {
                        _checkPasswordStrength(val);
                        _checkPasswordsMatch();
                      },
                      decoration: _inputDecoration(
                        "Password",
                        IconButton(
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white70,
                          ),
                          onPressed: () =>
                              setState(() => _passwordVisible = !_passwordVisible),
                        ),
                      ),
                    ),

                    if (_startedTyping) ...[
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: _passwordStrength,
                        backgroundColor: Colors.white10,
                        color: _passwordStrength < 0.3
                            ? Colors.redAccent
                            : _passwordStrength < 0.6
                                ? Colors.orangeAccent
                                : _passwordStrength < 0.8
                                    ? Colors.lightGreen
                                    : _primaryColor,
                        minHeight: 6,
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _passwordStrengthLabel,
                          style:
                              const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildRule("At least 8 characters", _hasLength),
                            _buildRule("1 uppercase letter", _hasUppercase),
                            _buildRule("1 special character", _hasSpecial),
                            _buildRule("Avoid easy patterns like '123' or 'abc'",
                                _noSequential),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Confirm Password
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: !_confirmPasswordVisible,
                      style: const TextStyle(color: Colors.white),
                      onChanged: (_) {
                        _checkPasswordsMatch();
                        setState(() {});
                      },
                      decoration: _inputDecoration(
                        "Confirm Password",
                        IconButton(
                          icon: Icon(
                            _confirmPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white70,
                          ),
                          onPressed: () => setState(
                              () => _confirmPasswordVisible = !_confirmPasswordVisible),
                        ),
                      ),
                    ),
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
                        ),
                      ),
                    ),

                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent)),
                    ],
                    // Add some bottom spacing so last field isn't jammed
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // bottom fixed button — animates with keyboard inset
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              left: 0,
              right: 0,
              bottom: keyboardInset > 0 ? keyboardInset : 0,
              child: SafeArea(
                top: false,
                child: Container(
                  color: const Color(0xFF222428),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _isFormValid ? _signUp : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _isFormValid ? _primaryColor : Colors.grey[600],
                            minimumSize: const Size.fromHeight(52),
                            foregroundColor: Colors.black,
                            disabledForegroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey[700],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Create Account",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRule(String text, bool met) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle : Icons.cancel,
            color: met ? Colors.lightGreen : Colors.white30,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: met ? Colors.lightGreen : Colors.white54,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
