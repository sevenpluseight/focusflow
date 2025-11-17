import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:focusflow/screens/user/user.dart';
import 'package:focusflow/providers/user_provider.dart';
import 'package:focusflow/providers/progress_provider.dart';
import 'package:focusflow/models/models.dart'; // For UserModel, MessageModel, CoachRequestModel
import 'package:cloud_firestore/cloud_firestore.dart';

// Fakes
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

  @override
  Future<void> fetchUser() async {}

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
  Future<void> fetchDailyProgress() async {}

  @override
  Future<String> endSession(int durationSeconds) async {
    return '';
  }

  @override
  void skipBreak() {}

  @override
  double todayProgress(double dailyTargetHours) {
    return (minutesFocusedToday / 60) / dailyTargetHours;
  }

  @override
  String getFormattedProgress(double dailyTargetHours) {
    return '$minutesFocusedToday / ${dailyTargetHours.toStringAsFixed(0)} hrs';
  }

  @override
  String uid = '123';
}

// ⚠ The main entry point of the test
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

    await tester.pumpAndSettle();

    expect(find.textContaining('Good Morning, Test User!'), findsOneWidget);
    expect(find.textContaining('Every minute counts! Stay focused'), findsOneWidget);
    expect(find.textContaining("Today's Progress: 90 min / 2 hrs"), findsOneWidget);
  });
}
