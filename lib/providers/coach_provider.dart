import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:focusflow/models/models.dart';
import 'package:focusflow/services/services.dart';
import 'package:flutter/foundation.dart';

class CoachProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<UserModel> _connectedUsers = [];
  bool _isLoading = false;

  List<UserModel> get connectedUsers => _connectedUsers;
  bool get isLoading => _isLoading;

  List<ChallengeModel> _challenges = [];
  bool _challengesLoading = false;

  List<ChallengeModel> get challenges => _challenges;
  bool get challengesLoading => _challengesLoading;

  List<DistractionLogModel> _userLogs = [];
  bool _logsLoading = false;

  List<DistractionLogModel> get userLogs => _userLogs;
  bool get logsLoading => _logsLoading;

  // ignore: prefer_final_fields
  Map<String, int> _todayFocusMinutes = {};
  Map<String, int> get todayFocusMinutes => _todayFocusMinutes;

  List<DailyProgressModel> _userProgressHistory = [];
  bool _progressHistoryLoading = false;

  List<DailyProgressModel> get userProgressHistory => _userProgressHistory;
  bool get progressHistoryLoading => _progressHistoryLoading;

  List<DailyProgressModel> _aggregateProgressHistory = [];
  bool _aggregateHistoryLoading = false;

  List<DailyProgressModel> get aggregateProgressHistory =>
      _aggregateProgressHistory;
  bool get aggregateHistoryLoading => _aggregateHistoryLoading;

  String _aiInsights = "";
  bool _aiLoading = false;

  String get aiInsights => _aiInsights;
  bool get aiLoading => _aiLoading;

  List<ConnectionRequestModel> _pendingRequests = [];
  List<ConnectionRequestModel> get pendingRequests => _pendingRequests;

  String _systemAiRecommendations = "Tap to load system recommendations.";
  bool _systemAiLoading = false;

  String get systemAiRecommendations => _systemAiRecommendations;
  bool get systemAiLoading => _systemAiLoading;

  /// Fetches all users from Firestore where the 'coachId' matches the currently logged-in coach's UID.
  Future<void> fetchConnectedUsers(String coachId) async {
    if (coachId.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      // This is the query that uses the 'coachId' field
      final querySnapshot = await _firestore
          .collection('users')
          .where('coachId', isEqualTo: coachId)
          .get();

      _connectedUsers = querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();

      // After fetching users, fetch their progress in parallel
      await _fetchUsersProgress(_connectedUsers);
    } catch (e) {
      debugPrint('Error fetching connected users: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchUsersProgress(List<UserModel> users) async {
    final todayId = _getTodayId();
    _todayFocusMinutes.clear();

    List<Future<void>> futures = [];

    for (final user in users) {
      futures.add(
        _firestore
            .collection('users')
            .doc(user.uid)
            .collection('dailyProgress')
            .doc(todayId)
            .get()
            .then((doc) {
              if (doc.exists) {
                // Store minutes in the map: 'userId' -> 120
                _todayFocusMinutes[user.uid] =
                    (doc.data()?['focusedMinutes'] as num? ?? 0).toInt();
              } else {
                _todayFocusMinutes[user.uid] = 0;
              }
            })
            .catchError((e) {
              debugPrint('Error fetching progress for ${user.uid}: $e');
              _todayFocusMinutes[user.uid] = 0; // Default to 0 on error
            }),
      );
    }
    // Wait for all progress fetches to complete
    await Future.wait(futures);
  }

  String _getTodayId() {
    final now = DateTime.now();
    // Logic from ProgressProvider: day resets at 4AM
    final adjusted = now.hour < 4 ? now.subtract(const Duration(days: 1)) : now;
    return "${adjusted.year.toString().padLeft(4, '0')}-"
        "${adjusted.month.toString().padLeft(2, '0')}-"
        "${adjusted.day.toString().padLeft(2, '0')}";
  }

  // This function will save the new challenge
  Future<void> submitChallengeForApproval({
    required String name,
    required Timestamp startDate,
    required Timestamp endDate,
    required int focusGoalHours,
    required String description,
  }) async {
    final coachId = _auth.currentUser?.uid;
    if (coachId == null) {
      throw Exception('You must be logged in to create a challenge.');
    }

    try {
      final newChallengeRef = _firestore.collection('challenges').doc();

      final newChallenge = ChallengeModel(
        id: newChallengeRef.id,
        name: name,
        focusGoalHours: focusGoalHours,
        description: description,
        coachId: coachId,
        createdAt: Timestamp.now(),
        status: 'pending', // Awaiting admin approval
        startDate: startDate,
        endDate: endDate,
      );

      await newChallengeRef.set(newChallenge.toMap());
    } catch (e) {
      debugPrint('Error submitting challenge: $e');
      throw Exception('Failed to submit challenge.');
    }
  }

  Future<void> fetchMyChallenges() async {
    final coachId = _auth.currentUser?.uid;
    if (coachId == null) return;

    _challengesLoading = true;
    notifyListeners();

    try {
      final querySnapshot = await _firestore
          .collection('challenges')
          .where('coachId', isEqualTo: coachId)
          .orderBy('createdAt', descending: true)
          .get();

      // Use the new ChallengeModel.fromFirestore factory
      _challenges = querySnapshot.docs
          .map((doc) => ChallengeModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error fetching challenges: $e');
    } finally {
      _challengesLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDistractionLogs(String userId) async {
    if (userId.isEmpty) return;
    _logsLoading = true;
    notifyListeners();
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('distractionLogs') // Assumes this subcollection
          .orderBy('createdAt', descending: true)
          .get();
      _userLogs = querySnapshot.docs
          .map((doc) => DistractionLogModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error fetching distraction logs: $e');
    } finally {
      _logsLoading = false;
      notifyListeners();
    }
  }

  Future<void> reportLog(String userId, String logId) async {
    final coachId = _auth.currentUser?.uid;
    if (coachId == null) throw Exception('Not logged in');
    try {
      final newReportRef = _firestore.collection('reports').doc();
      final newReport = ReportModel(
        id: newReportRef.id,
        reportedItemId: logId,
        reportedUserId: userId,
        coachId: coachId,
        createdAt: Timestamp.now(),
        type: ReportType.distractionLog,
      );
      await newReportRef.set(newReport.toMap());
    } catch (e) {
      debugPrint('Error reporting log: $e');
      throw Exception('Failed to submit report.');
    }
  }

  Future<void> sendMessage({
    required String userId,
    required String text,
    required MessageType type,
  }) async {
    final coachId = _auth.currentUser?.uid;
    if (coachId == null) throw Exception('Not logged in');
    if (text.isEmpty) throw Exception('Message cannot be empty');

    try {
      // We store messages in a subcollection on the USER's document.
      // This makes it easy for the user to fetch their own messages.
      final messageRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('messages')
          .doc();

      final newMessage = MessageModel(
        id: messageRef.id,
        coachId: coachId,
        userId: userId,
        text: text,
        type: type,
        createdAt: Timestamp.now(),
      );

      await messageRef.set(newMessage.toMap());
    } catch (e) {
      debugPrint('Error sending message: $e');
      throw Exception('Failed to send message.');
    }
  }

  Future<void> fetchUserFocusHistory(String userId) async {
    if (userId.isEmpty) return;

    _progressHistoryLoading = true;
    _userProgressHistory = []; // Clear old data
    notifyListeners();

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('dailyProgress')
          .orderBy('date', descending: true) // Show newest first
          .limit(30)
          .get();

      _userProgressHistory = querySnapshot.docs
          .map((doc) => DailyProgressModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error fetching focus history: $e');
    } finally {
      _progressHistoryLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAggregateFocusHistory() async {
    // Basic cache: If we already fetched it, don't fetch again.
    if (_aggregateProgressHistory.isNotEmpty) return;

    _aggregateHistoryLoading = true;
    notifyListeners();

    try {
      Map<String, int> tempAggregates = {};
      List<Future<QuerySnapshot>> futures = [];

      // 1. Create all the fetch futures (one for each connected user)
      for (final user in _connectedUsers) {
        futures.add(
          _firestore
              .collection('users')
              .doc(user.uid)
              .collection('dailyProgress')
              .orderBy('date', descending: true)
              .limit(30) // Get last 30 days of data
              .get(),
        );
      }

      // 2. Wait for all users' data to return
      final allSnapshots = await Future.wait(futures);

      // 3. Process all the data
      for (final snapshot in allSnapshots) {
        for (final doc in snapshot.docs) {
          final progress = DailyProgressModel.fromFirestore(doc);
          final date = progress.date;
          final minutes = progress.focusedMinutes;
          // Add this day's minutes to the aggregate map
          tempAggregates[date] = (tempAggregates[date] ?? 0) + minutes;
        }
      }

      // 4. Convert map to a sorted list
      _aggregateProgressHistory = tempAggregates.entries
          .map(
            (e) => DailyProgressModel(
              date: e.key,
              focusedMinutes: e.value,
              updatedAt: DateTime.now(), // This date doesn't matter here
            ),
          )
          .toList();

      _aggregateProgressHistory.sort((a, b) => a.date.compareTo(b.date));
    } catch (e) {
      debugPrint('Error fetching aggregate focus history: $e');
    } finally {
      _aggregateHistoryLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAiRiskFlags(String userId) async {
    _aiLoading = true;
    _aiInsights = "";
    notifyListeners();

    try {
      // 1. Get the data we've already fetched
      final UserModel? user = _connectedUsers.firstWhere(
        (u) => u.uid == userId,
      );
      if (user == null) throw Exception("User not found");

      // --- NEW 5 AM REFRESH LOGIC ---
      // 1. Check Firebase for a saved analysis
      final userDocRef = _firestore.collection('users').doc(userId);
      final userSnapshot = await userDocRef.get();
      final userData = userSnapshot.data();

      final savedAnalysis = userData?['aiAnalysis'] as Map<String, dynamic>?;
      final savedTimestamp = savedAnalysis?['updatedAt'] as Timestamp?;

      if (savedTimestamp != null) {
        final now = DateTime.now();
        final today5AM = DateTime(
          now.year,
          now.month,
          now.day,
          5,
        ); // 5 AM today

        DateTime appDayStart;
        if (now.isBefore(today5AM)) {
          // It's currently before 5 AM, so the "app day" started at 5 AM yesterday
          appDayStart = today5AM.subtract(const Duration(days: 1));
        } else {
          // It's after 5 AM, so the "app day" started at 5 AM today
          appDayStart = today5AM;
        }

        final savedDate = savedTimestamp.toDate();

        // Check if the saved analysis is from the "current app day"
        if (savedDate.isAfter(appDayStart)) {
          // The cache is good (saved *after* 5 AM on the current app day), so use it.
          _aiInsights = savedAnalysis?['insights'] ?? "No insights found.";
          debugPrint(
            "--- Using Cached AI Analysis (from ${savedDate.toIso8601String()}) ---",
          );
          _aiLoading = false;
          notifyListeners();
          return; // Stop here
        }
      }

      // 2. If no recent analysis, fetch data and call Gemini
      debugPrint("--- No cache. Fetching new AI Analysis... ---");
      await fetchDistractionLogs(userId);
      await fetchUserFocusHistory(userId);

      // 2. Build a prompt for the Gemini API
      String prompt =
          """
        You are a helpful productivity coach. Analyze the following data for a user named '${user.username}'.
        Provide your analysis in clean markdown format.
        Use markdown headings (like '## AI Risk Flags') for sections.
        Inside lists, use bolding (like '**Term:**') for key concepts. Be concise and professional.

        Here is the user's data:
        ## User's Profile
        - **Current Streak:** ${user.currentStreak ?? 0} days
        - **Longest Streak:** ${user.longestStreak ?? 0} days
        - **Daily Target:** ${user.dailyTargetHours ?? 2} hours

        ## Recent Focus History (last 14 days)
        ${_userProgressHistory.isEmpty ? "- No focus history." : _userProgressHistory.map((p) => "- **${p.date}:** ${p.focusedMinutes} minutes focused.").join("\n")}

        ## Recent Distraction Logs
        ${_userLogs.isEmpty ? "- No distraction logs." : _userLogs.map((l) => "- **${l.category}:** ${l.note ?? ''}").join("\n")}

        ## Coach's Analysis
        (Provide your '## AI Risk Flags' and '## Positive Insights' below)
      """;

      debugPrint("--- Sending Prompt to Gemini ---");
      debugPrint(prompt);

      // 3. Call the Gemini Service
      final response = await GeminiService.generateText(prompt);
      _aiInsights = response;

      await userDocRef.update({
        'aiAnalysis': {
          'insights': _aiInsights, // Save the single response
          'updatedAt': Timestamp.now(),
        },
      });
    } catch (e) {
      _aiInsights = "Error generating AI insights: $e";
    } finally {
      _aiLoading = false;
      notifyListeners();
    }
  }

  Future<List<String>> fetchAiGuideSuggestions(String userId) async {
    // 1. Get user data
    final UserModel? user = _connectedUsers.firstWhere((u) => u.uid == userId);
    if (user == null) return [];

    await fetchUserFocusHistory(userId); // Make sure we have the latest history

    // 2. Create a specific prompt for guides
    String prompt =
        """
      A user named '${user.username}' has this data:
      - Current Streak: ${user.currentStreak ?? 0} days
      - Daily Target: ${user.dailyTargetHours ?? 2} hours
      - Recent Focus: ${_userProgressHistory.isEmpty ? "None" : _userProgressHistory.map((p) => "${p.focusedMinutes} mins").join(", ")}
      
      Based on this, generate exactly 3 short, actionable "guide" strategies for me (as their coach) to suggest.
      Start each suggestion with a '*' and a space. Do not add any other text.
      Example:
      * Try breaking your task into smaller 25-min sessions.
      * Set a small, achievable goal for your next session.
      * Take a 5-minute walk when you feel distracted.
    """;

    try {
      // 3. Call Gemini
      final response = await GeminiService.generateText(prompt);

      // 4. Parse the response into a list
      if (response.isEmpty) return [];

      final suggestions = response
          .split('* ')
          .where((s) => s.trim().isNotEmpty) // Remove empty entries
          .map((s) => s.trim().replaceAll('*', '')) // Clean up
          .toList();

      return suggestions.isNotEmpty ? suggestions : ["No suggestions found."];
    } catch (e) {
      print("Error fetching AI guides: $e");
      return ["Error: Could not get AI suggestions."];
    }
  }

  Future<void> fetchPendingRequests() async {
    final coachId = _auth.currentUser?.uid;
    if (coachId == null) return;

    try {
      final querySnapshot = await _firestore
          .collection('connectionRequests')
          .where('coachId', isEqualTo: coachId)
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      _pendingRequests = querySnapshot.docs
          .map((doc) => ConnectionRequestModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error fetching pending requests: $e');
    }
    notifyListeners(); // Notify listeners even if it's just to clear the list
  }

  Future<void> approveConnectionRequest(String requestId, String userId) async {
    // 1. Update the user's document to link them to this coach
    await _firestore.collection('users').doc(userId).update({
      'coachId': _auth.currentUser?.uid,
    });

    // 2. Delete the request (or set status to 'approved')
    await _firestore.collection('connectionRequests').doc(requestId).delete();

    // 3. Refresh the data
    await fetchPendingRequests();
    await fetchConnectedUsers(_auth.currentUser!.uid); // Re-fetch user list
  }

  Future<void> rejectConnectionRequest(String requestId) async {
    // 1. Just delete the request
    await _firestore.collection('connectionRequests').doc(requestId).delete();

    // 2. Refresh the list
    await fetchPendingRequests();
  }

  Future<void> fetchSystemAiRecommendations() async {
    _systemAiLoading = true;
    _systemAiRecommendations = "Analyzing connected users for system trends...";
    notifyListeners();

    try {
      final users = _connectedUsers;
      final totalUsers = users.length;
      final totalStreak = users.fold<int>(
        0,
        (total, u) => total + (u.currentStreak ?? 0),
      );
      final avgStreak = totalUsers > 0
          ? (totalStreak / totalUsers).toStringAsFixed(1)
          : '0';

      String prompt =
          """
        You are a system-level productivity consultant providing advice to a coach managing ${totalUsers} clients.
        The average client streak is ${avgStreak} days.
        Provide one single, high-leverage coaching strategy, 20 words maximum, that the coach can apply
        to their entire client base this week to improve overall consistency.
        Start with: 'System Strategy:'
      """;

      final response = await GeminiService.generateText(prompt);

      _systemAiRecommendations = response
          .replaceFirst('System Strategy:', '')
          .trim();
    } catch (e) {
      _systemAiRecommendations = "Error fetching system recommendation.";
    } finally {
      _systemAiLoading = false;
      notifyListeners();
    }
  }
}
