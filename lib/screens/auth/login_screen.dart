import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:focusflow/screens/auth/auth.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:focusflow/utils/utils.dart';
import 'package:focusflow/widgets/widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: SizeConfig.wp(6)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: SizeConfig.hp(2)),
                  Image.asset(
                    isDarkMode
                        ? 'assets/icons/png/focusflow_icon_transparent.png'
                        : 'assets/icons/png/focusflow_icon_borderline.png',
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

                  // Email input
                  CustomTextField(
                    controller: _emailController,
                    labelText: "Email",
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: SizeConfig.hp(2)),

                  // Password input
                  CustomTextField(
                    controller: _passwordController,
                    labelText: "Password",
                    obscureText: _obscurePassword,
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

                  // Forgot password button
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Forgot Password?",
                        style: text.bodyMedium?.copyWith(
                          color: colors.onSurface.withValues(alpha: 0.8),
                          fontSize: SizeConfig.font(2),
                        ),
                      ),
                    ),
                  ),

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

                  // Sign in button
                  PrimaryButton(
                    onPressed: () async {
                      final email = _emailController.text.trim();
                      final password = _passwordController.text.trim();
                      setState(() => _localErrorMessage = null);

                      await authProvider.signIn(email, password);

                      if (!mounted) return;

                      if (authProvider.isLoggedIn) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const UserLoadingScreen(),
                          ),
                        );
                      } else if (authProvider.errorMessage != null &&
                          authProvider.errorMessage!.isNotEmpty) {
                        _showTemporaryError(authProvider.errorMessage!);
                      } else {
                        _showTemporaryError("An unknown error occurred.");
                      }
                    },
                    child: const Text("Sign In"),
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
                            color:
                                colors.onSurface.withAlpha((255 * 0.8).toInt()),
                          ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  SizedBox(height: SizeConfig.hp(3)),

                  // Google Sign-In button
                  SecondaryButton(
                    onPressed: () async {
                      await authProvider.signInWithGoogle();
                      if (!mounted) return;

                      if (authProvider.isLoggedIn) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const UserLoadingScreen(),
                          ),
                        );
                      } else if (authProvider.errorMessage != null &&
                          authProvider.errorMessage!.isNotEmpty) {
                        _showTemporaryError(authProvider.errorMessage!);
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/icons/png/google.png',
                          height: SizeConfig.hp(3),
                        ),
                        SizedBox(width: SizeConfig.wp(2)),
                        const Text(
                          "Sign in with Google",
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
                          color:
                              colors.onSurface.withAlpha((255 * 0.8).toInt()),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.read<AuthProvider>().clearError();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignUpScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "Sign Up",
                          style: text.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: SizeConfig.font(2),
                            color:
                                isDarkMode ? colors.primary : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
