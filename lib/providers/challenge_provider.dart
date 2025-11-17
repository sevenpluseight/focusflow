import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:focusflow/models/challenge_model.dart';
import 'package:focusflow/services/services.dart';
import 'package:focusflow/models/models.dart';

class ChallengeProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserService _userService = UserService();

  bool _isLoading = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Stream<List<ChallengeModel>> getPendingChallengesStream() {
    return _firestore
        .collection('challenges')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChallengeModel.fromFirestore(doc))
              .toList(),
        );
  }

  Stream<List<ChallengeModel>> getApprovedChallengesStream() {
    return _firestore
        .collection('challenges')
        .where('status', isEqualTo: 'approved')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChallengeModel.fromFirestore(doc))
              .toList(),
        );
  }

  Stream<List<ChallengeModel>> getOngoingChallengesStream() {
    return _firestore
        .collection('challenges')
        .where('status', isEqualTo: 'approved')
        .where('endDate', isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy('endDate') // Order by what ends soonest
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChallengeModel.fromFirestore(doc))
              .toList(),
        );
  }

  Future<bool> approveChallenge(String challengeId) async {
    _setLoading(true);
    _errorMessage = '';

    try {
      final challengeRef = _firestore.collection('challenges').doc(challengeId);
      await challengeRef.update({'status': 'approved'});
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> rejectChallenge(String challengeId) async {
    _setLoading(true);
    _errorMessage = '';

    try {
      final challengeRef = _firestore.collection('challenges').doc(challengeId);
      await challengeRef.update({'status': 'rejected'});
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<UserModel?> getCoachDetails(String coachId) async {
    if (coachId.isEmpty) return null;

    try {
      final user = await _userService.getUser(coachId);
      return user;
    } catch (e) {
      print('Error fetching coach details in ChallengeProvider: $e');
      return null;
    }
  }
}
