import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:focusflow/models/models.dart';

class ChallengeProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  void _listenToApprovedChallenges() {
    _setLoading(true);

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

  /// Join a challenge using Firestore arrayUnion
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

  Future<void> refreshChallenges() async {
    _listenToApprovedChallenges();
  }
}
