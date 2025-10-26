import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:focusflow/screens/auth/auth.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:focusflow/utils/utils.dart';
import 'package:focusflow/screens/user/user.dart';

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
  bool _obscurePassword = true;
  String? _localErrorMessage;

  late double iconSize;
  late double iconTopOffset;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().clearError();
    });
  }

@override
void didChangeDependencies() {
    super.didChangeDependencies();
    SizeConfig.init(context);
    iconSize = SizeConfig.wp(50);
    iconTopOffset = SizeConfig.hp(-1);
}

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label, {Widget? suffixIcon}) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = theme.textTheme;

    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: colors.surface,
      labelStyle: text.bodyMedium?.copyWith(
        color: colors.onSurface.withAlpha((255 * 0.8).toInt()),
        fontSize: SizeConfig.font(2),
      ),
      hintStyle: text.bodyMedium?.copyWith(
        color: colors.onSurface.withAlpha((255 * 0.6).toInt()),
        fontSize: SizeConfig.font(1.8),
      ),
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SizeConfig.wp(3)),
        borderSide: BorderSide(
          color: colors.outlineVariant,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SizeConfig.wp(3)),
        borderSide: BorderSide(color: colors.primary, width: 2),
      ),
    );
  }

  void _showTemporaryError(String message) {
    setState(() => _localErrorMessage = message);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _localErrorMessage = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = theme.textTheme;
    final authProvider = context.watch<AuthProvider>();

    final bool isDarkMode = theme.brightness == Brightness.dark;
    final IconData themeIcon = isDarkMode ? Pixel.sunalt : Pixel.moon;
    final Color themeIconColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: theme.appBarTheme.elevation,
        iconTheme: theme.appBarTheme.iconTheme,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: SizeConfig.wp(1.2)),
            child: IconButton(
              icon: Icon(
                themeIcon,
                size: SizeConfig.wp(6.8),
                color: themeIconColor,
              ),
              onPressed: widget.onToggleTheme,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: SizeConfig.wp(6)),
            child: Column(
              children: [
                SizedBox(height: SizeConfig.hp(2)),
                Image.asset(
                  'assets/icons/png/focusflow_icon_transparent.png',
                  width: SizeConfig.wp(35),
                  height: SizeConfig.wp(35),
                  fit: BoxFit.contain,
                ),
                SizedBox(height: SizeConfig.hp(1)),
                Text(
                  "FocusFlow",
                  style: text.titleLarge?.copyWith(
                    fontSize: SizeConfig.font(5.5),
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
                SizedBox(height: SizeConfig.hp(3)),

                // Email
                TextField(
                  controller: _emailController,
                  decoration: _inputDecoration("Email"),
                  keyboardType: TextInputType.emailAddress,
                  style: text.bodyLarge?.copyWith(
                    color: colors.onSurface,
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
                        color: colors.onSurface.withAlpha((255 * 0.7).toInt()),
                        size: SizeConfig.wp(5),
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  style: text.bodyLarge?.copyWith(
                    color: colors.onSurface,
                    fontSize: SizeConfig.font(2),
                  ),
                ),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      final email = _emailController.text.trim();
                      context.read<AuthProvider>().resetPassword(email);
                    },
                    child: Text(
                      "Forgot Password?",
                      style: text.bodyMedium?.copyWith(
                        color: colors.onSurface.withAlpha((255 * 0.8).toInt()),
                        fontSize: SizeConfig.font(1.8),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: SizeConfig.hp(3)),

                // Error message
                if (_localErrorMessage != null)
                  Text(
                    _localErrorMessage!,
                    style: text.bodyMedium?.copyWith(
                      color: Colors.redAccent,
                      fontSize: SizeConfig.font(1.8),
                    ),
                  ),

                // Info message
                if (authProvider.infoMessage != null)
                  Text(
                    authProvider.infoMessage!,
                    style: text.bodyMedium?.copyWith(
                      color: Colors.greenAccent,
                      fontSize: SizeConfig.font(1.8),
                    ),
                  ),

                SizedBox(height: SizeConfig.hp(3)),

                // Sign In button
                ElevatedButton(
                  onPressed: () async {
                    final email = _emailController.text.trim();
                    final password = _passwordController.text.trim();
                    setState(() => _localErrorMessage = null);

                    await authProvider.signIn(email, password);

                    if (!mounted) return;

                    if (authProvider.isLoggedIn) {
                      if (mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserLoadingScreen(
                              isDarkMode: isDarkMode,
                              onToggleTheme: widget.onToggleTheme ?? () {},
                            ),
                          ),
                        );
                      }
                    } else {
                      final err = authProvider.errorMessage?.toLowerCase() ?? "";
                      if (err.contains("invalid-credential") ||
                          err.contains("user-not-found") ||
                          err.contains("wrong-password") ||
                          err.contains("invalid email") ||
                          err.contains("password is invalid")) {
                        _showTemporaryError("Incorrect email or password.");
                      } else if (authProvider.errorMessage != null &&
                          authProvider.errorMessage!.isNotEmpty) {
                        _showTemporaryError(authProvider.errorMessage!);
                      } else {
                        _showTemporaryError("Incorrect email or password.");
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBFFB4F),
                    elevation: 2,
                    foregroundColor: Colors.black,
                    minimumSize: Size(double.infinity, SizeConfig.hp(6)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Sign In",
                    style: text.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: SizeConfig.font(2),
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: SizeConfig.hp(2)),

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: SizeConfig.wp(2)),
                      child: Text(
                        "Or continue with",
                        style: text.bodyMedium?.copyWith(
                          fontSize: SizeConfig.font(1.8),
                          color: colors.onSurface.withAlpha((255 * 0.8).toInt()),
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                SizedBox(height: SizeConfig.hp(3)),

                // Google sign in
                OutlinedButton(
                  onPressed: () async {
                    await authProvider.signInWithGoogle();

                    if (!mounted) return;
                    if (authProvider.isLoggedIn) {
                      if (mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserLoadingScreen(
                              isDarkMode: isDarkMode,
                              onToggleTheme: widget.onToggleTheme ?? () {},
                            ),
                          ),
                        );
                      }
                    } else if (authProvider.errorMessage != null) {
                      _showTemporaryError(authProvider.errorMessage!);
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(double.infinity, SizeConfig.hp(6)),
                    side: BorderSide(color: colors.primary),
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
                        style: text.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: SizeConfig.font(2),
                          color: isDarkMode ? colors.primary : Colors.black,
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
                      "Don't have an account?",
                      style: text.bodyMedium?.copyWith(
                        fontSize: SizeConfig.font(1.8),
                        color: colors.onSurface.withAlpha((255 * 0.8).toInt()),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<AuthProvider>().clearError();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignUpScreen(
                              isDarkMode: isDarkMode,
                              onToggleTheme: widget.onToggleTheme ?? () {},
                            ),
                          ),
                        );
                      },
                      child: Text(
                        "Sign Up",
                        style: text.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: SizeConfig.font(2),
                          color: isDarkMode ? colors.primary : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}