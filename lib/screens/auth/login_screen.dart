import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:focusflow/providers/providers.dart';
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
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().clearError();
    });
  }

  InputDecoration _inputDecoration(String label, {Widget? suffixIcon}) {
    final isDark = widget.isDarkMode;
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: isDark ? const Color(0xFF2C2F33) : Colors.white,
      labelStyle: TextStyle(
        color: isDark ? Colors.white70 : Colors.black87,
        fontSize: SizeConfig.font(2),
      ),
      hintStyle: TextStyle(
        color: isDark ? Colors.white54 : Colors.black45,
        fontSize: SizeConfig.font(1.8),
      ),
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
    final authProvider = context.watch<AuthProvider>();

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
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: SizeConfig.wp(6)),
            child: Column(
              children: [
                SizedBox(height: SizeConfig.hp(21)),

                // App name
                Text(
                  "FocusFlow",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: SizeConfig.font(5.5),
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
                    onPressed: () {
                      final email = _emailController.text.trim();
                      authProvider.resetPassword(email);
                    },
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

                // Error message
                if (authProvider.errorMessage != null)
                  Text(
                    authProvider.errorMessage!,
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: SizeConfig.font(1.8),
                    ),
                  ),
                SizedBox(height: SizeConfig.hp(3)),

                // Loading or buttons
                authProvider.isLoading
                    ? const CircularProgressIndicator()
                    : Column(
                        children: [
                          // Sign In button
                          ElevatedButton(
                            onPressed: () {
                              final email = _emailController.text.trim();
                              final password = _passwordController.text.trim();
                              authProvider.signIn(email, password);
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize:
                                  Size(double.infinity, SizeConfig.hp(6)),
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

                          // Divider
                          Row(
                            children: [
                              const Expanded(child: Divider()),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: SizeConfig.wp(2)),
                                child: Text(
                                  "Or continue with",
                                  style: TextStyle(fontSize: SizeConfig.font(1.8)),
                                ),
                              ),
                              const Expanded(child: Divider()),
                            ],
                          ),
                          SizedBox(height: SizeConfig.hp(3)),

                          // Google sign in
                          OutlinedButton(
                            onPressed: authProvider.signInWithGoogle,
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
                                    color: widget.isDarkMode
                                        ? const Color(0xFFBFFB4F)
                                        : Colors.black,
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
                                  context.read<AuthProvider>().clearError();
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
                                    color: widget.isDarkMode
                                        ? const Color(0xFFBFFB4F)
                                        : Colors.black,
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

          // Floating Icon
          Positioned(
            top: SizeConfig.hp(-1),
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/icons/png/focusflow_icon_transparent.png',
                width: SizeConfig.wp(50),
                height: SizeConfig.wp(50),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
