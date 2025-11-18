import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:focusflow/screens/user/user_home_screen.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:focusflow/models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ------------------------------------------------------------
//  Fakes
// ------------------------------------------------------------

class FakeUserModel extends UserModel {
  FakeUserModel()
      : super(
          uid: '123',
          username: 'Test User',
          email: 'test@example.com',
          role: 'user',
          signInMethod: 'email',
          createdAt: Timestamp.now(),
          dailyTargetHours: 2.0,
        );
}

class FakeUserProvider extends ChangeNotifier implements UserProvider {
  @override
  UserModel? user = FakeUserModel();

  @override
  CoachRequestModel? connectedCoach;

  @override
  bool isLoading = false;

  @override
  List<String> pendingCoachIds = [];

  // 🔥 FIX: Changed return type from Future<void> to Future<bool>
  @override
  Future<bool> fetchUser() async {
    return true;
  }

  @override
  void listenToPendingRequests() {}

  @override
  Future<void> createUser({
    required String uid,
    required String username,
    required String email,
    required double dailyTargetHours,
    required int workInterval,
    required int breakInterval,
    required String focusType,
  }) async {}

  @override
  Future<void> updateSettings({
    double? dailyTargetHours,
    int? workInterval,
    int? breakInterval,
    String? focusType,
  }) async {}

  @override
  Future<void> updateStreak() async {}

  @override
  Future<void> submitCoachApplication({
    required String fullName,
    required String expertise,
    required String bio,
    String? portfolioLink,
  }) async {}

  @override
  Future<void> sendConnectionRequest(String coachId) async {}

  @override
  Stream<List<MessageModel>> getMessagesStream(String coachId) => Stream.value([]);
}

class FakeProgressProvider extends ChangeNotifier implements ProgressProvider {
  @override
  int currentStreak = 3;

  @override
  int longestStreak = 5;

  @override
  DateTime? lastFocusDate = DateTime.now();

  @override
  int get minutesFocusedToday => 90;

  @override
  int get totalFocusedMinutes => 1500;

  @override
  String get totalFocusedHours => (totalFocusedMinutes / 60).toStringAsFixed(1);

  @override
  Future<void> fetchDailyProgress() async {}

  @override
  Future<String> endSession(int durationSeconds) async {
    return '';
  }

  @override
  void skipBreak() {}

  @override
  double todayProgress(double dailyTargetHours) {
    if (dailyTargetHours <= 0) return 0.0;
    return (minutesFocusedToday / (dailyTargetHours * 60)).clamp(0.0, 1.0);
  }

  @override
  String getFormattedProgress(double dailyTargetHours) {
    final minutesToday = minutesFocusedToday;
    if (minutesToday < 60) {
      final targetMinutes = (dailyTargetHours * 60).round();
      return "$minutesToday / $targetMinutes min";
    } else {
      final hoursToday = minutesToday / 60;
      return "${hoursToday.toStringAsFixed(1)} / ${dailyTargetHours.toStringAsFixed(1)} hrs";
    }
  }

  @override
  String uid = '123';
}

// ------------------------------------------------------------
//  Main Test
// ------------------------------------------------------------

void main() {
  testWidgets('UserHomeScreen displays username, tip and progress', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<UserProvider>(create: (_) => FakeUserProvider()),
          ChangeNotifierProvider<ProgressProvider>(create: (_) => FakeProgressProvider()),
        ],
        child: const MaterialApp(home: UserHomeScreen()),
      ),
    );

    // Wait for the frame callback (fetchDailyProgress) to complete
    await tester.pumpAndSettle();

    // 1. Check Username with hardcoded "Good Morning" (as per your widget code)
    expect(find.textContaining('Good Morning, Test User!'), findsOneWidget);

    // 2. Check for the static motivational text
    expect(find.textContaining('Every minute counts! Stay focused'), findsOneWidget);

    // 3. Check Progress calculation:
    // Target = 2.0 hours.
    // Focused = 90 minutes.
    // Widget logic: "$completedMinutes min / ${dailyTarget.toStringAsFixed(0)} hrs"
    // Expect: "90 min / 2 hrs"
    expect(find.textContaining("Today's Progress: 90 min / 2 hrs"), findsOneWidget);
  });
}