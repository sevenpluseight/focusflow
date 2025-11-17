import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:focusflow/models/coach_request_model.dart';
import 'package:focusflow/services/services.dart'; // For AdminStatService

class CoachRequestProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AdminStatService _statsService;

  CoachRequestProvider({AdminStatService? statsService})
    : _statsService = statsService ?? AdminStatService();

  bool _isLoading = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Fetches ONLY pending coach requests (for the admin menu)
  Stream<List<CoachRequestModel>> getPendingRequestsStream() {
    return _firestore
        .collection('coachRequests')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CoachRequestModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// Fetches ALL coach requests (for the "See All" page)
  Stream<List<CoachRequestModel>> getAllRequestsStream() {
    return _firestore
        .collection('coachRequests')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CoachRequestModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// Approves a coach request
  Future<bool> approveCoachRequest(CoachRequestModel request) async {
    _setLoading(true);
    _errorMessage = '';

    try {
      final batch = _firestore.batch();

      // 1. Update the request status to 'approved'
      final requestRef = _firestore.collection('coachRequests').doc(request.id);
      batch.update(requestRef, {'status': 'approved'});

      // 2. Update the user's role to 'coach'
      final userRef = _firestore.collection('users').doc(request.userId);
      batch.update(userRef, {'role': 'coach'});

      // 3. Update admin stats (decrement user, increment coach)
      _statsService.updateUserCount(batch, 'user', false);
      _statsService.updateUserCount(batch, 'coach', true);

      await batch.commit();
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  /// Rejects a coach request
  Future<bool> rejectCoachRequest(String requestId) async {
    _setLoading(true);
    _errorMessage = '';

    try {
      final requestRef = _firestore.collection('coachRequests').doc(requestId);
      await requestRef.update({'status': 'rejected'});

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }
}
