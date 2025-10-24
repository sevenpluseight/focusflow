import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:focusflow/screens/auth/signup_screen.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:focusflow/utils/utils.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onToggleTheme;
  final bool isDarkMode;

  const LoginScreen({
    super.key,
    this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

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

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Google sign-in canceled.";
        });
        return;
      }

      final googleAuth = await googleUser.authentication;
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

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _errorMessage = "Please enter your email to reset password.");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      setState(() {
        _errorMessage = "Password reset link sent to $email";
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  InputDecoration _inputDecoration(String label, {Widget? suffixIcon}) {
    final isDark = widget.isDarkMode;

    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: isDark ? const Color(0xFF2C2F33) : Colors.white,
      labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: SizeConfig.font(2)),
      hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black45, fontSize: SizeConfig.font(1.8)),
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SizeConfig.wp(3)),
        borderSide: BorderSide(color: isDark ? Colors.white30 : Colors.black38),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SizeConfig.wp(3)),
        borderSide: const BorderSide(color: Color(0xFFBFFB4F), width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: theme.appBarTheme.elevation,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: SizeConfig.wp(1.2)),
            child: IconButton(
              icon: Icon(
                widget.isDarkMode ? Pixel.sunalt : Pixel.moon,
                size: SizeConfig.wp(6.8),
              ),
              onPressed: widget.onToggleTheme,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(SizeConfig.wp(6)),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/icons/png/focusflow_icon.png',
                  width: SizeConfig.wp(25),
                  height: SizeConfig.wp(25),
                ),
                SizedBox(height: SizeConfig.hp(4)),
                Text(
                  "FocusFlow",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: SizeConfig.font(4.5),
                    fontWeight: FontWeight.bold,
                    color: widget.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: SizeConfig.hp(5)),

                // Email
                TextField(
                  controller: _emailController,
                  decoration: _inputDecoration("Email"),
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(
                    color: widget.isDarkMode ? Colors.white : Colors.black87,
                    fontSize: SizeConfig.font(2),
                  ),
                ),
                SizedBox(height: SizeConfig.hp(2)),

                // Password
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: _inputDecoration(
                    "Password",
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Pixel.eyeclosed : Pixel.eye,
                        color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                        size: SizeConfig.wp(5),
                      ),
                      onPressed: () => setState(() {
                        _obscurePassword = !_obscurePassword;
                      }),
                    ),
                  ),
                  style: TextStyle(
                    color: widget.isDarkMode ? Colors.white : Colors.black87,
                    fontSize: SizeConfig.font(2),
                  ),
                ),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _resetPassword,
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: widget.isDarkMode ? Colors.white70 : Colors.black87,
                        fontSize: SizeConfig.font(1.8),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: SizeConfig.hp(3)),

                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: SizeConfig.font(1.8),
                    ),
                  ),

                SizedBox(height: SizeConfig.hp(3)),

                _isLoading
                    ? const CircularProgressIndicator()
                    : Column(
                        children: [
                          ElevatedButton(
                            onPressed: _signIn,
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, SizeConfig.hp(6)),
                            ),
                            child: Text(
                              "Sign In",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: SizeConfig.font(2),
                              ),
                            ),
                          ),
                          SizedBox(height: SizeConfig.hp(2)),
                          Row(
                            children: [
                              Expanded(child: Divider()),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: SizeConfig.wp(2)),
                                child: Text(
                                  "Or continue with",
                                  style: TextStyle(fontSize: SizeConfig.font(1.8)),
                                ),
                              ),
                              Expanded(child: Divider()),
                            ],
                          ),
                          SizedBox(height: SizeConfig.hp(3)),
                          OutlinedButton(
                            onPressed: _signInWithGoogle,
                            style: OutlinedButton.styleFrom(
                              minimumSize: Size(double.infinity, SizeConfig.hp(6)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/icons/png/google.png',
                                  height: SizeConfig.hp(3),
                                ),
                                SizedBox(width: SizeConfig.wp(2)),
                                Text(
                                  "Sign in with Google",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: SizeConfig.font(2),
                                    color: widget.isDarkMode ? Color(0xFFBFFB4F) : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: SizeConfig.hp(2)),

                          // Sign Up link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don’t have an account?",
                                style: TextStyle(fontSize: SizeConfig.font(1.8)),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SignUpScreen(
                                        isDarkMode: widget.isDarkMode,
                                        onToggleTheme: widget.onToggleTheme,
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: SizeConfig.font(2),
                                    color: widget.isDarkMode ? Color(0xFFBFFB4F) : Colors.black,
                                  ),
                                ),
                              ),
                            ],
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
