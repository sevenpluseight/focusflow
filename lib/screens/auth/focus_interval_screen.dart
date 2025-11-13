import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:focusflow/widgets/widgets.dart';
import 'package:focusflow/utils/utils.dart';

class CustomizeFocusFlowScreen extends StatefulWidget {
  final String username;
  final String email;
  final String password;

  const CustomizeFocusFlowScreen({
    super.key,
    required this.username,
    required this.email,
    required this.password,
  });

  @override
  State<CustomizeFocusFlowScreen> createState() => _CustomizeFocusFlowScreenState();
}

class _CustomizeFocusFlowScreenState extends State<CustomizeFocusFlowScreen> {
  double _dailyTargetHours = 2.0;
  int _selectedIntervalIndex = 0;
  final List<double> _snapPoints = [1, 4, 8];

  final List<Map<String, dynamic>> _focusIntervals = [
    {
      "title": "Breeze",
      "work": 25,
      "break": 5,
      "description": "Quick, refreshing focus bursts.",
    },
    {
      "title": "Flow",
      "work": 50,
      "break": 10,
      "description": "Smooth, deep concentration.",
    },
    {
      "title": "Horizon",
      "work": 90,
      "break": 20,
      "description": "Extended, immersive focus.",
    },
  ];

  Future<void> _submit(AuthProvider authProvider, UserProvider userProvider) async {
    authProvider.clearError();

    // Sign up with AuthProvider
    final user = await authProvider.signUp(
      username: widget.username,
      email: widget.email,
      password: widget.password,
    );

    if (authProvider.errorMessage != null || user == null) {
      CustomSnackBar.show(
        context,
        message: authProvider.errorMessage ?? "Sign-up failed.",
        type: SnackBarType.error,
      );
      return;
    }

    // Create Firestore user document with UserProvider
    final selected = _focusIntervals[_selectedIntervalIndex];
    try {
      await userProvider.createUser(
        uid: user.uid,
        username: widget.username,
        email: widget.email,
        dailyTargetHours: _dailyTargetHours,
        workInterval: selected['work'],
        breakInterval: selected['break'],
        focusType: selected['title'],
      );

      if (mounted) {
        CustomSnackBar.show(
          context,
          message: 'Account created successfully! 🎉',
          type: SnackBarType.success,
        );
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } catch (e) {
      CustomSnackBar.show(
        context,
        message: "Failed to save user data: $e",
        type: SnackBarType.error,
      );
    }
  }

  Widget _buildSlider(bool isDarkMode) {
    final limeColor = const Color(0xFFBFFB4F);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: limeColor,
            inactiveTrackColor: isDarkMode ? Colors.white10 : Colors.grey[300],
            thumbColor: limeColor,
            overlayColor: limeColor.withOpacity(0.2),
            trackHeight: 8,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            trackShape: RoundedRectSliderTrackShape(),
          ),
          child: Slider(
            value: _dailyTargetHours,
            min: 1,
            max: 8,
            divisions: 7,
            label: "${_dailyTargetHours.toStringAsFixed(0)}h",
            onChanged: (val) => setState(() => _dailyTargetHours = val),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _snapPoints
                .map((mark) => Text(
                      "${mark.toInt()}h",
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.white70 : Colors.black,
                      ),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            "${_dailyTargetHours.toStringAsFixed(0)} hours/day",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white70 : Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final limeColor = const Color(0xFFBFFB4F);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Consumer2<AuthProvider, UserProvider>(
        builder: (context, authProvider, userProvider, _) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: kToolbarHeight,
                    color: isDark ? theme.appBarTheme.backgroundColor : Colors.white,
                    alignment: Alignment.center,
                    child: const SizedBox.shrink(),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: SizeConfig.wp(4)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: SizeConfig.hp(1)),
                          Center(
                            child: Text(
                              "Customize Your Flow",
                              style: TextStyle(
                                fontSize: SizeConfig.font(4),
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          SizedBox(height: SizeConfig.hp(3)),

                          Text(
                            "1. What's your daily focus hours?",
                            style: TextStyle(
                              fontSize: SizeConfig.font(2.4),
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          SizedBox(height: SizeConfig.hp(1.5)),
                          _buildSlider(isDark),
                          SizedBox(height: SizeConfig.hp(4)),

                          Text(
                            "2. What's your preferred focus interval?",
                            style: TextStyle(
                              fontSize: SizeConfig.font(2.4),
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          SizedBox(height: SizeConfig.hp(1.5)),

                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _focusIntervals.length,
                            itemBuilder: (context, index) {
                              final data = _focusIntervals[index];
                              final isSelected = _selectedIntervalIndex == index;

                              return GestureDetector(
                                onTap: () => setState(() => _selectedIntervalIndex = index),
                                child: Container(
                                  margin: EdgeInsets.only(bottom: SizeConfig.hp(2)),
                                  padding: EdgeInsets.all(SizeConfig.wp(4)),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.white10 : Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isSelected
                                          ? limeColor
                                          : (isDark ? Colors.white30 : Colors.grey[300]!),
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        isSelected
                                            ? Icons.check_circle_rounded
                                            : Icons.circle_outlined,
                                        color: isSelected
                                            ? limeColor
                                            : (isDark ? Colors.white70 : Colors.black45),
                                      ),
                                      SizedBox(width: SizeConfig.wp(3)),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              data['title'],
                                              style: TextStyle(
                                                fontSize: SizeConfig.font(2.4),
                                                fontWeight: FontWeight.bold,
                                                color: isDark ? Colors.white : Colors.black87,
                                              ),
                                            ),
                                            Text(
                                              "${data['work']} min work • ${data['break']} min break",
                                              style: TextStyle(
                                                fontSize: SizeConfig.font(2.0),
                                                color: isDark ? Colors.white70 : Colors.black54,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              data['description'],
                                              style: TextStyle(
                                                fontSize: SizeConfig.font(1.9),
                                                color: isDark ? Colors.white60 : Colors.black45,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),

                          // Done button
                          (authProvider.isLoading || userProvider.isLoading)
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                                  onPressed: () => _submit(authProvider, userProvider),
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: Size(double.infinity, SizeConfig.hp(6)),
                                    backgroundColor: limeColor,
                                    foregroundColor: Colors.black,
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    "Done",
                                    style: TextStyle(
                                      fontSize: SizeConfig.font(2.6),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                          SizedBox(height: SizeConfig.hp(2)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
