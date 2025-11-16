import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:focusflow/models/challenge_model.dart';

class ChallengeProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _challengesSubscription;

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

  void _listenToApprovedChallenges() {
    _setLoading(true);
    _challengesSubscription = _firestore
        .collection('challenges')
        .where('status', isEqualTo: 'approved')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      debugPrint('ChallengeProvider: Received ${snapshot.docs.length} approved challenges.');
      _approvedChallenges = snapshot.docs
          .map((doc) => ChallengeModel.fromFirestore(doc))
          .toList();
      _errorMessage = null;
      _setLoading(false);
    }, onError: (e) {
      debugPrint('--- CHALLENGE PROVIDER ERROR ---');
      debugPrint('Error listening to approved challenges: $e');
      debugPrint('---------------------------------');
      _errorMessage = 'Error: ${e.toString()}';
      _setLoading(false);
    });
  }

  /// Safely join a challenge by adding the user to the participants array.
  Future<void> joinChallenge(String challengeId, String userId) async {
    _setLoading(true);
    try {
      final challengeRef = _firestore.collection('challenges').doc(challengeId);

      await challengeRef.update({
        'participants': FieldValue.arrayUnion([userId]),
      });

      debugPrint('User $userId successfully joined challenge $challengeId.');
    } on FirebaseException catch (e) {
      debugPrint('FirebaseException joining challenge: ${e.code} - ${e.message}');
      throw Exception('Failed to join challenge: ${e.message}');
    } catch (e) {
      debugPrint('Unexpected error joining challenge: $e');
      throw Exception('Failed to join challenge.');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshChallenges() async {
    // Optional: manually refresh
    _listenToApprovedChallenges();
  }
}
