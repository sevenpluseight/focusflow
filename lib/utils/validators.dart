class AuthValidators {
  /// Validate email format and allowed domains
  static bool isEmailValid(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) return false;

    final allowedDomains = ['gmail.com', 'outlook.com', 'yahoo.com'];
    final domain = email.split('@').last.toLowerCase();
    return allowedDomains.contains(domain);
  }

  /// Check if password has at least 8 characters
  static bool hasLength(String password) => password.length >= 8;

  /// Check if password contains at least one uppercase letter
  static bool hasUppercase(String password) => RegExp(r'[A-Z]').hasMatch(password);

  /// Check if password contains at least one special character
  static bool hasSpecial(String password) =>
      RegExp(r'[!@#\$&*~%^()\-_=+{}\[\]:;,.<>?]').hasMatch(password);

  /// Check if password avoids common sequences like 'abc', '123', 'qwe', or 'password'
  static bool noSequential(String password) =>
      !RegExp(r'(?:abc|123|qwe|password)', caseSensitive: false).hasMatch(password);

  /// Check if two passwords match
  static bool passwordsMatch(String password, String confirmPassword) =>
      password == confirmPassword && confirmPassword.isNotEmpty;

  /// Calculate password strength (0.0 to 1.0)
  static double passwordStrength(String password) {
    double strength = 0;
    if (hasUppercase(password)) strength += 0.25;
    if (hasSpecial(password)) strength += 0.25;
    if (hasLength(password)) strength += 0.25;
    if (noSequential(password)) strength += 0.25;
    return strength;
  }

  /// Optional: return a label for password strength
  static String passwordStrengthLabel(String password) {
    final strength = passwordStrength(password);
    if (strength < 0.3) return "Weak 😕";
    if (strength < 0.6) return "Medium 😐";
    if (strength < 0.8) return "Strong 💪";
    return "Very Strong 🔥";
  }
}
