import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:focusflow/models/models.dart';
import 'package:focusflow/models/challenge_model.dart';

class CoachProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<UserModel> _connectedUsers = [];
  bool _isLoading = false;

  List<UserModel> get connectedUsers => _connectedUsers;
  bool get isLoading => _isLoading;

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

    } catch (e) {
      print('Error fetching connected users: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
}