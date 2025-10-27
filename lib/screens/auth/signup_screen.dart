import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:focusflow/screens/auth/auth.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:focusflow/utils/utils.dart';
import 'package:focusflow/widgets/widgets.dart';

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

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _passwordsMatch = false;
  bool _startedTyping = false;
  bool _isEmailValid = false;

  bool _hasLength = false;
  bool _hasUppercase = false;
  bool _hasSpecial = false;
  bool _noSequential = false;

  double _passwordStrength = 0.0;
  String _passwordStrengthLabel = "";

  bool get _isFormValid =>
      _usernameController.text.trim().isNotEmpty &&
      _emailController.text.trim().isNotEmpty &&
      _isEmailValid &&
      _hasLength &&
      _hasUppercase &&
      _hasSpecial &&
      _noSequential &&
      _passwordsMatch;

  void _checkPasswordStrength(String password) {
    if (!_startedTyping && password.isNotEmpty) _startedTyping = true;

    setState(() {
      _hasLength = Validators.hasLength(password);
      _hasUppercase = Validators.hasUppercase(password);
      _hasSpecial = Validators.hasSpecial(password);
      _noSequential = Validators.noSequential(password);

      _passwordStrength = Validators.passwordStrength(password);
      _passwordStrengthLabel = Validators.passwordStrengthLabel(password);
    });
  }

  void _checkPasswordsMatch() {
    setState(() {
      _passwordsMatch = Validators.passwordsMatch(
        _passwordController.text,
        _confirmPasswordController.text,
      );
    });
  }

  Future<void> _signUp(AuthProvider authProvider) async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();

    if (!_isFormValid) return;

    authProvider.clearError();

    await authProvider.signUp(username: username, email: email, password: password);

    if (authProvider.errorMessage == null && mounted) {
      CustomSnackBar.show(
        context,
        message: 'Account created successfully! 🎉',
        type: SnackBarType.success,
      );
      Navigator.pop(context);
    } else if (authProvider.errorMessage != null &&
        authProvider.errorMessage!.contains('linked')) {
      _showInfoModal(
        "Email Already Registered",
        authProvider.errorMessage!,
        redirectToLogin: true,
      );
    }
  }

  void _showInfoModal(String title, String message, {bool redirectToLogin = false}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              if (redirectToLogin) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                );
              }
            },
            child: const Text(
              "OK",
              style: TextStyle(color: Color(0xFFBFFB4F)),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, {Widget? suffixIcon, bool isError = false}) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: theme.inputDecorationTheme.fillColor,
      labelStyle: theme.inputDecorationTheme.labelStyle,
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: isError
              ? Colors.redAccent
              : theme.inputDecorationTheme.enabledBorder!.borderSide.color,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: isError
              ? Colors.redAccent
              : theme.inputDecorationTheme.focusedBorder!.borderSide.color,
        ),
      ),
    );
  }

  Widget _buildRule(String text, bool met, bool isDarkMode) {
    final textColor = isDarkMode
        ? (met ? Colors.lightGreen : Colors.white54)
        : (met ? Colors.green[800] : Colors.black54);

    return Row(
      children: [
        Icon(
          met ? Icons.check_circle : Icons.cancel,
          color: met
              ? Colors.lightGreen
              : (isDarkMode ? Colors.white30 : Colors.black26),
          size: SizeConfig.font(2.15),
        ),
        SizedBox(width: SizeConfig.wp(2)),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: SizeConfig.font(2.05),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().clearError();
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final bottomPaddingForScroll = 160.0;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) => Scaffold(
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
            actions: [
              Padding(
                padding: EdgeInsets.only(right: SizeConfig.wp(1.2)),
                child: IconButton(
                  icon: Icon(
                    isDarkMode ? Pixel.sunalt : Pixel.moon,
                    size: SizeConfig.wp(6.8),
                  ),
                  onPressed: () => context.read<ThemeProvider>().toggleTheme(),
                ),
              ),
            ],
          ),
          backgroundColor: theme.scaffoldBackgroundColor,
          body: Stack(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  SizeConfig.wp(4),
                  SizeConfig.hp(3),
                  SizeConfig.wp(4),
                  bottomPaddingForScroll,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Text(
                          "Create Your Account",
                          style: TextStyle(
                            fontSize: SizeConfig.font(4),
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      SizedBox(height: SizeConfig.hp(4)),

                      // Username
                      TextField(
                        controller: _usernameController,
                        decoration: _inputDecoration("Username"),
                        style: TextStyle(
                          fontSize: SizeConfig.font(2),
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      SizedBox(height: SizeConfig.hp(2)),

                      // Email
                      TextField(
                        controller: _emailController,
                        decoration: _inputDecoration(
                          "Email",
                          isError: _emailController.text.isNotEmpty && !_isEmailValid,
                        ),
                        style: TextStyle(
                          fontSize: SizeConfig.font(2),
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {
                          setState(() {
                            _isEmailValid = Validators.isEmailValid(value.trim());
                          });
                        },
                      ),
                      if (_emailController.text.isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              _isEmailValid ? Pixel.check : Pixel.alert,
                              color: _isEmailValid
                                  ? Colors.lightGreen
                                  : Colors.redAccent,
                              size: SizeConfig.font(2.7),
                            ),
                            SizedBox(width: SizeConfig.wp(2)),
                            Expanded(
                              child: Text(
                                _isEmailValid
                                    ? "Valid email"
                                    : "Invalid email format",
                                style: TextStyle(
                                  color: _isEmailValid
                                      ? Colors.lightGreen
                                      : Colors.redAccent,
                                  fontSize: SizeConfig.font(1.95),
                                ),
                              ),
                            ),
                          ],
                        ),
                      SizedBox(height: SizeConfig.hp(2)),

                      // Password
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: _passwordController,
                            obscureText: !_passwordVisible,
                            style: TextStyle(
                              fontSize: SizeConfig.font(2),
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                            onChanged: (val) {
                              _checkPasswordStrength(val);
                              _checkPasswordsMatch();
                            },
                            decoration: _inputDecoration(
                              "Password",
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _passwordVisible ? Pixel.eye : Pixel.eyeclosed,
                                  color: isDarkMode
                                      ? Colors.white70
                                      : Colors.black54,
                                  size: SizeConfig.wp(5),
                                ),
                                onPressed: () =>
                                    setState(() => _passwordVisible = !_passwordVisible),
                              ),
                            ),
                          ),
                          SizedBox(height: SizeConfig.hp(1)),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: _passwordController.text.isEmpty
                                  ? 0
                                  : _passwordStrength,
                              backgroundColor:
                                  isDarkMode ? Colors.white10 : Colors.grey[300],
                              color: _passwordStrength < 0.3
                                  ? Colors.redAccent
                                  : _passwordStrength < 0.6
                                      ? Colors.orangeAccent
                                      : _passwordStrength < 0.8
                                          ? Colors.lightGreen
                                          : Colors.greenAccent,
                              minHeight: SizeConfig.hp(1),
                            ),
                          ),
                          if (_startedTyping) ...[
                            SizedBox(height: SizeConfig.hp(1)),
                            Text(
                              _passwordStrengthLabel,
                              style: TextStyle(
                                fontSize: SizeConfig.font(1.95),
                                color: isDarkMode
                                    ? Colors.white70
                                    : Colors.black87,
                              ),
                            ),
                            SizedBox(height: SizeConfig.hp(1)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildRule("At least 8 characters", _hasLength, isDarkMode),
                                SizedBox(height: SizeConfig.hp(0.8)),
                                _buildRule("1 uppercase letter", _hasUppercase, isDarkMode),
                                SizedBox(height: SizeConfig.hp(0.8)),
                                _buildRule("1 special character", _hasSpecial, isDarkMode),
                                SizedBox(height: SizeConfig.hp(0.8)),
                                _buildRule(
                                  "Avoid easy patterns like '123' or 'abc'",
                                  _noSequential,
                                  isDarkMode,
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: SizeConfig.hp(2)),

                      // Confirm Password
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: !_confirmPasswordVisible,
                        style: TextStyle(
                          fontSize: SizeConfig.font(2),
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                        onChanged: (_) {
                          _checkPasswordsMatch();
                          setState(() {});
                        },
                        decoration: _inputDecoration(
                          "Confirm Password",
                          isError: _confirmPasswordController.text.isNotEmpty &&
                              !_passwordsMatch,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _confirmPasswordVisible ? Pixel.eye : Pixel.eyeclosed,
                              color:
                                  isDarkMode ? Colors.white70 : Colors.black54,
                              size: SizeConfig.wp(5),
                            ),
                            onPressed: () => setState(
                              () => _confirmPasswordVisible =
                                  !_confirmPasswordVisible,
                            ),
                          ),
                        ),
                      ),

                      if (authProvider.errorMessage != null)
                        Padding(
                          padding: EdgeInsets.only(top: SizeConfig.hp(1)),
                          child: Text(
                            authProvider.errorMessage!,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      SizedBox(height: SizeConfig.hp(4)),
                    ],
                  ),
                ),
              ),

              // Create Account button
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.wp(4),
                      vertical: SizeConfig.hp(8),
                    ),
                    child: authProvider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed:
                                _isFormValid ? () => _signUp(authProvider) : null,
                            style: ElevatedButton.styleFrom(
                              minimumSize:
                                  Size(double.infinity, SizeConfig.hp(6)),
                              backgroundColor: _isFormValid
                                  ? const Color(0xFFBFFB4F)
                                  : const Color(0xFFBFFB4F).withOpacity(0.4),
                              foregroundColor: _isFormValid
                                  ? Colors.black
                                  : Colors.black45,
                              elevation: _isFormValid ? 3 : 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side:
                                    const BorderSide(color: Colors.transparent),
                              ),
                            ),
                            child: Text(
                              "Create Account",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: SizeConfig.font(2.6),
                              ),
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}