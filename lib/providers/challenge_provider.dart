import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:focusflow/models/models.dart';
import 'package:focusflow/services/services.dart';

class ChallengeProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserService _userService = UserService();

  StreamSubscription<QuerySnapshot>? _challengesSubscription;

  List<ChallengeModel> _approvedChallenges = [];
  List<ChallengeModel> get approvedChallenges => _approvedChallenges;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ChallengeProvider() {
    _listenToApprovedChallenges();
  }

  @override
  void dispose() {
    _challengesSubscription?.cancel();
    super.dispose();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// LISTEN to approved challenges
  void _listenToApprovedChallenges() {
    _setLoading(true);

    _challengesSubscription?.cancel();

    _challengesSubscription = _firestore
        .collection('challenges')
        .where('status', isEqualTo: 'approved')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        debugPrint('ChallengeProvider: Received ${snapshot.docs.length} approved challenges.');

        _approvedChallenges =
            snapshot.docs.map((doc) => ChallengeModel.fromFirestore(doc)).toList();

        _setError(null);
        _setLoading(false);
      },
      onError: (e) {
        debugPrint('Error listening to approved challenges: $e');
        _setError('Error: $e');
        _setLoading(false);
      },
    );
  }

  /// STREAM: pending challenges
  Stream<List<ChallengeModel>> getPendingChallengesStream() {
    return _firestore
        .collection('challenges')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => ChallengeModel.fromFirestore(doc)).toList(),
        );
  }

  /// STREAM: approved (ongoing) challenges
  Stream<List<ChallengeModel>> getOngoingChallengesStream() {
    return _firestore
        .collection('challenges')
        .where('status', isEqualTo: 'approved')
        .where('endDate', isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy('endDate')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => ChallengeModel.fromFirestore(doc)).toList(),
        );
  }

  /// JOIN challenge
  Future<void> joinChallenge(String challengeId, String userId) async {
    if (userId.isEmpty) return;

    debugPrint('Joining challenge $challengeId as $userId');
    _setLoading(true);

    try {
      final docRef = _firestore.collection('challenges').doc(challengeId);

      await docRef.update({
        'participants': FieldValue.arrayUnion([userId]),
      });

      debugPrint('Successfully joined challenge $challengeId.');
      _markUserJoinedLocal(challengeId, userId);
    } on FirebaseException catch (e) {
      debugPrint('FirebaseException: ${e.code} — ${e.message}');
      _setError(e.message);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Update local state after joining
  void _markUserJoinedLocal(String challengeId, String userId) {
    final index = _approvedChallenges.indexWhere((c) => c.id == challengeId);
    if (index == -1) return;

    final challenge = _approvedChallenges[index];
    final participants = List<String>.from(challenge.participants ?? []);

    if (!participants.contains(userId)) {
      participants.add(userId);

      _approvedChallenges[index] =
          challenge.copyWith(participants: participants);

      notifyListeners();
      debugPrint('Local state updated: User $userId joined challenge $challengeId.');
    }
  }

  /// MANUAL refresh
  Future<void> refreshChallenges() async {
    _listenToApprovedChallenges();
  }

  /// APPROVE challenge
  Future<bool> approveChallenge(String challengeId) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _firestore.collection('challenges').doc(challengeId).update({
        'status': 'approved',
      });
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  /// REJECT challenge
  Future<bool> rejectChallenge(String challengeId) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _firestore.collection('challenges').doc(challengeId).update({
        'status': 'rejected',
      });
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  /// Fetch coach
  Future<UserModel?> getCoachDetails(String coachId) async {
    if (coachId.isEmpty) return null;

    try {
      return await _userService.getUser(coachId);
    } catch (e) {
      debugPrint('Error fetching coach details in ChallengeProvider: $e');
      return null;
    }
  }
}
