import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import 'package:focusflow/models/models.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:focusflow/screens/coach/coach_home_screen.dart';
import 'package:focusflow/services/services.dart';

//  Mock Auth Provider
class MockAuthProvider extends ChangeNotifier implements AuthProvider {
  @override
  firebase_auth.User? get user => MockUser();

  @override
  String? get userEmail => 'fake@test.com';
  @override
  bool get isLoggedIn => true;
  @override
  bool get isLoading => false;
  @override
  String? get errorMessage => null;
  @override
  String? get infoMessage => null;

  @override
  AuthService get authService => throw UnimplementedError();

  @override
  void clearError() {}

  @override
  bool doesEmailMatch(String email) => false;

  @override
  Future<void> signIn(String email, String password) async {}

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<firebase_auth.User?> signUp({
    required String username,
    required String email,
    required String password,
  }) async => null;

  @override
  Future<void> resetPassword(String email) async {}

  @override
  Future<void> signOut(BuildContext context) async {}
}

//  Mock Firebase User
class MockUser implements firebase_auth.User {
  @override
  String get uid => "fake_coach_id";

  @override
  bool get emailVerified => true;

  @override
  bool get isAnonymous => false;

  @override
  firebase_auth.UserMetadata get metadata =>
      firebase_auth.UserMetadata(0, 0);

  @override
  List<firebase_auth.UserInfo> get providerData => [];

  @override
  String? get email => "fake@test.com";

  @override
  String? get displayName => "Fake Coach";

  @override
  String? get phoneNumber => null;

  @override
  String? get photoURL => null;

  @override
  String? get tenantId => null;

  @override
  Future<void> delete() async {}

  @override
  Future<String> getIdToken([bool forceRefresh = false]) async => "fake";

  @override
  Future<firebase_auth.IdTokenResult> getIdTokenResult(
          [bool forceRefresh = false]) async =>
      throw UnimplementedError();

  @override
  Future<firebase_auth.User> reload() async => this;

  @override
  Future<void> sendEmailVerification(
      [firebase_auth.ActionCodeSettings? actionCodeSettings]) async {}

  Future<firebase_auth.User> updateEmail(String newEmail) async => this;

  @override
  Future<void> updatePassword(String newPassword) async {}

  @override
  Future<void> updatePhoneNumber(
      firebase_auth.PhoneAuthCredential credential) async {}

  @override
  Future<void> updateDisplayName(String? displayName) async {}

  @override
  Future<void> updatePhotoURL(String? photoURL) async {}

  @override
  Future<void> updateProfile(
      {String? displayName, String? photoURL}) async {}

  @override
  firebase_auth.MultiFactor get multiFactor =>
      throw UnimplementedError();

  // ----- Required abstract methods introduced by Firebase Auth -----
  @override
  Future<firebase_auth.UserCredential> linkWithCredential(
          firebase_auth.AuthCredential credential) async =>
      throw UnimplementedError();

  @override
  Future<firebase_auth.UserCredential> reauthenticateWithCredential(
          firebase_auth.AuthCredential credential) async =>
      throw UnimplementedError();

  Future<void> sendSignInLinkToEmail(
          firebase_auth.ActionCodeSettings actionCodeSettings) async {}

  @override
  Future<firebase_auth.User> unlink(String providerId) async => this;

  @override
  Future<firebase_auth.UserCredential> linkWithPopup(
          firebase_auth.AuthProvider provider) async =>
      throw UnimplementedError();

  @override
  Future<firebase_auth.UserCredential> reauthenticateWithPopup(
          firebase_auth.AuthProvider provider) async =>
      throw UnimplementedError();

  Future<firebase_auth.ConfirmationResult> linkWithPhoneNumber(
          String phoneNumber,
          [firebase_auth.RecaptchaVerifier? verifier]) async =>
      throw UnimplementedError();

  @override
  Future<firebase_auth.UserCredential> linkWithProvider(
          firebase_auth.AuthProvider provider) async =>
      throw UnimplementedError();

  @override
  Future<firebase_auth.UserCredential> linkWithRedirect(
          firebase_auth.AuthProvider provider) async =>
      throw UnimplementedError();

  @override
  Future<firebase_auth.UserCredential> reauthenticateWithProvider(
          firebase_auth.AuthProvider provider) async =>
      throw UnimplementedError();

  @override
  Future<firebase_auth.UserCredential> reauthenticateWithRedirect(
          firebase_auth.AuthProvider provider) async =>
      throw UnimplementedError();

  @override
  Future<void> verifyBeforeUpdateEmail(String newEmail,
      [firebase_auth.ActionCodeSettings? actionCodeSettings]) async {}

