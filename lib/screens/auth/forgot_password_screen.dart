import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:focusflow/screens/auth/auth.dart';
import 'package:focusflow/utils/utils.dart';
import 'package:pixelarticons/pixelarticons.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isEmailValid = false;
  bool _startedTyping = false;
  bool _buttonDisabled = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendResetLink(AuthProvider authProvider) async {
    final email = _emailController.text.trim().toLowerCase();

    if (!_isEmailValid || _buttonDisabled) return;

    setState(() => _buttonDisabled = true);
    await authProvider.resetPassword(email);

    // Re-enable button after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) setState(() => _buttonDisabled = false);
    });
  }

  void _showDialog(String title, String message, {bool isError = false}) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF2C2F33) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (!isError) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                );
              }
            },
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFF4A90E2)),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: isDarkMode ? Colors.white70 : Colors.black54,
      ),
      filled: true,
      fillColor: isDarkMode ? const Color(0xFF2C2F33) : Colors.grey[200],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (authProvider.errorMessage != null) {
              _showDialog('Error', authProvider.errorMessage!, isError: true);
              authProvider.clearError();
            } else if (authProvider.infoMessage != null) {
              _showDialog('Success', authProvider.infoMessage!, isError: false);
              authProvider.clearError();
            }
          });

          return Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              backgroundColor: theme.appBarTheme.backgroundColor,
              elevation: theme.appBarTheme.elevation,
              leading: IconButton(
                icon: Icon(
                  Pixel.chevronleft,
                  size: SizeConfig.wp(6.6),
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            backgroundColor: theme.scaffoldBackgroundColor,
            body: Padding(
              padding: EdgeInsets.fromLTRB(
                SizeConfig.wp(4),
                SizeConfig.hp(3),
                SizeConfig.wp(4),
                SizeConfig.hp(8),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: SizeConfig.hp(2)),

                    // Title
                    Center(
                      child: Text(
                        "Reset Your Password",
                        style: TextStyle(
                          fontSize: SizeConfig.font(4),
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    SizedBox(height: SizeConfig.hp(2)),

                    // Instruction
                    Text(
                      "Enter your registered email and we'll send you a reset link",
                      style: TextStyle(
                        fontSize: SizeConfig.font(2),
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    SizedBox(height: SizeConfig.hp(3)),

                    // Email input
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(
                        fontSize: SizeConfig.font(2),
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                      onChanged: (value) {
                        if (!_startedTyping && value.isNotEmpty) _startedTyping = true;
                        setState(() => _isEmailValid = AuthValidators.isEmailValid(value.trim()));
                      },
                      decoration: _inputDecoration('Email'),
                    ),

                    // Email validation indicator
                    if (_emailController.text.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: SizeConfig.hp(1)),
                        child: Row(
                          children: [
                            Icon(
                              !_isEmailValid ? Pixel.alert : Pixel.check,
                              color: !_isEmailValid ? Colors.redAccent : Colors.lightGreen,
                              size: SizeConfig.font(2.2),
                            ),
                            SizedBox(width: SizeConfig.wp(2)),
                            Expanded(
                              child: Text(
                                !_isEmailValid
                                    ? "Invalid email format"
                                    : "Looks good",
                                style: TextStyle(
                                  fontSize: SizeConfig.font(1.8),
                                  color: !_isEmailValid ? Colors.redAccent : Colors.lightGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    SizedBox(height: SizeConfig.hp(3)),

                    // Send reset link button
                    ElevatedButton(
                      onPressed: authProvider.isLoading || !_isEmailValid || _buttonDisabled
                          ? null
                          : () => _sendResetLink(authProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isEmailValid
                            ? const Color(0xFFBFFB4F)
                            : const Color(0xFFBFFB4F).withValues(),
                        padding: EdgeInsets.symmetric(vertical: SizeConfig.hp(2)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: authProvider.isLoading
                          ? const CircularProgressIndicator(color: Colors.black)
                          : Text(
                              'Send Reset Link',
                              style: TextStyle(
                                fontSize: SizeConfig.font(2),
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                    ),
                    SizedBox(height: SizeConfig.hp(2)),

                    // Back to login
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Back to Log In',
                          style: TextStyle(
                            fontSize: SizeConfig.font(2),
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
