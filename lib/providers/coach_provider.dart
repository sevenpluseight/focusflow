import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:focusflow/models/models.dart';
import 'package:focusflow/models/challenge_model.dart';
import 'package:focusflow/models/report_model.dart';
import 'package:focusflow/models/distraction_log_model.dart';

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

  Map<String, int> _todayFocusMinutes = {};
  Map<String, int> get todayFocusMinutes => _todayFocusMinutes;

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
      print('Error fetching connected users: $e');
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
            _todayFocusMinutes[user.uid] = (doc.data()?['minutesFocused'] as num? ?? 0).toInt();
          } else {
            _todayFocusMinutes[user.uid] = 0;
          }
        }).catchError((e) {
          print('Error fetching progress for ${user.uid}: $e');
          _todayFocusMinutes[user.uid] = 0; // Default to 0 on error
        })
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
    required int durationDays,
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
        durationDays: durationDays,
        focusGoalHours: focusGoalHours,
        description: description,
        coachId: coachId,
        createdAt: Timestamp.now(),
        status: 'pending', // Awaiting admin approval 
      );

      await newChallengeRef.set(newChallenge.toMap());
      
    } catch (e) {
      print('Error submitting challenge: $e');
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
      
      _challenges = querySnapshot.docs.map((doc) {
        final data = doc.data();
        // Manually create ChallengeModel from map
        return ChallengeModel(
          id: data['id'] ?? '',
          name: data['name'] ?? '',
          durationDays: data['durationDays'] ?? 0,
          focusGoalHours: data['focusGoalHours'] ?? 0,
          description: data['description'] ?? '',
          coachId: data['coachId'] ?? '',
          createdAt: data['createdAt'] ?? Timestamp.now(),
          status: data['status'] ?? 'pending',
        );
      }).toList();

    } catch (e) {
      print('Error fetching challenges: $e');
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
      print('Error fetching distraction logs: $e');
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
      print('Error reporting log: $e');
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
      print('Error sending message: $e');
      throw Exception('Failed to send message.');
    }
  }
}