  @override
  String? get refreshToken => null;
}

//  Mock CoachProvider
class MockCoachProvider extends ChangeNotifier implements CoachProvider {
  List<UserModel> _connectedUsers = [];
  List<ConnectionRequestModel> _pendingRequests = [];

  @override
  List<UserModel> get connectedUsers => _connectedUsers;

  @override
  List<ConnectionRequestModel> get pendingRequests => _pendingRequests;

  @override
  bool get isLoading => false;

  // --- FIX: Added errorMessage implementation ---
  @override
  String? get errorMessage => null; 

  @override
  List<ChallengeModel> get challenges => [];

  @override
  bool get challengesLoading => false;

  @override
  List<DistractionLogModel> get userLogs => [];

  @override
  bool get logsLoading => false;

  @override
  Map<String, int> get todayFocusMinutes => {};

  @override
  List<DailyProgressModel> get userProgressHistory => [];

  @override
  bool get progressHistoryLoading => false;

  @override
  String get aiInsights => "";

  @override
  bool get aiLoading => false;

  @override
  String get systemAiRecommendations => "Test tip";

  @override
  bool get systemAiLoading => false;

  @override
  String? get errorMessage => null;

  @override
  Future<void> fetchConnectedUsers(String coachId) async {}

  @override
  Future<void> fetchMyChallenges() async {}

  @override
  Future<void> fetchPendingRequests() async {}

  @override
  Future<void> fetchDistractionLogs(String userId) async {}

  @override
  Future<void> reportLog(String userId, String logId) async {}

  @override
  Future<void> sendMessage(
      {required String userId,
      required String text,
      required MessageType type}) async {}

  @override
  Future<void> fetchUserFocusHistory(String userId) async {}

  @override
  Future<void> fetchAiRiskFlags(String userId) async {}

  @override
  Future<List<String>> fetchAiGuideSuggestions(String userId) async =>
      [];

  @override
  Future<void> approveConnectionRequest(
          String requestId, String userId) async {}

  @override
  Future<void> rejectConnectionRequest(String requestId) async {}

  @override
  Future<void> fetchSystemAiRecommendations() async {}

  @override
  Future<void> submitChallengeForApproval({
    required String name,
    required Timestamp startDate,
    required Timestamp endDate,
    required int focusGoalHours,
    required String description,
  }) async {}

  bool get aggregateHistoryLoading => false;

  List<DailyProgressModel> get aggregateProgressHistory => [];

  // Not included in interface but required by your code
  Future<void> fetchAggregateFocusHistory() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'CoachHomeScreen shows "No users are currently at risk" when list empty',
    (tester) async {
      final mockCoachProvider = MockCoachProvider();
      final mockAuthProvider = MockAuthProvider();

      mockCoachProvider._connectedUsers = [];
      mockCoachProvider._pendingRequests = [];

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<CoachProvider>(
              create: (_) => mockCoachProvider,
            ),
            ChangeNotifierProvider<AuthProvider>(
              create: (_) => mockAuthProvider,
            ),
          ],
          child: const MaterialApp(home: CoachHomeScreen()),
        ),
      );

      expect(find.text('User Management'), findsOneWidget);
      expect(find.text('At-Risk Users'), findsOneWidget);
      expect(find.text('Great job! No users are currently at risk.'),
          findsOneWidget);
    },
  );

  testWidgets(
    'CoachHomeScreen shows at-risk user tile',
    (tester) async {
      final mockCoachProvider = MockCoachProvider();
      final mockAuthProvider = MockAuthProvider();

      final atRiskUser = UserModel(
        uid: "u123",
        username: "TestUserAtRisk",
        email: "t@r.com",
        role: "user",
        signInMethod: "email",
        createdAt: Timestamp.now(),
        currentStreak: 0,
      );

      mockCoachProvider._connectedUsers = [atRiskUser];
      mockCoachProvider._pendingRequests = [];

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<CoachProvider>(
              create: (_) => mockCoachProvider,
            ),
            ChangeNotifierProvider<AuthProvider>(
              create: (_) => mockAuthProvider,
            ),
          ],
          child: const MaterialApp(home: CoachHomeScreen()),
        ),
      );

      // Ensure empty message is gone
      expect(find.text('Great job! No users are currently at risk.'),
          findsNothing);

      // Ensure triage tile is shown
      expect(find.text('Triage Alert: TestUserAtRisk'), findsOneWidget);
      expect(
        find.text('User is inactive. Focus streak needs immediate reboot.'),
        findsOneWidget,
      );
    },
  );
}